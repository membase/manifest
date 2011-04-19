#!/usr/bin/env ruby

require 'rexml/document'
require 'rubygems'
require 'rake'

if ARGV.size < 1
  puts "I need at least 1 arg: repo/manifest.xml"
  puts "Ex: fetch-manifest.rb repo/manifest/default.xml [optional/override.xml] [optional/changes/out.txt]"
  exit 1
end

path = ARGV[0] # Required. Example: some/repo/manifest/default.xml
more = ARGV[1] # Optional. Example: some/override.xml
emit = ARGV[2] # Optional. Example: output/changes-since-last-fetch.txt
oxml = ARGV[3] # Optional. Example: output/build-manifest.xml -- usable as input to repo tool.

root = REXML::Document.new(File.new(path)).root

default = root.get_elements("//default")[0]
remotes = {}

root.each_element("//remote") do |remote|
  remotes[remote.attributes['name']] = remote
end

projects = {}

root.each_element("//project") do |project|
  projects[project.attributes['name']] = project
end

# An override.xml file can be useful to specify different remote
# servers, such as to a closer, local git mirror.
#
if more
  more_root = REXML::Document.new(File.new(more)).root
  more_root.each_element("//remote") do |remote|
    remotes[remote.attributes['name']] = remote
  end
  more_root.each_element("//project") do |project|
    projects[project.attributes['name']] = project
  end
end

changes = {}

projects.each do |name, project|
  path     = project.attributes['path'] || project.attributes['name']
  remote   = remotes[project.attributes['remote'] || default.attributes['remote']]
  fetch    = remote.attributes['fetch']
  revision = project.attributes['revision'] || default.attributes['revision']

  print "#{name} #{revision}...\n"

  unless File.directory?("#{path}/.git")
    sh %{git clone #{fetch}#{name} #{path}}
  else
    Dir.chdir(path) do
      sh %{git remote update}
    end
  end

  Dir.chdir(path) do
    curr = `git rev-parse HEAD`.chomp

    sh %{git fetch --tags}
    sh %{git reset --hard origin/#{revision} || git reset --hard #{revision}}

    changes[name] =
      "#{name} #{revision}...\n" +
      `git log --pretty=format:'%h %an, %s' --abbrev-commit #{curr}..HEAD --`
  end

  project.each_element("copyfile") do |copyfile|
    src = copyfile.attributes['src']
    dest = copyfile.attributes['dest']
    cp "#{path}/#{src}", dest
  end
end

if emit
  result = []
  changes.keys.sort.each do |name|
    result << "=================="
    result << changes[name]
    result << ""
  end
  result = result.join("\n") + "\n"
  puts result
  File.open(emit, 'w') {|o| o.write(result)} unless emit == '--'
end

if oxml
  # Optionally emit a manifest.xml that can be used as input to
  # the repo / fetch-manifest.rb tool.
  #
  File.open(oxml, 'w') do |o|
    o.write "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    o.write "<manifest>\n"
    remotes.keys.sort.each do |name|
      remote = remotes[name]
      o.write "  <remote name=\"#{name}\" fetch=\"#{remote.attributes['fetch']}\"/>\n"
    end
    o.write "\n"
    o.write "  <default remote=\"#{default.attributes['remote']}\" revision=\"#{default.attributes['revision']}\"/>\n"
    o.write "\n"
    projects.keys.sort.each do |name|
      project = projects[name]
      path    = project.attributes['path'] || project.attributes['name']
      Dir.chdir(path) do
        curr = `git rev-parse HEAD`.chomp
        o.write "  <project name=\"#{name}\" path=\"#{path}\" revision=\"#{curr}\"/>\n"
      end
    end
    o.write "</manifest>\n"
  end
end
