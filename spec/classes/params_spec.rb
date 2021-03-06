require 'spec_helper'

describe 'libvirt::params' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_resource_count(0) }
    end
  end
end

# vim: set tw=80 ts=2 sw=2 sts=2 et:
