require "spec_helper"

describe AnsibleDocGenerator::DocGenerator::VariableInterpolator do
  subject { described_class.new(input, task) }

  describe '#call' do
    context 'basic interpolation' do
      let(:input) { 'Add a line in #{lineinfile>destfile} to activate rbenv' }
      let(:task) do
        {
          'name' => 'Activate rbenv in users',
          'become' => true,
          'lineinfile' => {
            'destfile' => '/etc/bashrc',
            'state' => 'present'
          }
        }
      end

      it 'returns the expected output' do
        expect(subject.call).to eq 'Add a line in /etc/bashrc to activate rbenv'
      end
    end

    context 'interpolation with filters' do
      let(:input) { 'apt install -y #{apt>pkg | join: \' \'}' }
      let(:task) do
        {
          'name' => 'Install required packages',
          'apt' => {
            'pkg' => ["dirmngr", "gnupg", "apt-transport-https", "ca-certificates"]
          }
        }
      end

      it 'returns the expected output' do
        expect(subject.call).to eq 'apt install -y dirmngr gnupg apt-transport-https ca-certificates'
      end
    end

    context 'interpolation with filters' do
      let(:input) { 'apt install -y #{apt>pkg | join: \' \'}' }
      let(:task) do
        {
          'name' => 'Install required packages',
          'apt' => {
            'pkg' => ["dirmngr", "gnupg", "apt-transport-https", "ca-certificates"]
          }
        }
      end

      it 'returns the expected output' do
        expect(subject.call).to eq 'apt install -y dirmngr gnupg apt-transport-https ca-certificates'
      end
    end

    context 'interpolation with inline syntax' do
      let(:input) { 'Add a line in #{lineinfile>destfile} to activate the plugin' }
      let(:task) do
        {
          'name' => 'Activate rbenv vars',
          'lineinfile' => 'destfile=/etc/bashrc regexp="^rbenv-vars" line="eval \"$(/usr/lib/rbenv/plugins/rbenv-vars/bin/rbenv-vars)\"" state=present'
        }
      end

      it 'returns the expected output' do
        expect(subject.call).to eq 'Add a line in /etc/bashrc to activate the plugin'
      end
    end
  end
end
