module Babygitter
  class ReportGenerator
    class Application
      
      class << self
        
        def prepare_file_stucture
          path = Babygitter.report_file_path
          FileUtils.mkdir_p "#{path}/babygitter_images" unless File.exists?("#{path}/babygitter_images")
          FileUtils.cp_r("#{Babygitter.image_assets_path}" + "/.", "#{path}/asset_images/")
        end
        
        def level_sentence
          if Babygitter.folder_levels.size > 1 
            'levels ' +
            Babygitter.folder_levels[0..-2].map do |level|
            "#{level}"
            end.join(", ") + " and #{Babygitter.folder_levels.last}"
          else 
            "level #{Babygitter.folder_levels.first}"
          end
        end
        
        def verbose_output(options)
          $stdout.puts "Repo path set as #{Babygitter.repo_path}"
          $stdout.puts "Repo is bare" if options[:is_bare]
          $stdout.puts "Using whitelist option" if Babygitter.use_whitelist
          unless Babygitter.folder_levels.empty? || Babygitter.folder_levels == [0]
            $stdout.puts "Report will plot folder #{level_sentence}"
          else
            $stdout.puts "Report will not plot lines committed by folder levels"
          end
          $stdout.puts "Report will be generated to #{Babygitter.report_file_path}"
        end
        
        def check_if_directory_exits(arguments)
          if !File.exists?(arguments.first)
            abort "'#{arguments.first}' does not exist."
          elsif !File.directory?(arguments.first)
            abort "'#{arguments.first}' is not a directory."
          end
        end
        
        def run!(*arguments)
          options = Babygitter::ReportGenerator::Options.new(arguments)          
          
          if options[:show_help]
            $stderr.puts options.opts
            return 1
          end
          
          if options[:show_version_number]
            refs = open(File.join(File.dirname(__FILE__), '../../../VERSION.yml')) {|f| YAML.load(f) }
            $stdout.puts "Babygitter Version #{refs[:major]}.#{refs[:minor]}.#{refs[:patch]}"  
            return 1
          end
          
          unless arguments.size == 1
            $stderr.puts options.opts    
            return 1
          end
          
          begin
            check_if_directory_exits(arguments)
            Babygitter.repo_path = arguments.first
            if options[:verbose]
              verbose_output(options)
            end
            generator = Babygitter::ReportGenerator.new(Babygitter.repo_path, {:is_bare => options[:is_bare]}, options[:master_branch])
            prepare_file_stucture
            $stdout.puts "Begun generating report."
            generator.write_report
            $stdout.puts "Report written to #{Babygitter.report_file_path}"
            return 0
          rescue Grit::InvalidGitRepositoryError
            $stderr.puts "#{Babygitter.repo_path} is not a git repository"
            return 1
          end
        end
      end

   
    end
  end
end