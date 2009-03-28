require 'gruff'
module Babygitter
  class ReportGenerator < Babygitter::Repo

    THEME = {   # Declare a custom theme
      :colors => %w(orange silver yellow pink purple green white red #cccccc), # colors can be described on hex values (#0f0f0f)
      :font_color => 'white',
      :marker_color => 'white', # The horizontal lines color
      :background_colors => %w(black grey) # you can use instead: :background_image => ‘some_image.png’
    }
    SMALL_SIZE ="183x184"

    def create_histograph_of_commits_by_author_for_branch(branch)
      large_file_path = create_large_histograph_of_commits_by_author_for_branch(branch)
      small_file_path = create_small_histograph_of_commits_by_author_for_branch(branch)
      "<a href='#{large_file_path}' rel='#{branch.name.gsub(/\//, "_")}_gallery' class='image_gallery'><img src=#{small_file_path} alt=''/></a>"

    end

    def create_large_histograph_of_commits_by_author_for_branch(branch)
      g = Gruff::Bar.new('800x400') # Define a custom size
      g.sort = false  # Do NOT sort data based on values
      #g.y_axis_increment = 1  # Points shown on the Y axis
      g.legend_font_size = 12 # Legend font size
      g.title_font_size = 22 # Title font size
      g.theme = THEME
      g.title = 'Commits by Author'
      for author in branch.authors
        g.data("#{author.name}", [author.total_committed])
      end
      file_path = "#{Babygitter.report_file_path}/babygitter_report/babygitter_images/large_#{branch.name.gsub(/\//, "_")}_commits_by_author.png"
      g.write(file_path)
      file_path
    end

    def create_small_histograph_of_commits_by_author_for_branch(branch)
      g = Gruff::Bar.new(SMALL_SIZE) # Define a custom size
      g.sort = false  # Do NOT sort data based on values
      #g.y_axis_increment = 1  # Points shown on the Y axis
      g.hide_legend = true
      g.title_font_size = 32 # Title font size
      g.theme = THEME
      g.title = 'Commits by Author'
      for author in branch.authors
        g.data("#{author.name}", [author.total_committed])
      end
      file_path ="#{Babygitter.report_file_path}/babygitter_report/babygitter_images/small_#{branch.name.gsub(/\//, "_")}_commits_by_author.png"
      g.write(file_path)
      file_path
    end

    def create_stacked_bar_graph_of_commits_by_author_for_branch(branch)
      large_file_path = create_large_stacked_bar_graph_of_commits_by_author_for_branch(branch)
      small_file_path = create_small_stacked_bar_graph_of_commits_by_author_for_branch(branch)
      "<a href='#{large_file_path}' rel='#{branch.name.gsub(/\//, "_")}_gallery' class='image_gallery'><img src=#{small_file_path} alt=''/></a>"
    end

    def create_large_stacked_bar_graph_of_commits_by_author_for_branch(branch)
      g = Gruff::StackedBar.new('800x600') # Define a custom size
      g.sort = true  # Do NOT sort data based on values
      g.y_axis_increment = 10  # Points shown on the Y axis
      g.legend_font_size = 12 # Legend font size
      g.title_font_size = 22 # Title font size
      g.theme = THEME
      g.title = 'Commits for the Last 52 weeks'
      for author in branch.authors
        g.data("#{author.name}", author.create_bar_data_points)
      end
      file_path = "#{Babygitter.report_file_path}/babygitter_report/babygitter_images/large_#{branch.name.gsub(/\//, "_")}_stacked_bar_graph_by_author.png"
      g.write(file_path)
      file_path
    end

    def create_small_stacked_bar_graph_of_commits_by_author_for_branch(branch)
      g = Gruff::StackedBar.new(SMALL_SIZE) # Define a custom size
      g.sort = true  # Do NOT sort data based on values
      g.y_axis_increment = 10  # Points shown on the Y axis
      g.hide_legend = true
      g.title_font_size = 32 #
      g.theme = THEME
      g.title = 'Commits for the Last 52 weeks'
      for author in branch.authors
        g.data("#{author.name}", author.create_bar_data_points)
      end
      file_path = "#{Babygitter.report_file_path}/babygitter_report/babygitter_images/small_#{branch.name.gsub(/\//, "_")}_stacked_bar_graph_by_author.png"
      g.write(file_path)
      file_path
    end

    def create_folder_graph(branch, level)
      small_file_path = create_small_folder_graph(branch, level)
      large_file_path = create_large_folder_graph(branch, level)
      "<a href='#{large_file_path}' rel='#{branch.name.gsub(/\//, "_")}_gallery' class='image_gallery'><img src=#{small_file_path} alt=''/></a>"
    end

    def create_large_folder_graph(branch, level)
      g = Gruff::Line.new('800x600') # Define a custom size
      g.title = "Plot of commits #{pluralize(level, 'level')} deep"
      g.legend_font_size = 12 # Legend font size


      branch.plot_folder_points(level).each do |key,value|
        key = "program_folder" if key == ""
        g.data(key, value)
      end

      file_path = "#{Babygitter.report_file_path}/babygitter_report/babygitter_images/large_#{branch.name.gsub(/\//, "_")}_level_#{level}_line_graph.png"
      g.write(file_path)
      file_path
    end

    def create_small_folder_graph(branch, level)
      g = Gruff::Line.new(SMALL_SIZE) # Define a custom size
      g.title = "Plot of commits #{pluralize(level, 'level')} deep"
      g.legend_font_size = 32 # Legend font size
      g.hide_legend = true
      branch.plot_folder_points(level).each do |key,value|
        key = "program_folder" if key == ""
        g.data(key, value)
      end
      file_path = "#{Babygitter.report_file_path}/babygitter_report/babygitter_images/small_#{branch.name.gsub(/\//, "_")}_level_#{level}_line_graph.png"
      g.write(file_path)
      file_path
    end

    def create_bar_graph_of_commits_in_the_last_52_weeks(author)
      g = Gruff::Bar.new('800x300') # Define a custom size

      g.sort = false  # Do NOT sort data based on values
      #g.y_axis_increment = 1  # Points shown on the Y axis

      g.legend_font_size = 12 # Legend font size
      g.title_font_size = 22 # Title font size

      g.top_margin = 10 # Empty space on the upper part of the chart
      g.bottom_margin = 20  # Empty space on the lower part of the chart

      g.theme = THEME

      g.title = "Commits in the last 52 weeks by #{author.name}"

      g.data("#{author.name}", author.create_bar_data_points)
      g.no_data_message = "No Commits"
      filepath ="#{Babygitter.report_file_path}/babygitter_report/babygitter_images/#{author.name.gsub(/ |\/|\\/, "_")}_commits_last_52_weeks.png"
      g.write(filepath)
      "<img src =#{filepath} />"
    end
  end

end
