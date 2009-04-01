require 'cgi'
module Babygitter

 class ReportGenerator < Babygitter::Repo
  
  #Pluralizes the authors of a branch in a readable and gramatically correct manner 
  #
  #authors_list([Matt, Allen]) => Matt and allen have
  #authors_list([Matt]) => Only Matt has
  def authors_list(array_of_authors)
     case array_of_authors.length
     when 1:
       'Only ' + array_of_authors.first + ' has'
     else
       array_of_authors[0..-2].join(', ') + ' and ' + array_of_authors.last + ' have'
     end
   end
   
   #Pluralizes the branches in a XHTML correct manner with links to the branch headers
   def branch_names_list(branches_names)
      case branch_names.length
      when 1:
        "<ul class='page_control'>
            <li><a href=##{branch_names.first.gsub(/ /, "")}>#{branch_names.first}</a></li>\n</ul>"
      else
        string = "<ul class='page_control'>" 
         for name in branch_names[0..-2]
            string += "<li><a href=##{name.gsub(/ /, "")}>#{name}</a></li>\n"
         end
          string += "<li>and <a href=##{branch_names.last.gsub(/ /, "")}>#{branch_names.last}</a></li>\n</ul>"
        string
      end
    end
    
    #Output the git repo's branches details  in a XHTML correct manner 
   def branch_details(branches, remote_url)
      branches.map do |branch|
      "<h2 class='toggler open' id='#{branch.name.gsub(/ /, '')}'>#{branch.name}</h2>\n
      <div class='toggle'>\n" +
      if Babygitter.output_graphs
        image_gallery(branch) 
      else
        "" 
      end +
      "<div class='branch_details'>\n" +
      author_links(branch) +
      branch_synopsis(branch) +
      "<h3 class='toggler open'>#{branch.name} commit history</h3>
      <div class='toggle'>"+
      show_commits(branch) +
      "</div>" +
      author_details(branch.name, branch.authors, remote_url, branch.total_commits) +
      "</div>\n
      </div>"
      end.join("\n")
    end
    
    def image_gallery(branch)
      "<div class='image_gallery'>\n" +
      create_histograph_of_commits_by_author_for_branch(branch) + "\n" +
      create_stacked_bar_graph_of_commits_by_author_for_branch(branch) + "\n" +
      unless Babygitter.folder_levels.empty? || Babygitter.folder_levels == [0]
        folder_graphs(branch, Babygitter.folder_levels)
      else
        "" 
      end +
      "</div>\n"
    end
    
    def branch_synopsis(branch)
      "<p>Last commit was <tt>#{link_to_github?(branch.latest_commit, remote_url)}</tt> by #{branch.latest_commit.author.name} " +
      "on #{branch.latest_commit.date_time_string}</p>\n" +
      "<p>They have committed a total of #{pluralize(branch.total_commits, "commit", "branches")}</p>\n
      #{"<p>This is the designated master branch</p>\n"  if branch.is_master_branch }" +
      "<p>There are #{branch.unique_commits.size} #{branch.unique_commits.size == 1 ? 'unique commits' : 'unique commit'} for this branch</p>"
      "<p>#{branch.name} branched at <a href='##{branch.name}_branched_here'>#{branch.branched_at.id_abbrev}</a></p>"
    end
    
    def show_commits(branch)
      "<ul>
        #{branch_committer_detail(branch, branch.commits, remote_url)}
      </ul>"
    end
   
   def author_details(branch_name, authors, remote_branch, total_for_branch)
     authors.map do |author|
        "<h3 id='#{branch_name}_#{author.name.gsub(/ /, "")}' class='toggler open'>#{author.name}</h3>\n
        <div id='#{author.name}' class='toggle'>\n" +
          create_bar_graph_of_commits_in_the_last_52_weeks(author) +
          "<p>#{author.name} first commit for this branch was on #{author.began.date_time_string} <br />
          They have committed #{pluralize(author.total_committed, "commit")} <br />
          #{amount_committed_to_total(author, total_for_branch)} of the total for the branch<p>
          <ul>
            #{committer_detail(author.commits, remote_url)}
          </ul>\n
        </div>"
      end.join("\n")
   end

   def amount_committed_to_total(author, total_for_branch)
     ((author.total_committed.to_f / total_for_branch)*100.round)/100
   end
   def author_links(branch)
      names =  branch.author_names
      case names.length
      when 1:
        "<ul class='page_control'>\n" +
        "<li>Only <a href=##{branch.name}_#{names.first.gsub(/ /, "")}>#{names.first}</a> has committed to #{branch.name}</li>\n" +
        "</ul>"
      else
        "<ul class='page_control'>" + 
        names[0..-2].map do |name|
          "<li><a href=##{branch.name}_#{name.gsub(/ /, "")}>#{name}</a>,</li>"
        end.join("\n") +
        "\n<li><a href=##{branch.name}_#{names.last.gsub(/ /, "")}>#{names.last}</a> have committed to #{branch.name}</li>\n" +
        "</ul>"
      end
   end
   
   def folder_graphs(branch, levels)
     string = ""
     for level in levels   
       string += create_folder_graph(branch, level) + "\n"
     end
     string
   end
    
   def committer_detail(commits, remote_url)
      commits.map do |c|
        '<li>' + CGI::escapeHTML(c.message) + 
        ' <cite>' + c.author.name + ' ' +
        c.date_time_string + 
        '</cite> ' + link_to_github?(c, remote_url)+ '</li>'
      end.join("\n")
    end
    
    def commit_classes(branch, commit)
      return "unique" if branch.unique_commits != nil && branch.unique_commits.map(&:id).include?(commit.id)
      return "branched" if branch.branched_at.id == commit.id
    end
    
    def branch_committer_detail(branch, commits, remote_url)
      commits.map do |c|
        "<li id='#{branch.name + '_branched_here' if c.id == branch.branched_at.id}' class=#{commit_classes(branch, c)}>" + CGI::escapeHTML(c.message) + 
        ' <cite>' + c.author.name + ' ' +
        c.date_time_string + 
        '</cite> ' + link_to_github?(c, remote_url)+ '</li>'
      end.join("\n")
    end
    
    def link_to_github?(commit, remote_url)
      remote_url == "" ? "<tt>#{commit.id_abbrev}</tt>" : 
      "<tt><strong><a href='#{remote_url}/commit/#{commit.id}'>#{commit.id_abbrev}</a></strong></tt>"
    end
    
    def pluralize(count, singular, plural = nil)
       "#{count || 0} " + if count == 1 || count == '1'
        singular
      elsif plural
        plural
      elsif Object.const_defined?("Inflector")
        Inflector.pluralize(singular)
      else
        singular + "s"
      end
    end
   
   end
end