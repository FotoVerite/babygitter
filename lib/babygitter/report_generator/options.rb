module Babygitter
  class ReportGenerator
    class Options < Hash
      attr_reader :opts
 
      def initialize(args)
        super()
 
        @opts = OptionParser.new do |opts|
          opts.banner = "Usage: babygitter #{File.basename($0)}  <Repo_Directory> [options] [-w] [<folder levels>] [<blacklisted or whitelisted folders>]"
        
          opts.separator ""
          opts.separator "Specific options:"

          # Mark folders to be whitelisted or lacklisted
          opts.on("-l", "--levels [n1,n2,n3]",
                  "Folder levels to map to graph", Array) do |levels|  
            Babygitter.folder_levels  = levels.map {|n| n.to_i} unless levels.nil?
          end

          # Mark folders to be whitelisted or lacklisted
          opts.on("-m", "--mark [f1,f2,f3]",
                  "Mark folders to be white or black listed depending on option", Array) do |folders|
            Babygitter.marked_folders  = folders  unless folders.nil?
          end

          # Boolean switch.
          opts.on("-w", "--[no-]whitelist", "Run babygitter with whitelist enabled") do |w|
            Babygitter.use_whitelist = w
          end

          # Boolean switch.
          opts.on("-b", "--[no-]bare", "Mark repo as bare") do |b|
            self[:is_bare] = b
          end

          # Boolean switch.
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

          # Another typical switch to print the version.
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