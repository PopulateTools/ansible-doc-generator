# frozen_string_literal: true

require_relative "variable_interpolator"

module AnsibleDocGenerator
  class DocGenerator
    class RoleDocExtractor
      attr_reader :yml_path, :lang
      attr_accessor :parsed_content, :md_output

      META_KEYWORDS = %w(metatitle)

      def initialize yml_path, lang
        @yml_path = yml_path
        @lang = lang
        @parsed_content = {'meta' => []}
        @md_output = []
      end

      def call
        parse_file_comments
        generate_meta_content
        generate_tasks_content

        join_elements(md_output, "\n\n")
      end

      private

      # Extract relevant lines from the file and group them by task
      def parse_file_comments
        file = File.open(yml_path)
        current_comments = []
        file.each do |line|
          if line.start_with?('#') && META_KEYWORDS.any?{|keyword| line.start_with?("# @#{keyword}") }
            parsed_content['meta'] << line.gsub('# ', '').strip
          elsif line.start_with?('#')
            current_comments << line.gsub('# ', '').strip
          elsif line.start_with?('- name:')
            task_name = line.gsub('- name:','').strip
            parsed_content[task_name] = current_comments
            current_comments = []
          end
        end and nil
        file.close
      end

      def generate_meta_content
        return if parsed_content['meta'].nil?
        metatitle = extract_from(:metatitle, parsed_content['meta'])
        return if metatitle.nil?

        md_output << "## #{metatitle}"
      end

      # Parse previously extracted lines and separated them by keyword
      def generate_tasks_content
        parsed_content.each do |task_name, lines|
          title = extract_from(:title, lines)
          next if title.nil?

          output = extract_multiline_from(:output, lines, separator: "\n").first
          input = extract_multiline_from(:input, lines, separator: "\n").first
          comments = extract_multiline_from(:comment, lines)

          md_output << generate_md_with(task_name, title: title, comments: comments, output: output, input: input)
        end
      end

      def generate_md_with task_name, params
        temp_md = ["### #{params[:title]}"]
        params.fetch(:comments, []).each{|comment| temp_md << comment }
        temp_md << "Input: \n\n```\n#{params[:input]}\n```" if params[:input]
        temp_md << "Expected output: \n\n```\n#{params[:output]}\n```" if params[:output]

        non_interpolated_output = join_elements(temp_md, "\n\n")
        task = tasks.find{|task| task['name'] == task_name}
        VariableInterpolator.new(non_interpolated_output, task).call
      end

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

        lines.each do |line|
          # It's the beginning of a comment
          if selectable_line?(keyword, line)
            # we save the previous comment before parsing the new one
            if current_item.any?
              collection << join_elements(current_item, separator)
              current_item = []
            end
            current_item << clean_line(keyword, line)
            # If it's another keyword but not relevant, we store current comment. But we keep the loop in case there are others
          elsif line.start_with?("@") && !selectable_line?(keyword, line) && current_item.any?
            collection << join_elements(current_item, separator)
            current_item = []
            # It's the second/third... line of a comment
          elsif current_item.any? && !line.start_with?('@')
            current_item << line.strip
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
        line.gsub(/@#{keyword}_#{lang}|@#{keyword}/, '').strip
      end

      def join_elements elements, separator
        elements.reject{|line| line.strip == '' || line.nil? }.join(separator)
      end

      def tasks
        @tasks = YAML.load_file(yml_path)
      end

    end
  end
end
