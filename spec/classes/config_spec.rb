require 'spec_helper'

describe 'libvirt::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      case os_facts[:os]['release']['major']
      when '6'
        let(:sum) do
          {
            libvirtd: '4d7c27ca0f2d42940ad541a61764f5fd6ad0bfa0',
          }
        end
      when '8'
        let(:sum) do
          {
            libvirtd: '4f1c2ef1f4032b5a6fdc659d3b2d449c5793aa12',
          }
        end
      end
      let(:pre_condition) { 'include libvirt' }
      let(:facts) { os_facts }

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_file('/etc/libvirt/libvirtd.conf')
            .with_ensure('present')
            .with_require('Class[Libvirt::Install]')
        end
        # These should match the completely unaltered files shipped with package
        it 'is expected that the base libvirtd.conf template will match' do
          f = catalogue.resource('file', '/etc/libvirt/libvirtd.conf')
          real = Digest::SHA1.hexdigest(f[:content])
          expect(real).to eq(sum[:libvirtd])
        end
      end
    end
  end
end

# vim: set tw=80 ts=2 sw=2 sts=2 et:
