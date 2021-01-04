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
          return scan_in_inline_syntax(new_task, tail.first)
        else
          dig(new_task, tail)
        end
      end

      def scan_in_inline_syntax string, key
        input = StringScanner.new(string)

        # Scan until the key we are looking for
        input.scan_until(/#{key}=/)
        # Scan until the next key
        output = input.scan_until(/\s{1}\S+=/)
        # Remove the next key part
        output.gsub(/\s{1}\S+=/, '')
      end

    end
  end
end
