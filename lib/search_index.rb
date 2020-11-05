require 'json'
require 'open-uri'
require 'bundler/setup'
require 'execjs'
require 'nokogiri'

require_relative "search_index_document"

module RailsGuides
  class SearchIndex
    def initialize
      guides_dir = File.expand_path('..', __dir__)
      @output_dir = "#{guides_dir}/output/pt-BR"
      guides_to_generate = Dir.entries("#{guides_dir}/pt-BR").grep(/\.(?:erb|md)\z/)
      @guides = guides_to_generate.reject { |guide| guide.end_with?(".erb")  }
                                  .map    { |guide| guide.gsub(".md", ".html") }
      @site_dir = "#{guides_dir}/site"
    end

    def generate
      documents = @guides.map do |guide|
        generate_documents(guide)
      end.flatten

      generate_index(documents)
    end

    private
    def generate_documents(guide)
      body = File.read(@output_dir + "/" + guide)

      sections = []
      current_section = nil
      heading = nil

      Nokogiri::HTML.fragment(body).tap do |doc|
        puts "Generating search index for #{guide}"
        title = doc.at_css("h2").text

        doc.at_css("#mainCol").children.each do |node|
          case node.name
          when "h3"
            heading = node.text
          when "h4"
            sections << current_section
            link = node.at_css("a")
            next if link.nil?
            anchor = link["href"]
            current_section = SearchIndexDocument.new(guide, anchor, title, heading, node.text)
          when "p"
            current_section = SearchIndexDocument.new(guide, anchor, title, heading, heading) if current_section.nil?
            current_section.append_line(node.text)
          end
        end
      end
      sections << current_section
      sections.compact
    end

    def generate_index(documents)
      link_map = {}
      documents.map.each_with_index do |document, index|
        link_map[index] = document.id
        document.id = index
        document
      end

      documents_js = "var lunrDocuments = #{documents.to_json};"
      link_map_js = "var linkMap = #{link_map.to_json};"
      File.write("#{@site_dir}/javascripts/lunr-documents.js", documents_js + link_map_js)

      root = File.expand_path(".", __dir__)
      lunr = File.read("#{@site_dir}/javascripts/lunr.js")
      lunr_indexer = File.read("#{root}/lunr-indexer.js")
      lunr_index = ExecJS.eval("(function() {" + lunr + documents_js + lunr_indexer + "})()")
      file_content = "var lunrIndexData = #{lunr_index};"
      File.write("#{@site_dir}/javascripts/lunr-index.js", file_content)
    end
  end
end
