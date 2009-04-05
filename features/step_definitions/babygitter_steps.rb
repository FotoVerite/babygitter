Given 'a project directory' do
  @project_dir = File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'spec/simple_git_repo.git')
  FileUtils.rm_rf "#{@project_dir}/log"
  @options = nil
  #default babygitter_options
  Babygitter.repo_path = '.'
  Babygitter.stylesheet = File.join(File.dirname(__FILE__), '../../lib/babygitter/assets/stylesheets/default.css')
  Babygitter.image_assets_path = File.join(File.dirname(__FILE__), '../../lib/babygitter/assets/image_assets')
  Babygitter.jquery = File.join(File.dirname(__FILE__), '../../lib/babygitter/assets/javascripts/jquery.js')
  Babygitter.template = File.join(File.dirname(__FILE__), '../../lib/babygitter/assets/templates/default.html.erb')
  Babygitter.additional_links = File.join(File.dirname(__FILE__), '../../lib/babygitter/assets/guides/bdd_stack.html.erb')
  Babygitter.instructions = File.join(File.dirname(__FILE__), '../../lib/babygitter/assets/guides/display_only.html.erb')
  Babygitter.use_whitelist = false
  Babygitter.folder_levels = [1]
  Babygitter.marked_folders = []
end

Given /^a project directory that is not a git directory$/ do
@project_dir = File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'spec/')
end

Then /^I use the options* '(.*?)'$/ do |options|
  @options = options.split(', ')
end

When /^I generate a report for '((?:\w|-|_)+)'/ do |repo_path|
  @repo_path = repo_path

  arguments = ["#{@project_dir}",
              @options
              ].flatten.compact
  @stdout = OutputCatcher.catch_out do
    Babygitter::ReportGenerator::Application.run! *arguments
  end
  
  @stderr = OutputCatcher.catch_err do
     Babygitter::ReportGenerator::Application.run! *arguments
   end
end

Then /^a directory named '(.*)' is created$/ do |directory|
  directory = File.join(@project_dir, directory)

  assert File.exists?(directory), "#{directory} did not exist"
  assert File.directory?(directory), "#{directory} is not a directory"
end

Then /^a file named '(.*)' is created$/ do |file|
  file = File.join(@project_dir, file)

  assert File.exists?(file), "#{file} expected to exist, but did not"
  assert File.file?(file), "#{file} expected to be a file, but is not"
end

Then /^'(.*?)' is displayed$/ do |sentence|
  assert_match "#{sentence}", @stdout
end

Then /^'(.*?)' error is displayed$/ do |sentence|
  assert_match "#{sentence}", @stderr
end

Then /^'(.*?)' is not displayed$/ do |sentence|
  assert_no_match Regexp.new(sentence), @stdout 
end

Then /^the generater is using the whitelist option$/ do
  assert_equal Babygitter.use_whitelist, true
end

Then "the version number is shown" do
  refs = open(File.join(File.dirname(__FILE__), '../../VERSION.yml')) {|f| YAML.load(f) }
  assert_equal "Babygitter Version #{refs[:major]}.#{refs[:minor]}.#{refs[:patch]}\n", @stdout
end

Then "a babygitter report is generated" do
  Then "a directory named 'log' is created"
  Then "a directory named 'log/babygitter_report' is created"
  Then "a directory named 'log/babygitter_report/babygitter_images' is created"
  Then "a directory named 'log/babygitter_report/asset_images' is created"
	Then "a file named 'log/babygitter_report/babygitter_report.html' is created"
	#check if the images are being generated
	Then "a file named 'log/babygitter_report/babygitter_images/small_master_stacked_bar_graph_by_author.png' is created"
	Then "a file named 'log/babygitter_report/babygitter_images/small_master_level_1_line_graph.png' is created"
end

Then "a babygitter report is generated without folder graphs" do
  Then "a directory named 'log' is created"
  Then "a directory named 'log/babygitter_report' is created"
  Then "a directory named 'log/babygitter_report/babygitter_images' is created"
  Then "a directory named 'log/babygitter_report/asset_images' is created"
	Then "a file named 'log/babygitter_report/babygitter_report.html' is created"
	Then "a file named 'log/babygitter_report/babygitter_images/small_master_stacked_bar_graph_by_author.png' is created"
	#check if the images are being generated
end

And /^Folder levels equal '(.*)'$/ do |levels|
  assert_equal Babygitter.folder_levels, levels.split(',').map {|n| n.to_i}
end

And /^Marked folders equal '(.*)'$/ do |folders|
  assert_equal Babygitter.marked_folders, folders.split(', ')
end