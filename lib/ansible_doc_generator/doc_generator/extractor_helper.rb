# frozen_string_literal: true

module AnsibleDocGenerator
  class DocGenerator
    module ExtractorHelper

      def extract_from keyword, lines
        line = lines.find{|line| selectable_line?(keyword, line) }
        clean_line(keyword, line)
      end

      # - a comment, for instance, can be in several lines and only the first one will have the keyword.
      # - if a new "@comment" appear, it's a new comment
      # - this method always return an array, but some keywords like input or output will only use one item
      def extract_multiline_from keyword, lines, separator: ' '
        collection = []     # collection of @keyword with maybe several lines
        current_item = []   # current @keyword that will change through the loop
        current_keyword = nil

        lines.each do |line|
          # It's the beginning of a comment
          if selectable_line?(keyword, line)
            current_keyword = keyword
            # we save the previous comment before parsing the new one
            if current_item.any?
              collection << join_elements(current_item, separator)
              current_item = []
            end
            current_item << clean_line(current_keyword, line)
          # If it's another keyword but not relevant, we store current comment. But we keep the loop in case there are others
          elsif line.start_with?("@") && !selectable_line?(keyword, line) && current_item.any?
            collection << join_elements(current_item, separator)
            current_item = []
          # It's the second/third... line of a comment
          elsif current_item.any? && !line.start_with?('@')
            current_item << clean_line(current_keyword, line)
          end
        end

        collection << join_elements(current_item, separator) if current_item.any?

        collection
      end

      def selectable_line?(keyword, line)
        line.start_with?("@#{keyword}_#{lang}") || (line.start_with?("@#{keyword}") && !line.start_with?("@#{keyword}_"))
      end

      def clean_line(keyword, line)
        return nil unless line

        no_keyword_line = line.gsub(/@#{keyword}_#{lang}|@#{keyword}/, '')
        if %w(input output).include?(keyword)
          no_keyword_line
        else
          no_keyword_line.strip
        end
      end

      def join_elements elements, separator
        elements.reject{|line| line.strip == '' || line.nil? }.join(separator)
      end

    end
  end
end
