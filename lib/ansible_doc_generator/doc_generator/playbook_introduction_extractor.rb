# frozen_string_literal: true

require_relative "extractor_helper"
require_relative "interpolator"

module AnsibleDocGenerator
  class DocGenerator
    class PlaybookIntroductionExtractor
      include ExtractorHelper

      attr_reader :playbook_path, :lang
      attr_accessor :parsed_content, :md_output

      def initialize playbook_path, lang
        @playbook_path = playbook_path
        @lang = lang
        @parsed_content = []
        @md_output = []
      end

      def call
        joined_output
      end

      private

      def joined_output
        @joined_output ||= begin
          parse_file_comments
          generate_content

          join_elements(md_output, "\n\n")
        end
      end

      def parse_file_comments
        file = File.open(playbook_path)
        file.each do |line|
          if line.start_with?('#')
            parsed_content << line.gsub(/\A#\s{1}/, '')
          end
        end and nil
      end

      def generate_content
        title = extract_from(:title, parsed_content)
        comments = extract_multiline_from(:comment, parsed_content)

        md_output << generate_md_with(title: title, comments: comments)
      end

      def generate_md_with params
        temp_md = []
        temp_md.push("# #{params[:title]}") if params[:title]
        params.fetch(:comments, []).each{|comment| temp_md << comment }

        join_elements(temp_md, "\n\n")
      end

    end
  end
end
