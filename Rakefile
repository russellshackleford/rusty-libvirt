require 'puppetlabs_spec_helper/rake_tasks'
require 'colorize'

def gnu_grep?
  errmsg = "\nGrep with perl support is required. If you are using a Mac"
  errmsg += "\nyou will need to brew install grep and then add:"
  errmsg += "\nexport PATH=\"/usr/local/opt/grep/libexec/gnubin:$PATH\""
  errmsg += "\ninto ~/.bash_profile\n\n"
  system('grep --help |grep -q perl-regexp')
  raise errmsg unless $CHILD_STATUS.success?
end

# Define paths excluded from multiple tests
exclude_paths = %w[spec/fixtures/**/* vendor/**/*]

# Clear some unneeded tasks used for publishing to the forge
Rake::Task[:build].clear
Rake::Task[:clean].clear
Rake::Task[:compute_dev_version].clear

# The puppet-lint's rake task has no flexibility. PDK moved to using the binary
# directly and so will we.
Rake::Task[:lint].clear
Rake::Task[:lint_fix].clear
desc 'Run puppet-lint'
task :lint do |_t, args|
  if args.extras.empty? || args.extras.nil?
    pattern = Dir.glob('**/*.pp')
    pattern -= Dir.glob(exclude_paths) if defined?(exclude_paths)
  else
    pattern = args.extras
  end
  system("puppet-lint #{pattern.sort.join(' ')}")
  raise 'puppet-lint failed!' unless $CHILD_STATUS.success?
  puts 'puppet-lint successful!'
end

# Rubocop will likely have caught anything ruby -c will catch, but just in case.
desc 'Validate spec files'
task :validate_spec do
  Dir['spec/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ %r{spec/fixtures}
  end
end

whitelist = %w[
  aio_agent_version
  augeas
  facterversion
  filesystems
  is_virtual
  kernel
  kernelmajversion
  kernelrelease
  kernelversion
  os
  path
  ruby
  timezone
  virtual
]
greylist = %w[
  dmi
  load_averages
  memory
  networking
  processors
  ssh
  system_uptime
]

desc 'Checks for implementation-specific facter facts'
task :bad_facts do
  bail = false
  puts "\nChecking for implementation-specific facter facts\n"
  Dir['manifests/**/*.pp'].each do |pp|
    File.foreach(pp).with_index do |line, linenum|
      if line =~ /\${?facts\['\w+'\]/
        matches = line.scan(/\['\w+'\]/).map { |x| x.tr("[]'", '') }
        next if whitelist.include? matches.first

        msg = "fact (#{matches.first}) in #{pp}:#{linenum}"
        if greylist.include? matches.first
          puts "Found greylisted #{msg}".yellow
        else
          puts "Found blacklisted #{msg}".red
          bail = true
        end
      end
    end
  end
  puts
  raise if bail
end

# Leading double colons is a syntax for a bygone era
desc 'Check for leading ::'
task :double_colons do
  puts 'Checking for leading double colons (::)'
  gnu_grep?
  # regex = "('|\\[|\\\\$|\\{| )::(?!(:|mirror|sensu_gem_source))"
  regex = "('|\\[|\\\\$|\\{| )::"
  files = Dir.glob('**/*.pp')
  files -= Dir.glob(exclude_paths) if defined?(exclude_paths)
  system("grep -P \"#{regex}\" #{files.sort.join(' ')}")
  raise "\nLeading double colons found!" if $CHILD_STATUS.success?
end

desc 'Runs :release_checks, :bad_facts, :rubocop, and :validate_spec'
task :precommit do
  Rake::Task[:bad_facts].invoke
  Rake::Task[:double_colons].invoke
  Rake::Task[:rubocop].invoke
  Rake::Task[:validate_spec].invoke
  Rake::Task[:release_checks].invoke
end

# vim: set ts=2 sw=2 et:
