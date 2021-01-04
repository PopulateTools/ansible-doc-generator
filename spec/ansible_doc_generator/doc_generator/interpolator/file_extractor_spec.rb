require "spec_helper"

describe AnsibleDocGenerator::DocGenerator::Interpolator::FileExtractor do
  subject { described_class.new(input, path) }

  describe '#call' do
    let(:input) { "El output es:\nf{example_file_content.txt}" }
    let(:path) { 'spec/support/files/fake_non_existent_file.yml' }

    context 'existing file' do
      let(:expected_output) { "El output es:\n#{File.read("spec/support/files/example_file_content.txt")}" }

      it 'interpolates the file content' do
        expect(subject.call).to eq expected_output
      end
    end

    context 'missing file' do
      let(:input) { "El output es:\nf{fake_file_content.txt}" }
      let(:expected_output) { "El output es:\nf{fake_file_content.txt}" }

      it 'interpolates the file content' do
        expect(subject.call).to eq expected_output
      end
    end
  end
end
