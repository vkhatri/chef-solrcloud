require 'rubocop/rake_task'
require 'foodcritic'
require 'rspec/core/rake_task'

# Default task
task :default => :lint

# Default lint
desc 'Run all lints'
task :lint =>  %w(knife foodcritic rubocop spec)

# Knife
desc 'Run Knife Test'
task :knife do
  cookbook_dir = File.expand_path(File.dirname(__FILE__))
  cookbook_name = File.basename(cookbook_dir)
  sh %(bundle exec knife cookbook test -o #{cookbook_dir}/.. -c #{cookbook_dir}/test/.chef/knife.rb #{cookbook_name})
end

# Foodcritic
desc 'Run Foodcritic Lint'
task :foodcritic do
  if Gem::Version.new('1.9.3') <= Gem::Version.new(RUBY_VERSION.dup)
    puts 'Running Foodcritic Lint ..'
    FoodCritic::Rake::LintTask.new
  else
    puts "WARNING: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.3"
  end
end

# Rubocop
desc 'Run Rubocop Lint'
task :rubocop do
  RuboCop::RakeTask.new
end

# Spec
desc 'Run ChefSpec Test'
 task :spec do
  puts 'Running ChefSpec Test'
  RSpec::Core::RakeTask.new(:spec)
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end
