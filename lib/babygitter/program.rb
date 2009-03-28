require 'cmdparse'
require 'grit'
require File.join(File.dirname(__FILE__), '../babygitter')
require File.join(File.dirname(__FILE__), '../babygitter/author')
require File.join(File.dirname(__FILE__), '../babygitter/branch')
require File.join(File.dirname(__FILE__), '../babygitter/report_generator')


cmd = CmdParse::CommandParser.new( true, true )
cmd.program_name = "babygitter"
cmd.program_version = [0, 5, 0]
cmd.options = CmdParse::OptionParserWrapper.new do |opt|
  opt.separator "Global options:"
  opt.on("--verbose", "Be verbose when outputting info") {|t| $verbose = true }
end

cmd.add_command( CmdParse::HelpCommand.new )
cmd.add_command( CmdParse::VersionCommand.new )
cmd.add_command( CmdParse::FolderListCommand.new )

# babygitter-report
babygitter_report = CmdParse::Command.new( 'babygitter-report', true, true )
babygitter_report.short_desc = "Generate babygitter report"
babygitter_report.set_execution_block do |args|
  puts "Graphing  #{args.join(', ')} levels of the git repository" if $verbose
end
babygitter_report.add_command( levels_deep)
cmd.add_command( babygitter_report )

# ipaddr repo-path
repo_path = CmdParse::Command.new( 'repo-path', false )
repo_path.short_desc = "designate path to git repository"
repo_path.set_execution_block do |args|
  puts "Git repository path is #{args}" if $verbose
  Babygitter.repo_path = args
end
babygitter_report.add_command( repo_path )

# ipaddr whitelist
whitelist = CmdParse::Command.new( 'whitelist', false )
whitelist.short_desc = "Turn on whitelist option for folder and branch selection"
whitelist.options = CmdParse::OptionParserWrapper.new do |opt|
  opt.on( '-w', '--whitelist', 'Whitelist option on' ) { $whiteList = true }
whitelist.set_execution_block do |args|
  puts "Using whitelist option" if $verbose
  Babygitter.whitelist = true
end
babygitter_report.add_command( whitelist )

# ipaddr list
branches = CmdParse::Command.new( 'branches', false )
branches.short_desc = "Blacklist or whitelist branches"
branches.set_execution_block do |args|
  puts "#{$whiteList ? "Whitelisting" : "Blacklisting"} #{args.join(', ')}" if $verbose
  Babygitter.blacklisted_folders = args
end
babygitter_report.add_command( branches)

levels_deep = CmdParse::Command.new( 'levels-deep', false )
levels_deep.short_desc = "Levels to graph for repository default to 1"
levels_deep.set_execution_block do |args|
  puts "Graphing  #{args.join(', ')} levels of the git repository" if $verbose
  Babygitter.blacklisted_folders = args
end
babygitter_report.add_command( levels_deep)





end