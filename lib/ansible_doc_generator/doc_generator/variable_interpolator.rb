# frozen_string_literal: true

module AnsibleDocGenerator
  class DocGenerator
    class VariableInterpolator
      attr_reader :input, :task

      def initialize input, task
        @input = input
        @task = task
        @filters = {
          join: ', '
        }
      end

      def call
        output = input

        input.scan(/#\{[^\}]+\}/).each do |interpolation|
          new_string = get_string(interpolation)
          output.gsub!(interpolation, new_string)
        end

        output
      end

      private

      def get_string interpolation
        yaml_path = interpolation.match(/#\{(\S*)\}/)[1]
        yaml_value = task.dig *yaml_path.split('>')

        case yaml_value
        when String then yaml_value
        when Array then yaml_value.join(", ")
        else interpolation
        end
      end

    end
  end
end
