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
volt = ARGV[4] # Optional. voltron revision, to be in emitted manifest

root = REXML::Document.new(File.new(path)).root

default = root.get_elements("//default")[0]

remotes_arr = []
remotes = {}
root.each_element("//remote") do |remote|
  remotes_arr << remote.attributes['name']
  remotes[remote.attributes['name']] = remote
end

projects_arr = []
projects = {}
root.each_element("//project") do |project|
  projects_arr << project.attributes['name']
  projects[project.attributes['name']] = project
end

# An override.xml file can be useful to specify different remote
# servers, such as to a closer, local git mirror.
#
if more
  more_root = REXML::Document.new(File.new(more)).root
  more_root.each_element("//remote") do |remote|
    unless remotes[remote.attributes['name']]
      remotes_arr << remote.attributes['name']
    end
    remotes[remote.attributes['name']] = remote
  end
  more_root.each_element("//project") do |project|
    unless projects[project.attributes['name']]
      projects_arr << project.attributes['name']
    end
    projects[project.attributes['name']] = project
  end
end

changes = {}

projects_arr.each do |name|
  project  = projects[name]
  path     = project.attributes['path'] || project.attributes['name']
  remote   = remotes[project.attributes['remote'] || default.attributes['remote']]
  fetch    = remote.attributes['fetch']
  revision = project.attributes['revision'] || default.attributes['revision']

  print "#{name} #{revision}...\n"

  unless File.directory?("#{path}/.git")
    sh %{git clone #{fetch}#{name} #{path}} do |ok, res|
      exit(false) unless ok
    end
  else
    Dir.chdir(path) do
      sh %{git remote update} do |ok, res|
        exit(false) unless ok
      end
    end
  end

  Dir.chdir(path) do
    curr = `git rev-parse HEAD`.chomp

    sh %{git fetch --tags} do |ok, res|
      exit(false) unless ok
    end

    if revision.include?(' ')
      # Handle when the revision attribute is a full command, like...
      #
      # <project name="ep-engine"
      #          path="ep-engine"
      #      revision="git fetch ssh://buildbot@review.membase.org:29418/ep-engine refs/changes/79/5979/1 && git format-patch -1 --stdout FETCH_HEAD"/>
      #
      # This is useful for gerrit-based test builds.
      #
      sh revision do |ok, res|
        exit(false) unless ok
      end
    else
      sh %{git reset --hard origin/#{revision} || git reset --hard #{revision}} do |ok, res|
        exit(false) unless ok
      end
    end

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
    remotes_arr.each do |name|
      remote = remotes[name]
      o.write "  <remote name=\"#{name}\" fetch=\"#{remote.attributes['fetch']}\"/>\n"
    end
    o.write "\n"
    o.write "  <default remote=\"#{default.attributes['remote']}\" revision=\"#{default.attributes['revision']}\"/>\n"
    o.write "\n"
    projects_arr.each do |name|
      project = projects[name]
      remote  = project.attributes['remote']
      path    = project.attributes['path'] || project.attributes['name']
      Dir.chdir(path) do
        curr = `git rev-parse HEAD`.chomp
        o.write "  <project name=\"#{name}\" path=\"#{path}\" revision=\"#{curr}\""
        if remote
          o.write "\n"
          o.write "           remote=\"#{remote}\""
        end

        has_body = false

        project.each_element do |child|
          o.write(">\n") unless has_body
          o.write("    ")
          o.write(child)
          o.write("\n")
          has_body = true
        end

        if has_body
          o.write "  </project>\n"
        else
          o.write "/>\n"
        end
      end
    end
    if volt
       o.write "  <project name=\"voltron\" path=\"voltron\" revision=\"#{volt}\" />\n"
    end
    o.write "</manifest>\n"
  end
end
