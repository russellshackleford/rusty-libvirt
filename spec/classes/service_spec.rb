require 'spec_helper'

describe 'libvirt::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) { 'include libvirt' }
      let(:facts) { os_facts }

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_service('libvirt')
            .with_ensure('running')
            .with_name('libvirtd')
            .with_enable(true)
            .with_hasstatus(true)
            .with_hasrestart(true)
            .that_requires('Class[libvirt::config]')
        end
        it do
          is_expected.to contain_service('libvirt-guests')
            .with_name('libvirt-guests')
            .with_enable(false)
            .that_requires('Class[libvirt::config]')
        end
      end
    end
  end
end
