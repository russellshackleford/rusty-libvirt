require 'spec_helper'

describe 'libvirt::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      case os_facts[:os]['release']['major']
      when '6'
        let(:sum) do
          {
            libvirtd: '4d7c27ca0f2d42940ad541a61764f5fd6ad0bfa0',
            libvirt_guests: '1aaf96d7de86d8c0dbed8125096bb7a82675fb63',
            polkit: '9059654016cdb794aad183c59dc6585871ed94b6',
          }
        end
        let(:pol_file) do
          '/etc/polkit-1/localauthority/50-local.d/50-libvirtd.pkla'
        end
      when '8'
        let(:sum) do
          {
            libvirtd: '4f1c2ef1f4032b5a6fdc659d3b2d449c5793aa12',
            libvirt_guests: 'a766ef2673b38ccaeb7999b046e205ae0026c54e',
            polkit: 'c5a1766d440b2490627004559d532b23b5346186',
          }
        end
        let(:pol_file) { '/etc/polkit-1/rules.d/50-libvirt.rules' }
      end
      let(:pre_condition) { 'include libvirt' }
      let(:facts) { os_facts }

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_group('libvirt') }
        it do
          is_expected.to contain_file('/etc/profile.d/libvirt-uri.sh')
            .with_ensure('present')
            .with_mode('0644')
            .with_source('puppet:///modules/libvirt/libvirt-uri.sh')
        end

        it 'is expected that libvirt-uri.sh will match sum' do
          f = File.read('files/libvirt-uri.sh')
          sum = Digest::SHA1.hexdigest(f)
          expect(sum).to eq('1b666261f53abb09e19ae598b732a957aba371ea')
        end

        it do
          is_expected.to contain_file('/etc/libvirt/libvirtd.conf')
            .with_ensure('present')
            .with_require('Class[Libvirt::Install]')
            .with_notify('Service[libvirt]')
        end
        # These should match the completely unaltered files shipped with package
        it 'is expected that the base libvirtd.conf template will match' do
          f = catalogue.resource('file', '/etc/libvirt/libvirtd.conf')
          real = Digest::SHA1.hexdigest(f[:content])
          expect(real).to eq(sum[:libvirtd])
        end

        it do
          is_expected.to contain_file('/etc/sysconfig/libvirt-guests')
            .with_ensure('present')
            .with_require('Class[Libvirt::Install]')
        end
        # These should match the completely unaltered files shipped with package
        it 'is expected that the base libvirt-guests template will match' do
          f = catalogue.resource('file', '/etc/sysconfig/libvirt-guests')
          real = Digest::SHA1.hexdigest(f[:content])
          expect(real).to eq(sum[:libvirt_guests])
        end

        it { is_expected.not_to contain_file(pol_file) }
      end

      context 'when managing the default group' do
        let(:pre_condition) do
          super().replace("class { 'libvirt': manage_group => true }")
        end

        it { is_expected.to contain_group('libvirt') }
      end

      context 'when managing a non-default group' do
        let(:pre_condition) do
          super().replace(
            "class { 'libvirt':
               manage_group => true,
               socket_group => 'nondefault' }"
          )
        end

        it { is_expected.to contain_group('nondefault') }
      end

      context 'when managing the GID' do
        let(:pre_condition) do
          super().replace(
            "class { 'libvirt':
               manage_group => true,
               socket_gid => 1337 }"
          )
        end

        it do
          is_expected.to contain_group('libvirt')
            .with_gid(1337)
        end
      end

      %w[start ignore].each do |x|
        context "with libvirt_guests_onboot set to #{x}" do
          let(:pre_condition) do
            super().replace(
              "class { 'libvirt': libvirt_guests_onboot => '#{x}' }"
            )
          end

          it "is expected to configure ON_BOOT to '#{x}'" do
            is_expected.to contain_file('/etc/sysconfig/libvirt-guests')
              .with_content(/^ON_BOOT=#{x}$/)
          end
        end
      end

      context 'with an invalid option for libvirt_guests_onboot' do
        let(:pre_condition) do
          super().replace(
            "class { 'libvirt': libvirt_guests_onboot => 'invalid' }"
          )
        end

        it do
          is_expected.to compile.and_raise_error(
            /'libvirt_guests_onboot' expects a match for Enum/
          )
        end
      end

      %w[suspend shutdown].each do |x|
        context "with libvirt_guests_onshutdown set to #{x}" do
          let(:pre_condition) do
            super().replace(
              "class { 'libvirt': libvirt_guests_onshutdown => '#{x}' }"
            )
          end

          it "is expected to configure ON_SHUTDOWN to '#{x}'" do
            is_expected.to contain_file('/etc/sysconfig/libvirt-guests')
              .with_content(/^ON_SHUTDOWN=#{x}$/)
          end
        end
      end

      context 'with an invalid option for libvirt_guests_onshutdown' do
        let(:pre_condition) do
          super().replace(
            "class { 'libvirt': libvirt_guests_onshutdown=> 'invalid' }"
          )
        end

        it do
          is_expected.to compile.and_raise_error(
            /'libvirt_guests_onshutdown' expects a match for Enum/
          )
        end
      end

      context 'when polkit is managed' do
        let(:pre_condition) do
          super().replace("class { 'libvirt': manage_polkit => true }")
        end

        it do
          is_expected.to contain_file(pol_file)
            .with_ensure('present')
            .with_require('Class[Libvirt::Install]')
        end

        it 'is expected that the default polkit file will match' do
          f = catalogue.resource('file', pol_file)
          real = Digest::SHA1.hexdigest(f[:content])
          expect(real).to eq(sum[:polkit])
        end

        context 'when using a non-default group' do
          case os_facts[:os]['release']['major']
          when '6'
            let(:match) { /Identity=unix-group:nondefault/ }
          when '8'
            let(:match) { /subject.isInGroup\("nondefault"\)/ }
          end
          let(:pre_condition) do
            super().replace(
              "class { 'libvirt':
                 manage_polkit => true,
                 socket_group => 'nondefault' }"
            )
          end

          it do
            is_expected.to contain_file(pol_file)
              .with_content(match)
          end
        end
      end
    end
  end
end

# vim: set tw=80 ts=2 sw=2 sts=2 et:
