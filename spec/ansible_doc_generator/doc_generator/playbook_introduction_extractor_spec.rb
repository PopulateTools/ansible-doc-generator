require "spec_helper"

describe AnsibleDocGenerator::DocGenerator::PlaybookIntroductionExtractor do
  let(:playbook_path) { 'spec/support/files/example_playbook.yml' }
  let(:lang) { 'es' }

  subject { described_class.new(playbook_path, lang) }

  describe '#call' do
    let(:expected_output) { File.read("spec/support/files/example_playbook_output_en.md") }

    it 'returns the expected output' do
      expect(subject.call).to match expected_output.chop
    end
  end
end
