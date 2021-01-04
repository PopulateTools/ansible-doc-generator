# frozen_string_literal: true

require_relative "interpolator/variable_extractor"
require_relative "interpolator/file_extractor"

module AnsibleDocGenerator
  class DocGenerator
    class Interpolator
      attr_reader :input, :task, :role_path

      def initialize input, task, role_path
        @input = input
        @task = task
        @role_path = role_path
      end

      def call
        variables_interpolated = Interpolator::VariableExtractor.new(input, task).call
        Interpolator::FileExtractor.new(variables_interpolated, role_path).call
      end

    end
  end
end
