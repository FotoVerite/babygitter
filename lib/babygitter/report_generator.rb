require File.join(File.dirname(__FILE__), 'html_output')
require File.join(File.dirname(__FILE__), 'graph_output')
module Babygitter
  
class ReportGenerator < Babygitter::Repo
   attr_accessor :total_commits, :branches, :branch_names, :authors_names, :began, :lastest_commit, :remote_url, :submodule_list
   
   def initialize(path=".", options = {}, master=nil)
     super
     raise "Could not find stylesheet #{Babygitter.stylesheet}" unless File.exist?(Babygitter.stylesheet)
   end
   
   def write_report
     r = File.open("#{Babygitter.report_file_path}/babygitter_report.html", 'w+')
     r.write templated_report
     r.close
     "Report written to #{Babygitter.report_file_path}/babygitter_report.html"
   end
   
   def templated_report
     require 'erb'
     
     stylesheet, additional_links, instructions, jquery = '', '', '', ''
     File.open(Babygitter.stylesheet, 'r') { |f| stylesheet = f.read }
     File.open(Babygitter.additional_links, 'r') { |f| additional_links = f.read }
     File.open(Babygitter.instructions, 'r') { |f| instructions = f.read }
     File.open(Babygitter.jquery, 'r') { |f| jquery = f.read }
     template = File.read(Babygitter.template)
     result = ERB.new(template).result(binding)

   end
   
 end
end