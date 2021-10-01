require 'spec_helper'

describe 'libvirt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('libvirt::params') }
        it { is_expected.to contain_class('libvirt::install') }
      end
    end
  end
end

# vim: set tw=80 ts=2 sw=2 sts=2 et:
