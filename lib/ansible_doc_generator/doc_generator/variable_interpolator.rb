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
        variable_match = interpolation.match(/#\{([^\}]+)\}/)[1]
        yaml_path, filters = variable_match.split('|')
        set_filters(filters)
        yaml_value = task.dig(*yaml_path.gsub(/\s/, '').split('>'))

        case yaml_value
        when String then yaml_value
        when Array then yaml_value.join(@filters[:join])
        else interpolation
        end
      end

      def set_filters(filters)
        return if filters.nil?
        filter_name, filter_value = filters.split(':')
        @filters[filter_name.gsub(/\s/, '').to_sym] = eval(filter_value)
      end
    end
  end
end
