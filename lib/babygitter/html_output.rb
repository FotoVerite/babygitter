require 'cgi'
require 'markaby'
  
module Babygitter

  module HtmlOutput

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
    def branch_names_list(branch_names)
      markaby do
        ul.page_control do
          case branch_names.length
          when 1:
            li do
              a branch_names.first, :href => "##{branch_names.first.underscore}"
            end
          else
            for name in branch_names[0..-2]
              li do
                a name, :href => "##{name.underscore}"
              end
            end
          end
        end
      end
    end

    #Output the git repo's branches details  in a XHTML correct manner
    def branch_details(branches, remote_url)
      markaby do
        branches.map do |branch|
          h2.toggler.open branch.name, :id => branch.name.gsub(/ /, '')
          div.toggle.branch do
            image_gallery(branch) if Babygitter.output_graphs
            div.branch_details do
              author_links(branch)
              branch_synopsis(branch)
              h3.toggler.open "#{branch.name} commit history"
              div.toggle do
                ul do
                  branch_committer_detail(branch, branch.commits, remote_url)
                end
              end
              author_details(branch.name, branch.authors, remote_url, branch.total_commits)
            end
          end
        end
      end
    end

    def image_gallery(branch)
      markaby do
        div.image_gallery do
          create_histograph_of_commits_by_author_for_branch(branch) + "\n" +
          create_stacked_bar_graph_of_commits_by_author_for_branch(branch) + "\n" +
          unless Babygitter.folder_levels.empty? || Babygitter.folder_levels == [0]
            Babygitter.folder_levels.map do |level|
              create_folder_graph(branch, level)
            end.join("\n")
          else
            ""
          end
        end
      end
    end

    def branch_synopsis(branch)
      markaby do
        p { "Last commit was " + link_to_github?(branch.latest_commit, remote_url) +
            " by #{branch.latest_commit.author.name} on #{branch.latest_commit.date_time_string}"
          }
        p "They have committed a total of #{pluralize(branch.total_commits, "commit", "commits")}"
        p "This is the designated master branch" if branch.is_master_branch
        p "There are #{branch.unique_commits.size} #{branch.unique_commits.size == 1 ? 'unique commits' : 'unique commit'} for this branch"
        p {"#{branch.name} branched at " + a(branch.branched_at.id_abbrev, :href => "##{branch.name}_branched_here")}
      end
    end

    def author_details(branch_name, authors, remote_branch, total_for_branch)
      markaby do
        authors.map do |author|
          h3.toggler.open author.name, :id => "#{branch_name}_#{author.name.underscore}"
          div.toggle :id => author.name do
            create_bar_graph_of_commits_in_the_last_52_weeks(author)
            p "#{author.name} first commit for this branch was on #{author.began.date_time_string}"
            p "They have committed #{pluralize(author.total_committed, "commit")}"
            p "#{amount_committed_to_total(author, total_for_branch)} of the total for the branch"
            ul do
              committer_detail(author.commits, remote_url)
            end
          end
        end
      end
    end

    def amount_committed_to_total(author, total_for_branch)
      ((author.total_committed.to_f / total_for_branch)*100.round)/100
    end

    def author_links(branch)
      names =  branch.author_names
      markaby do
        ul.page_control do
          case names.length
          when 1:
            li {"Only " + a(names.first, :id => "##{branch.name}_#{names.first.underscore}") + " has committed to #{branch.name}"  }
          else
            names[0..-2].map do |name|
              li { a(name, :id =>"##{branch.name}_#{name.underscore}") + ","}
            end
            li {" and " + a(names.first, :id => "##{branch.name}_#{names.last.underscore}") + " have committed to #{branch.name}"  }
          end
        end
      end
    end

    def committer_detail(commits, remote_url)
      markaby do
        commits.map do |commit|
          li { CGI::escapeHTML(commit.message) +
            cite("#{commit.author.name} #{commit.date_time_string}") +
          link_to_github?(commit, remote_url) }
        end
      end
    end

    def commit_classes(branch, commit)
      return "unique" if branch.unique_commits != nil && branch.unique_commits.map(&:id).include?(commit.id)
      return "branched" if branch.branched_at.id == commit.id
    end

    def branch_committer_detail(branch, commits, remote_url)
      markaby do
        commits.map do |commit|
          li :id => commit_id_class(branch, commit), :class => commit_classes(branch, commit) do
            CGI::escapeHTML(commit.message) +
            cite("#{commit.author.name} #{commit.date_time_string}") +
            link_to_github?(commit, remote_url)
          end
        end
      end
    end

    def commit_id_class(branch, commit)
      if commit.id == branch.branched_at.id
        "#{branch.name}_branched_here"
      else
        branch.name + "_" + commit.id
      end
    end

    def link_to_github?(commit, remote_url)
      remote_url == "" ? "<tt>#{commit.id_abbrev}</tt>" :
      "<tt><strong><a href='#{remote_url}/commit/#{commit.id}'>#{commit.id_abbrev}</a></strong></tt>"
    end

    def pluralize(count, singular, plural = nil)
      "#{count || 0} " +
      if count == 1 || count == '1'
        singular
      elsif plural
        plural
      elsif Object.const_defined?("Inflector")
        Inflector.pluralize(singular)
      else
        singular + "s"
      end
    end

    def markaby(&block)
      Markaby::Builder.set(:indent, 2)
      Markaby::Builder.new({}, self, &block).to_s
    end
    
  end
end
