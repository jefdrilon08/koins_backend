
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'activerecord-import'
gem 'awesome_print'
gem 'aws-sdk-s3', require: false
gem 'aws-sdk-sns'
gem 'aws-sdk-ses'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'cocoon'
gem 'config'
gem 'cssbundling-rails'
gem 'devise'
gem 'dotenv-rails'
gem 'haml'
gem 'hirb'
gem 'httparty'
gem 'jsbundling-rails'
gem 'jwt'
gem 'kaminari'
gem 'mini_magick'
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'net-smtp', require: false
gem 'newrelic_rpm'
gem 'numbers_and_words'
gem 'pg'
gem 'puma'
gem 'rack-cors'
gem 'rails'
gem 'redis'
gem 'rollbar'
gem 'sendgrid-ruby'
gem 'sidekiq'
gem 'simple_form'
gem 'stimulus-rails'
gem 'tty-table'
gem 'turbo-rails'
gem 'whenever'
gem 'zip-zip'
gem "ruby-vips", "~> 2.3.0"
gem 'rqrcode', '~> 3.1'
gem 'bcrypt', '~> 3.1.18'
gem "solid_queue"

# TODO: Remove eventually
gem 'jquery-rails'

gem 'uglifier'
#gem 'sprockets-rails'

# For ruby 2.7.1
# Note for Ubuntu: Make synmlink to ln -s /bin/mkdir /usr/bin/mkdir
gem 'nokogiri'

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'guard-rspec', require: false
  gem 'bullet'

  # Profiling
  gem 'rack-mini-profiler'
  gem 'memory_profiler' # For memory profiling
  gem 'flamegraph' # For call-stack profiling flamegraphs
  gem 'stackprof'
  gem 'puma_worker_killer'
end

group :test do
  gem "rspec-rails"
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :test, :development do
  gem "factory_bot_rails"
  gem "faker"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
