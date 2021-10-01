require 'spec_helper'

describe 'libvirt::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) { 'include libvirt' }
      let(:facts) { os_facts }

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_package('libvirt')
            .with_ensure('present')
            .with_name('libvirt')
        end
        it do
          is_expected.to contain_package('kvm')
            .with_ensure('present')
            .with_name('qemu-kvm')
        end
      end

      context 'with a different libvirt package name' do
        let(:pre_condition) do
          super().replace(
            'class { "libvirt": libvirt_pkg => "diff_libvirt_pkg" }'
          )
        end

        it do
          is_expected.to contain_package('libvirt')
            .with_name('diff_libvirt_pkg')
        end
      end

      context 'with a different kvm package name' do
        let(:pre_condition) do
          super().replace(
            'class { "libvirt": kvm_pkg => "diff_kvm_pkg" }'
          )
        end

        it do
          is_expected.to contain_package('kvm')
            .with_name('diff_kvm_pkg')
        end
      end

      context 'without a kvm package' do
        let(:pre_condition) do
          super().replace(
            'class { "libvirt": kvm => false }'
          )
        end

        it { is_expected.not_to contain_package('kvm') }
      end

      context 'with a different virt-install package name' do
        let(:pre_condition) do
          super().replace(
            'class { "libvirt": virt_install_pkg=> "diff_virt_install_pkg" }'
          )
        end

        it do
          is_expected.to contain_package('virt-install')
            .with_name('diff_virt_install_pkg')
        end
      end

      context 'without a virt-install package' do
        let(:pre_condition) do
          super().replace(
            'class { "libvirt": virt_install => false }'
          )
        end

        it { is_expected.not_to contain_package('virt-install') }
      end
    end
  end
end

# vim: set tw=80 ts=2 sw=2 sts=2 et:
