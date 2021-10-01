require 'hiera'
require 'rspec-puppet'
require 'rspec-puppet-facts'
include RspecPuppetFacts # rubocop:disable Style/MixinUsage

RSpec.configure do |c|
  c.mock_with :rspec
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  c.formatter = :documentation
  c.after(:suite) do
    cov = if ENV['COVERAGE'].nil? || ENV['COVERAGE'].empty?
            100
          else
            ENV['COVERAGE'].to_i
          end
    RSpec::Puppet::Coverage.report!(cov)
  end
end

# The mocking framework needed to be configured before pulling this in
require 'puppetlabs_spec_helper/module_spec_helper'

class Hash
  # Individual spec files need to append and/or overwrite parts of the facts
  # provided by rspec-puppet-facts and the custom facts above.
  def deep_merge(second)
    merger = proc do |_key, v1, v2|
      if v1.is_a?(Hash) && v2.is_a?(Hash); then v1.merge(v2, &merger)
      elsif v1.is_a?(Array) && v2.is_a?(Array); then v1 | v2
      elsif [:undefined, nil, :nil].include?(v2); then v1
      else
        v2
      end
    end
    merge(second.to_h, &merger)
  end

  # Ruby doesn't have a non-destructive way of deleting
  # a key from a hash. ActiveSupport does. This is it.
  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  # This is the nested version of above
  def except_nested(key)
    r = Marshal.load(Marshal.dump(self))
    r.except_nested!(key)
  end

  def except_nested!(key)
    except!(key)
    each do |_, v|
      v.except_nested!(key) if v.is_a?(Hash)
    end
  end
end

# vim: set tw=80 ts=2 sw=2 sts=2 et:
