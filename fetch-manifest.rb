#!/usr/bin/env ruby

require 'rexml/document'
require 'rubygems'
require 'rake'

path = ARGV[0] # Required. Example: some/repo/manifest/default.xml
more = ARGV[1] # Optional. Example: some/override.xml

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

projects.each do |name, project|
  path     = project.attributes['path']
  remote   = remotes[project.attributes['remote'] || default.attributes['remote']]
  fetch    = remote.attributes['fetch']
  revision = project.attributes['revision'] || default.attributes['revision']

  print "#{name} #{revision}...\n"

  sh %{git clone #{fetch}#{name} #{path}} unless File.directory?("#{path}/.git")

  cwd = Dir.getwd()
  Dir.chdir(path)

  sh %{git fetch --tags}

  sh %{git reset --hard #{revision} || git reset --hard origin/#{revision}}

  Dir.chdir(cwd)

  project.each_element("copyfile") do |copyfile|
    src = copyfile.attributes['src']
    dest = copyfile.attributes['dest']
    cp "#{path}/#{src}", dest
  end
end

