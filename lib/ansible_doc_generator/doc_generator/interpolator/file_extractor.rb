# frozen_string_literal: true

module AnsibleDocGenerator
  class DocGenerator
    class Interpolator
      class FileExtractor
        attr_reader :input, :role_path

        def initialize input, role_path
          @input = input
          @role_path = role_path
        end

        def call
          output = input

          input.scan(/f\{[^\}]+\}/).each do |interpolation|
            file_content = get_file_content(interpolation)
            output.gsub!(interpolation, file_content)
          end

          output
        end

        private

        def get_file_content interpolation
          file_name = interpolation.match(/f\{(\S*)\}/)[1]
          file_path = get_file_path_from(file_name)

          return interpolation if file_path.nil?
          File.read(file_path)
        end

        def get_file_path_from file_name
          %w(files templates)
            .map{|folder_name| File.join(main_folder, folder_name, file_name) }
            .find{|file_path| File.exists?(file_path) }
        end

        def main_folder
          @main_folder ||= File.expand_path("..", File.dirname(role_path))
        end

      end
    end
  end
end
