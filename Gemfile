source 'https://rubygems.org'

gem 'rake'
gem 'berkshelf',  '~> 3.1.4'
gem 'chefspec',   '~> 3.0'
gem 'foodcritic', '~> 3.0'
gem 'rubocop',    '~> 0.24'

# ohai attributes override
gem 'fauxhai'

group :integration do
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'kitchen-docker'
end

group :test do
  gem 'coveralls', require: false
end

group :development do
  gem 'chef'
  gem 'knife-spork', '~> 1.0.17'
  gem 'knife-spec'
end
