#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'init'
require 'optparse'
require 'ostruct'
require 'pp'

class BabygitterReport

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.repo_path = File.join(File.dirname(__FILE__))
    options.whitelist = Babygitter.use_whitelist
    options.levels = Babygitter.folder_levels
    options.marked = Babygitter.marked_folders
    options.bare = false
    
 
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: babygitter #{File.basename($0)} [options] [--path=GIT_DIR] [-w] [<folder levels>] [<blacklisted or whitelisted folders>]"

      opts.separator ""
      opts.separator "Specific options:"
      
      # Repo Path
      opts.on("-p", "--path ", "Path to git repository") do |path|
        options.repo_path = path
        Babygitter.repo_path  =  options.repo_path
      end

      # Mark folders to be whitelisted or lacklisted
      opts.on("-l", "--levels ",
              "Folder levels to map to graph", Array) do |levels|
        options.levels  = levels.map {|n| n.to_i}
        Babygitter.folder_levels  = levels.map {|n| n.to_i}
      end
      
      # Mark folders to be whitelisted or lacklisted
      opts.on("-m", "--mark ",
              "Mark folders to be white or black listed depending on option", Array) do |folder|
        options.marked  = folder
        Babygitter.marked_folders  = folder
      end
      
      # Boolean switch.
      opts.on("-w", "--[no-]whitelist", "Run babygitter with whitelist enabled") do |w|
        Babygitter.use_whitelist = w
        options.whitelist = w
      end
      
      # Boolean switch.
      opts.on("-b", "--[no-]bare", "Mark repo as bare") do |b|
        options.bare = b
      end

      # Boolean switch.
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit 0
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts Babygitter::Version::STRING.dup
        exit 0
      end
    end

    opts.parse!(args)
    options
  end  # parse()

end  # class OptparseExample


def set_folders
  FileUtils.mkdir  Babygitter.report_file_path unless File.exists?(Babygitter.report_file_path)
  FileUtils.mkdir "#{Babygitter.report_file_path}/babygitter_report" unless File.exists?("#{Babygitter.report_file_path}/babygitter_report")
  FileUtils.mkdir "#{Babygitter.report_file_path}/babygitter_report/babygitter_images" unless File.exists?("#{Babygitter.report_file_path}/babygitter_report/babygitter_images")
  FileUtils.cp_r(Babygitter.image_assets_path, "#{Babygitter.report_file_path}/babygitter_report/asset_images")
end

def output_file
  options = BabygitterReport.parse(ARGV)
  set_folders
  if options.verbose
    p "Repo path set as #{Babygitter.repo_path}"
    p "Repo is bare" if options.bare
    p "Using whitelist option" if Babygitter.use_whitelist
    p "Report will plot #{Babygitter.folder_levels.join(', ')} level"
    p "Report will be generated to #{Babygitter.report_file_path}"
  end
  puts "begun generating report"
  Babygitter::ReportGenerator.new(Babygitter.repo_path, :is_bare => options.bare).write_report
  puts "Report written to #{Babygitter.report_file_path}/babygitter_report"
end

output_file




