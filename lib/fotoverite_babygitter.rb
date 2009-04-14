# Babygitter analyzes a git repository and outputs
# a html document detailing all branches and the commits 
# committed on them. It also will ouput graphs with plotting out
# the relationship between authors and the number of commits they 
# have made and an anylsys as to how folders and their files lines
# of code have grown
#

# Author::    Matthew Bergman  (mailto:fotoverite@gmail.com)
# Copyright:: Copyright (c) 2009 
# License::   Distributes under the MIT license

require 'cgi'
require 'rubygems'
require 'grit'

 
$:.unshift(File.dirname(__FILE__))
#Helper modules
require 'babygitter/output_helpers/html_output'
require 'babygitter/output_helpers/graph_output'

#Statistic Modules
require 'babygitter/statistics/date_time_arrays'
require 'babygitter/statistics/folder_analysis_methods'

#added addendums to ruby
require 'babygitter/addendums/commit_addendum' # adds a nice date_time_string convenience method
require 'babygitter/addendums/ruby_addendum'

#regular files
require 'babygitter/errorclasses'
require 'babygitter/repo_analyzer'
require 'babygitter/report_generator'
require 'babygitter/repo_analyzer/branch'
require 'babygitter/repo_analyzer/author'
require 'babygitter/report_generator/application'
require 'babygitter/report_generator/options'

# This module holds basic settings for the html generator.
# TODO figure out if this should instead be a class
module Babygitter
  
  class << self
    # Customizable options
    attr_accessor :repo_path, :image_assets_path, :stylesheet, :template, :additional_links, 
    :instructions, :use_whitelist, :output_graphs, :jquery, :folder_levels, :marked_folders
    
    #checks to make sure that this option is an array durring writing to the blacklisted_folders option
    def blacklisted_folders=(marked_folders)
      raise ArgumentError, "must be an array" unless blacklisted_folders.is_a?(Array)
      @blacklisted_folders = blacklisted_folders
    end
    
    #checks to make sure that this option is an array  durring writing to the folder_levels option
    def folder_levels=(folder_levels)
      raise ArgumentError, "must be an array" unless folder_levels.is_a?(Array)
      @folder_levels = folder_levels
    end
    
    #creates path for the generated html
    def report_file_path
      "#{@repo_path.gsub(/\/$/, "")}" + "/log/babygitter_report"
    end
  
  end
  
  self.repo_path = FileUtils.pwd #Should I even have this set or should I leve it as nil?
  self.stylesheet = 'lib/babygitter/assets/stylesheets/default.css'
  self.image_assets_path = 'lib/babygitter/assets/image_assets'
  self.jquery = 'lib/babygitter/assets/javascripts/jquery.js'
  self.template = 'lib/babygitter/assets/templates/default.html.erb'
  self.additional_links = 'lib/babygitter/assets/guides/bdd_stack.html.erb'
  self.use_whitelist = false
  self.output_graphs = true
  self.folder_levels = [1]
  self.marked_folders = []

end