#!/usr/bin/env ruby

require 'rexml/document'
require 'rubygems'
require 'rake'
if ARGV.size < 4
  puts "I need at least 4 arg: repo/manifest.xml newmanifest.xml ep-engine master"
  exit 1
end

path = ARGV[0] # Required. Example: some/repo/manifest/default.xml
oxml = ARGV[1] # Example: output/build-manifest.xml -- usable as input to repo tool.
gerrit_project = ARGV[2] # Required.
gerrit_refspec = ARGV[3] # Required.

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

if oxml
  # Emit a manifest.xml that can be used as input to
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
      remote  = project.attributes['remote']
      path    = project.attributes['path'] || project.attributes['name']
	  curr = project.attributes['revision'] || default.attributes['revision']
	  if name == gerrit_project
         curr = gerrit_refspec
      end
      Dir.chdir(path) do
        #curr = `git rev-parse HEAD`.chomp
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
    o.write "</manifest>\n"
  end
end
