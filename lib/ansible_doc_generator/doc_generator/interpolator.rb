# frozen_string_literal: true

require_relative "interpolator/variable_extractor"

module AnsibleDocGenerator
  class DocGenerator
    class Interpolator
      attr_reader :input, :task

      def initialize input, task
        @input = input
        @task = task
      end

      def call
        var_interpolated = Interpolator::VariableExtractor.new(input, task).call
      end

    end
  end
end
