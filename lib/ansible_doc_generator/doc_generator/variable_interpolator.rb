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
        yaml_value = dig(task, yaml_path.gsub(/\s/, '').split('>'))

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

      def dig task, keys
        head, *tail = keys
        new_task = task[head]

        if tail == []
          return new_task
        elsif new_task.is_a?(String) && tail != []
          dig(hashify_inline_syntax(new_task), tail)
        else
          dig(new_task, tail)
        end
      end

      def hashify_inline_syntax string
        separated_values = string.scan(/(\w+)=("[^"]*"|\S+)/)
        separated_values.each_with_object({}){|(key, value), output| output[key] = value }
      end

    end
  end
end
