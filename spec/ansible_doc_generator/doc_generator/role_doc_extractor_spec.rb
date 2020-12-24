require "spec_helper"

describe AnsibleDocGenerator::DocGenerator::RoleDocExtractor do
  let(:yml_path) { 'spec/support/files/example_role.yml' }

  subject { described_class.new(yml_path, lang) }

  describe '#call' do
    context 'spanish' do
      let(:lang) { 'es' }
      let(:expected_output) { File.read("spec/support/files/example_role_output_es.md") }

      it 'returns the expected output' do
        expect(subject.call).to match expected_output.chop
      end
    end

    context 'english' do
      let(:lang) { 'en' }
      let(:expected_output) { File.read("spec/support/files/example_role_output_en.md") }

      it 'returns the expected output' do
        expect(subject.call).to match expected_output.chop
      end
    end
  end
end
