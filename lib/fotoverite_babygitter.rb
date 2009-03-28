require 'cgi'
require 'rubygems'
require 'grit'

 
$:.unshift(File.dirname(__FILE__))
require 'babygitter/repo'
require 'babygitter/report_generator'
require 'babygitter/branch'
require 'babygitter/author'
require 'babygitter/version'
#added class for grit
require 'babygitter/commit_addedum'
require 'babygitter/commit_stats_addedum'




class Symbol
  def to_proc
    lambda {|i| i.send(self)}
  end
end

module Babygitter
  
  class << self
    # Customizable options
    attr_reader :version
    attr_accessor :repo_path, :image_assets_path, :stylesheet, :template, :additional_links, :instructions, :use_whitelist,
    :jquery, :folder_levels, :marked_folders
    
    def blacklisted_folders=(marked_folders)
      raise "must be an array" unless blacklisted_folders.is_a?(Array)
      @blacklisted_folders = blacklisted_folders
    end
    
    def folder_levels=(folder_levels)
      raise "must be an array" unless folder_levels.is_a?(Array)
      @folder_levels = folder_levels
    end
    
    def report_file_path
      "#{@repo_path.gsub(/\/$/, "")}" + "/log"
    end
  
  end
  
  self.repo_path = FileUtils.pwd
  self.stylesheet = File.join(File.dirname(__FILE__), 'babygitter/assets/stylesheets/default.css')
  self.image_assets_path = File.join(File.dirname(__FILE__), 'babygitter/assets/image_assets')
  self.jquery = File.join(File.dirname(__FILE__), 'babygitter/assets/javascripts/jquery.js')
  self.template = File.join(File.dirname(__FILE__), 'babygitter/assets/templates/default.html.erb')
  self.additional_links = File.join(File.dirname(__FILE__), 'babygitter/assets/guides/bdd_stack.html.erb')
  self.instructions = File.join(File.dirname(__FILE__), 'babygitter/assets/guides/display_only.html.erb')
  self.use_whitelist = false
  self.folder_levels = [1]
  self.marked_folders = []

end