module Babygitter
  class ReportGenerator
    class Options < Hash
      attr_reader :opts
      
      def check_if_directory_exits(path)
        if !File.exists?(path)
          abort "'#{path}' does not exist."
        elsif !File.directory?(path)
          abort "'#{path}' is not a directory."
        end
      end
      
      def check_if_file_exits(path)
        if !File.exists?(path)
          abort "'#{path}' does not exist."
        elsif File.directory?(path)
          abort "'#{path}' is a directory."
        end
      end
 
      def initialize(args)
        super()
 
        @opts = OptionParser.new do |opts|
          opts.banner = "Usage: babygitter #{File.basename($0)}  <Repo_Directory> [options] [-w] [<folder levels>] [<blacklisted or whitelisted folders>]"
        
          opts.separator ""
          opts.separator "Specific options:"

          # Set folder levels to be plotted
          opts.on("-l", "--levels [n1,n2,n3]",
                  "Folder levels to map to graph", Array) do |levels|  
            Babygitter.folder_levels  = levels.map {|n| n.to_i}.sort unless levels.nil?
          end

          # Mark folders to be whitelisted or lacklisted
          opts.on("-m", "--mark [f1,f2,f3]",
                  "Mark folders to be white or black listed depending on option", Array) do |folders|
            Babygitter.marked_folders  = folders  unless folders.nil?
          end
          
          # Set the name of the master branch
          opts.on("--master_branch",
                  "Set the master branch name if it is not called master") do |master_branch|
            self[:master_branch] = master_branch
          end
          
          # Set the stylesheet
          opts.on("-s", "--stylesheet [Path]",
                  "sets the path to a custome stylesheet used in the  report generator") do |path|
            expanded_path = File.expand_path path
            check_if_file_exits(expanded_path)
            Babygitter.stylesheet = expanded_path
          end
          
          # Set the stylesheet
          opts.on("-i", "--image_path [Path]",
                  "sets the path to a custome image folder to be used in the report generator") do |path|
            expanded_path = File.expand_path path
            check_if_directory_exits(expanded_path)
            Babygitter.image_assets_path = File.expand_path path
          end
          
          # Set a custome template
          opts.on("-t", "--template [Path]",
                  "sets the path to a custome template to be used in the report generator") do |path|
            expanded_path = File.expand_path path
            check_if_file_exits(expanded_path)
            Babygitter.template = File.expand_path path
          end
          
          # Boolean switch.
          opts.on("-b", "--[no-]bare", "Mark repo as bare") do |b|
            self[:is_bare] = b
          end

          # Boolean switch.for whitelist
          opts.on("-w", "--[no-]whitelist", "Run babygitter with whitelist enabled") do |w|
            Babygitter.use_whitelist = w
          end

          # Boolean switch for graphs.
          opts.on("-g", "--[yes-]graphs", "Do not output report with graphs") do 
            Babygitter.output_graphs = false
          end
          
          # Boolean switch for application to run verbosely.
          opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
            self[:verbose] = v
          end

          opts.separator ""
          opts.separator "Common options:"

          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          opts.on_tail("-h", "--help", "Show this message") do
            self[:show_help] = true
          end

          # Switch to print the version.
          opts.on_tail("--version", "Show version number") do
            self[:show_version_number] = true
          end
        end
        
        begin
          @opts.parse!(args)
        rescue OptionParser::ParseError => e
          warn e.message
          puts opts
          exit 1
        end
        
      end
    end
  end
end