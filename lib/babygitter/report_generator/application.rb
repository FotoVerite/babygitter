module Babygitter
  class ReportGenerator
    class Application
      
      class << self
        
        def prepare_file_stucture
          path = Babygitter.report_file_path
          FileUtils.mkdir_p "#{path}/babygitter_images" unless File.exists?("#{path}/babygitter_images")
          FileUtils.cp_r(Babygitter.image_assets_path, "#{path}/asset_images")
        end
        
        def run!(*arguments)
          options = Babygitter::ReportGenerator::Options.new(arguments)          
 
          if options[:show_help]
            $stderr.puts options.opts
            return 1
          end
 
          unless arguments.size == 1
            $stderr.puts options.opts    
            return 1
          end
          
          begin
            if !File.exists?(arguments.first)
              abort "'#{arguments.first}' does not exist."
            elsif !File.directory?(arguments.first)
              abort "'#{arguments.first}' is not a directory."
            end
            Babygitter.repo_path = arguments.first
            prepare_file_stucture
            if options[:verbose]
              $stderr.puts "Repo path set as #{Babygitter.repo_path}"
              $stderr.puts "Repo is bare" if options[:is_bare]
              $stderr.puts "Using whitelist option" if Babygitter.use_whitelist
              unless Babygitter.folder_levels.empty? || Babygitter.folder_levels == [0]
                $stderr.puts "Report will plot #{Babygitter.folder_levels.join(', ')} level"
                $stderr.puts "Report will be generated to #{Babygitter.report_file_path}"
              else
                $stderr.puts "Report will not plot lines committed by folder levels"
              end
            end
            $stderr.puts "Begun generating report."
            generator = Babygitter::ReportGenerator.new(Babygitter.repo_path, :is_bare => options[:is_bare]).write_report
            $stderr.puts "Report written to #{Babygitter.report_file_path}"
            return 0
            
          rescue Grit::InvalidGitRepositoryError
            $stderr.puts "#{Babygitter.repo_path} is not a git repository"
          end
        end
      end

   
    end
  end
end