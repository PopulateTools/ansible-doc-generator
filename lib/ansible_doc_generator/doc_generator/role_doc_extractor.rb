# frozen_string_literal: true

require_relative "extractor_helper"
require_relative "interpolator"

module AnsibleDocGenerator
  class DocGenerator
    class RoleDocExtractor
      include ExtractorHelper

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
        joined_output
      end

      private

      def joined_output
        @joined_output ||= begin
          parse_file_comments
          generate_meta_content
          generate_tasks_content

          join_elements(md_output, "\n\n")
        end
      end

      # Extract relevant lines from the file and group them by task
      def parse_file_comments
        file = File.open(yml_path)
        current_comments = []
        file.each do |line|
          if line.start_with?('#') && META_KEYWORDS.any?{|keyword| line.start_with?("# @#{keyword}") }
            parsed_content['meta'] << line.gsub(/\A#\s{1}/, '').strip
          elsif line.start_with?('#')
            current_comments << line.gsub(/\A#\s{1}/, '')
          elsif line.start_with?('- name:')
            task_name = line.gsub('- name:','').strip
            parsed_content[task_name] = current_comments
            current_comments = []
          end
        end and nil
        file.close
      end

      def generate_meta_content
        return if parsed_content['meta'] == []
        metatitle = extract_from(:metatitle, parsed_content['meta'])
        return if metatitle.nil?

        md_output << "## #{metatitle}"
      end

      # Parse previously extracted lines and separated them by keyword
      def generate_tasks_content
        parsed_content.each do |task_name, lines|
          title = extract_from(:title, lines)

          output = extract_multiline_from(:output, lines, separator: "\n")
          input = extract_multiline_from(:input, lines, separator: "\n")
          comments = extract_multiline_from(:comment, lines)

          md_output << generate_md_with(task_name, title: title, comments: comments, output: output, input: input)
        end
      end

      def generate_md_with task_name, params
        temp_md = []
        temp_md.push("### #{params[:title]}") if params[:title]
        params.fetch(:comments, []).each{|comment| temp_md << comment }
        temp_md << "```\n#{params.fetch(:input, []).join("\n")}\n```" if params[:input].length > 0
        temp_md << "Expected output: \n\n```\n#{params[:output]}\n```" if params[:output].length > 0

        non_interpolated_output = join_elements(temp_md, "\n\n")
        task = tasks.find{|task| task['name'] == task_name}
        Interpolator.new(non_interpolated_output, task, yml_path).call
      end

      def tasks
        @tasks = YAML.load_file(yml_path)
      end

    end
  end
end
