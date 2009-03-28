require 'cgi'
module Babygitter
  
  class ReportGenerator < Babygitter::Repo
    
  def authors_list(array_of_authors)
     case array_of_authors.length
     when 1:
       'Only ' + array_of_authors.first + ' has'
     else
       array_of_authors[0..-2].join(', ') + ' and ' + array_of_authors.last + ' have'
     end
   end
   
   def bl(branches_names)
      case branch_names.length
      when 1:
        "<ul class='page_control'>
            <li><a href=##{branch_names.first.gsub(/ /, "")}>#{branch_names.first}</a></li>
         </ul>"
      else
        string = "<ul class='page_control'>" 
         for name in branch_names[0..-2]
            string += "<li><a href=##{name.gsub(/ /, "")}>#{name}</a></li>\n"
         end
          string += "<li>and <a href=##{branch_names.last.gsub(/ /, "")}>#{branch_names.last}</a></li>
        </ul>"
        string
      end
    end

   def branch_details(branches, remote_url)
      branches.map do |branch|
      "<h2 class='toggler open' id='#{branch.name.gsub(/ /, '')}'>#{branch.name}</h2>\n
      <div class='toggle'>\n" +
      image_gallery(branch) +
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
       folder_graphs(branch, Babygitter.folder_levels) +
       "</div>\n"
    end
    
    def branch_synopsis(branch)
      "<p>Last commit was <tt>#{link_to_github?(branch.latest_commit, remote_url)}</tt> by #{branch.latest_commit.author.name} " +
      "on #{branch.latest_commit.date_time_string}</p>
      <p>They have committed a total of #{pluralize(branch.total_commits, "commit", "branches")}</p>" +
      if branch.is_master_branch
      "<p>This is the designated master branch</p>"
      else
        branched_when(branch)
      end
    end
    
    def branched_when(branch)
      if branch.unique_commits.nil?
        "<p>#{branch.name} is a stub with no unique commits </p>"
      else
        "<p>There are #{branch.unique_commits.size} #{branch.unique_commits.size > 1 ? 'unique commits' : 'unique commit'} for this branch</p>"
      end
    end
    
    def show_commits(branch)
      if branch.unique_commits.nil?
        "<ul>
          #{committer_detail(branch.commits, remote_url)}
        </ul>"
      else
        index = branch.commits.map(&:id).index(branch.unique_commits.last.id)
        "<ul class='unique'>
          #{committer_detail(branch.commits[0..index], remote_url)}
        </ul>
        <ul>
          #{committer_detail(branch.commits[index+1..-1], remote_url)}
        </ul>"
      end
    end
   
   def author_details(branch_name, authors, remote_branch, total_for_branch)
     authors.map do |author|
        "<h3 id='#{branch_name}_#{author.name.gsub(/ /, "")}' class='toggler open'>#{author.name}</h3>\n
        <div id='#{author.name}' class='toggle'>\n" +
          create_bar_graph_of_commits_in_the_last_52_weeks(author) +
          "<p>#{author.name} first commit for this branch was on #{author.began.date_time_string} <br />
          They have committed #{pluralize(author.total_committed, "commit")} <br />
          #{author.total_committed.to_f / total_for_branch} of the total for the branch<p>
          <ul>
            #{committer_detail(author.commits, remote_url)}
          </ul>\n
        </div>"
      end.join("\n")
   end
   
   def author_links(branch)
      names =  branch.author_names
      case names.length
      when 1:
        "<ul class='page_control'>
            <li>Only <a href=##{branch.name}_#{names.first.gsub(/ /, "")}>#{names.first}</a> has committed to #{branch.name}</li>
         </ul>"
      else
        "<ul class='page_control'>" + 
          names[0..-2].map do |name|
           "<li><a href=##{branch.name}_#{name.gsub(/ /, "")}>#{name}</a>,</li>"
          end.join("\n") +
           "<li><a href=##{branch.name}_#{names.last.gsub(/ /, "")}>#{names.last}</a> have committed to #{branch.name}</li>
        </ul>"
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