#!/usr/bin/env ruby

require 'rexml/document'
require 'rubygems'
require 'rake'

path = ARGV[0] # Example: "some/repo/manifest/default.xml"
root = REXML::Document.new(File.new(path)).root

default = root.get_elements("//default")[0]
remotes = {}

root.each_element("//remote") do |remote|
  remotes[remote.attributes['name']] = remote
end

root.each_element("//project") do |project|
  name     = project.attributes['name']
  path     = project.attributes['path']
  remote   = remotes[project.attributes['remote'] || default.attributes['remote']]
  fetch    = remote.attributes['fetch']
  revision = project.attributes['revision'] || default.attributes['revision']

  print "#{name} #{revision}...\n"

  sh %{git clone #{fetch}#{name} #{path}} unless File.directory?("#{path}/.git")

  cwd = Dir.getwd()
  Dir.chdir(path)

  sh %{git fetch --tags}
  sh %{git checkout #{revision}}

  Dir.chdir(cwd)

  project.each_element("copyfile") do |copyfile|
    src = copyfile.attributes['src']
    dest = copyfile.attributes['dest']
    cp "#{path}/#{src}", dest
  end
end

