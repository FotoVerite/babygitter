Feature: generating babygitter report
  In order to generate a babygitter report
  As a user 
  I want to use the command line with various options

  Scenario: basic report no options
   	Given a project directory
    When I generate a report for 'babygitter' 
    Then a directory named 'log' is created
    And a directory named 'log/babygitter_report' is created
    And a directory named 'log/babygitter_report/babygitter_images' is created
    And a directory named 'log/babygitter_report/asset_images' is created

	And a file named 'log/babygitter_report/babygitter_report.html' is created
	#check if the images are being generated
	And a file named 'log/babygitter_report/babygitter_images/small_master_level_1_line_graph.png' is created
	Then a file named 'log/babygitter_report/babygitter_images/small_master_stacked_bar_graph_by_author.png' is created
	Then 'Begun generating report.' is displayed
	And 'Report written to' is displayed
	
  Scenario: basic report with verbose turned on
	Given a project directory
	And I use the option '-v' 
    When I generate a report for 'babygitter' 
    Then a babygitter report is generated
	And 'Repo path set as' is displayed
	And 'Report will plot folder level 1' is displayed
	And 'Report will be generated to' is displayed
	And 'Using whitelist' is not displayed
	And 'Repo is bare' is not displayed
	And 'Report will not plot lines committed by folder levels' is not displayed
	
  Scenario: basic report with verbose turned on and bare
	Given a project directory
	And I use the options '--verbose, --bare' 
    When I generate a report for 'babygitter' 
    Then a babygitter report is generated
	And 'Repo path set as' is displayed
	And 'Report will plot folder level 1' is displayed
	And 'Report will be generated to' is displayed
	And 'Using whitelist' is not displayed
	And 'Repo is bare' is displayed
	And 'Report will not plot lines committed by folder levels' is not displayed
	
  Scenario: basic report with verbose turned on and using whitelist
	Given a project directory
	And I use the options '--verbose, --whitelist' 
	When I generate a report for 'babygitter' 
	Then a babygitter report is generated
	And the generater is using the whitelist option
	And 'Repo path set as' is displayed
	And 'Report will plot folder level 1' is displayed
	And 'Report will be generated to' is displayed
	And 'Using whitelist' is displayed
	And 'Repo is bare' is not displayed
	And 'Report will not plot lines committed by folder levels' is not displayed
	
Scenario: basic report with verbose turned on and using custom levels
	Given a project directory
	And I use the options '--verbose, --levels, 1,2' 
	When I generate a report for 'babygitter' 
	Then a babygitter report is generated	
	And 'Repo path set as' is displayed
	And 'Report will plot folder levels 1 and 2' is displayed
	And 'Report will be generated to' is displayed
	And 'Using whitelist' is not displayed
	And 'Repo is bare' is not displayed
	And 'Report will not plot lines committed by folder levels' is not displayed
	And Folder levels equal '1,2'
	
Scenario: basic report with verbose turned on with no folders graphs
	Given a project directory
	And I use the options '--verbose, --levels, 0' 
	When I generate a report for 'babygitter' 
	Then a babygitter report is generated without folder graphs
	And 'Repo path set as' is displayed
	And 'Report will be generated to' is displayed
	And 'Using whitelist' is not displayed
	And 'Repo is bare' is not displayed
	And 'Report will not plot lines committed by folder levels' is displayed
	And Folder levels equal '0'
	
Scenario: basic report with and marked folders
	Given a project directory
	And I use the options '--verbose, --mark, app,public' 
	When I generate a report for 'babygitter' 
	Then a babygitter report is generated
	And Marked folders equal 'app, public'
	
Scenario: user wants to show the gem version
	Given a project directory
	And I use the options '--version' 
	When I generate a report for 'babygitter' 	
	Then the version number is shown

Scenario: user inputs a nonexistent project directory
	Given a project directory that doesn't exist
	When I generate a report for 'babygitter'
	Then '.* does not exist.' is displayed

Scenario: user inputs a non-git directory
	Given a project directory that is not a git director
	When I generate a report for 'babygitter'
	Then '.* does not exist.' is displayed
