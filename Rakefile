begin
  require 'voxpupuli/test/rake'
rescue LoadError
  # only available if gem group test is installed
end

begin
  require 'voxpupuli/acceptance/rake'
rescue LoadError
  # only available if gem group acceptance is installed
end

begin
  require 'voxpupuli/release/rake_tasks'
rescue LoadError
  # only available if gem group releases is installed
else
  GCGConfig.user = 'jps-help'
  GCGConfig.project = 'puppet-dconf'
end

# vim: syntax=ruby
