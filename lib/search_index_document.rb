module RailsGuides
  class SearchIndexDocument
    NUMBER_RE = /^\d+\.?\d*$/
    MIN_WORD_LENGTH = 4

    attr_accessor :id

    def initialize(guide, anchor, title, heading, subheading)
      @id = "#{guide}#{anchor}"
      @title = title
      @heading = heading
      @subheading = subheading
      @lines = []
    end

    def append_line(line)
      filtered = (line.downcase.split - stop_words)
        .map { |word| word.strip  }
        .reject { |word| word.length < MIN_WORD_LENGTH  }
        .reject { |word| word =~ NUMBER_RE  }
        .join(" ")
      @lines << filtered
    end

    def to_json(*args)
      {
        id: @id,
        title: @title,
        heading: @heading,
        subheading: @subheading,
        content:  @lines.join(" ")

      }.to_json(*args)
    end

    private
      def stop_words
        # tr -c '[:alnum:]' '[\n*]' < pt-BR/getting_started.md | sort | uniq -c | sort -nr | head -20
        %w( o de a para que um do da e em uma )
      end
  end
end
