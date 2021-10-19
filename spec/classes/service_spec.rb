require 'spec_helper'

describe 'libvirt::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) { 'include libvirt' }
      let(:facts) { os_facts }

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }

        case os_facts[:os]['release']['major']
        when '6'
          it do
            is_expected.to contain_service('libvirtd')
              .with_ensure('running')
              .with_enable(true)
              .with_hasstatus(true)
              .with_hasrestart(true)
              .with_provider('redhat')
              .with_require('Class[Libvirt::Config]')
          end
          it do
            is_expected.to contain_service('libvirt-guests')
              .with_ensure(nil)
              .with_name('libvirt-guests')
              .with_enable(true)
              .with_provider('redhat')
              .with_require('Class[Libvirt::Config]')
          end
        when '8'
          %w[virtlogd.socket virtlockd.socket libvirtd.socket].each do |svc|
            it do
              is_expected.to contain_service(svc)
                .with_ensure('running')
                .with_enable(true)
                .with_hasstatus(true)
                .with_hasrestart(true)
                .with_provider('systemd')
                .with_require('Class[Libvirt::Config]')
            end
          end
          it do
            is_expected.to contain_service('libvirt-guests')
              .with_ensure(true)
              .with_provider('systemd')
          end
        end
      end

      context 'with custom libvirt service name' do
        let(:pre_condition) do
          super().replace("class { 'libvirt': libvirt_service => 'meh' }")
        end

        next unless os_facts[:os]['release']['major'] == '6'
        it { is_expected.to contain_service('meh') }
        it { is_expected.not_to contain_service('libvirtd') }
      end

      context 'without libvirt-guests' do
        let(:pre_condition) do
          super().replace("class { 'libvirt': libvirt_guests => false }")
        end

        it do
          is_expected.to contain_service('libvirt-guests')
            .with_ensure(nil)
            .with_enable(false)
        end
      end
    end
  end
end
