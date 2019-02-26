# capistrano-shoryuken
Shoryuken integration for Capistrano.  Loosely based on `capistrano-sidekiq`

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-shoryuken', github: 'joekhoobyar/capistrano-shoryuken'

or:

    gem 'capistrano-shoryuken', group: :development

And then execute:

    $ bundle


## Usage
```ruby
    # Capfile

    require 'capistrano/shoryuken'
```


Configurable options, shown here with defaults (using Capistrano 3 syntax):

```ruby
    # config/deploy.rb

    # Whether or not to hook into the default deployment recipe.
    set :shoryuken_default_hooks,  true

    set :shoryuken_cmd,      -> { [:bundle, :exec, :shoryuken] }
    set :shoryuken_pid,      -> { File.join(shared_path, 'tmp', 'pids', 'shoryuken.pid') }
    set :shoryuken_env,      -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    set :shoryuken_log,      -> { File.join(shared_path, 'log', 'shoryuken.log') }
    set :shoryuken_config,   -> { File.join(release_path, 'config', 'shoryuken.yml') }
    set :shoryuken_requires, -> { [] }
    set :shoryuken_options,  -> { ['--rails'] }
    set :shoryuken_queues,   -> { [] }
    set :shoryuken_role,     :app

    # Monit

    set :shoryuken_service_name => "shoryuken_#{fetch(:application)}_#{fetch(:shoryuken_env)}"
    set :shoryuken_monit_conf_dir, '/etc/monit.d'
    set :shoryuken_monit_conf_file, -> { "#{shoryuken_service_name}.conf" }
    set :shoryuken_monit_use_sudo, true
    set :monit_bin, '/usr/local/bin/monit'
    set :shoryuken_monit_default_hooks, true
    set :shoryuken_monit_templates_path, 'config/deploy/templates'
    set :shoryuken_monit_group, nil
```

## Contributors

- [Joe Khoobyar] (https://github.com/joekhoobyar)
- [Cesar Gomez] (https://github.com/cesargomez89)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
