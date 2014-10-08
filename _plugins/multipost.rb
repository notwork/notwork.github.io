module Jekyll
  class MultiPost < Post

    # Initialize this MultiPost instance.
    #
    # site       - The Site.
    # base       - The String path to the dir containing the post file.
    # name       - The String filename of the post file.
    # layout     - The layout to use for the post.
    #
    # Returns the new Post.
    def initialize(site, source, dir, name, layout)
      @site = site
      @dir = dir
      @base = self.containing_dir(source, dir)
      @name = name

      self.categories = dir.downcase.split('/').reject { |x| x.empty? }
      self.process(name)
      self.read_yaml(@base, name)

      # Declare the layout for this instance
      self.data["layout"] = layout

      # Declare the unique permalink for this instance
      title = CGI.escape(slug)

      if self.data.has_key?('date')
        self.date = Time.parse(self.data["date"].to_s)
      end

      self.populate_categories
      self.populate_tags

      if layout == "mailchimp"
        self.data["permalink"] = "/mailchimp/#{name}"
      end
    end
  end

  class MultiPostGenerator < Generator
    safe true

    def generate(site)
      site.posts.each do |post|
        if post.data["layout"] == "newsletter"
          site.posts << MultiPost.new(site, site.source, "", post.name, "mailchimp")
        end
      end
    end
  end
end
