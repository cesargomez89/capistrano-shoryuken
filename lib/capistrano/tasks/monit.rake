namespace :load do
  task :defaults do
    set :shoryuken_service_name => "shoryuken_#{fetch(:application)}_#{fetch(:shoryuken_env)}"
    set :shoryuken_monit_conf_dir, '/etc/monit.d'
    set :shoryuken_monit_conf_file, -> { "#{shoryuken_service_name}.conf" }
    set :shoryuken_monit_use_sudo, true
    set :monit_bin, '/usr/local/bin/monit'
    set :shoryuken_monit_default_hooks, true
    set :shoryuken_monit_templates_path, 'config/deploy/templates'
    set :shoryuken_monit_group, nil
  end
end

namespace :deploy do
  before :starting, :check_shoryuken_monit_hooks do
    if fetch(:shoryuken_default_hooks) && fetch(:shoryuken_monit_default_hooks)
      invoke 'shoryuken:monit:add_default_hooks'
    end
  end
end

namespace :shoryuken do
  namespace :monit do

    task :add_default_hooks do
      before 'deploy:updating',  'shoryuken:monit:unmonitor'
      after  'deploy:published', 'shoryuken:monit:monitor'
    end

    desc 'Config Shoryuken monit-service'
    task :config do
      on roles(fetch(:shoryuken_role)) do |role|
        @role = role
        upload_shoryuken_template 'shoryuken_monit', "#{fetch(:tmp_dir)}/monit.conf", @role

        mv_command = "mv #{fetch(:tmp_dir)}/monit.conf #{fetch(:shoryuken_monit_conf_dir)}/#{fetch(:shoryuken_monit_conf_file)}"
        sudo_if_needed mv_command

        sudo_if_needed "#{fetch(:monit_bin)} reload"
      end
    end

    desc 'Monitor Shoryuken monit-service'
    task :monitor do
      on roles(fetch(:shoryuken_role)) do
          begin
            sudo_if_needed "#{fetch(:monit_bin)} monitor #{shoryuken_service_name}"
          rescue
            invoke 'shoryuken:monit:config'
            sudo_if_needed "#{fetch(:monit_bin)} monitor #{shoryuken_service_name}"
          end
      end
    end

    desc 'Unmonitor Shoryuken monit-service'
    task :unmonitor do
      on roles(fetch(:shoryuken_role)) do
          begin
            sudo_if_needed "#{fetch(:monit_bin)} unmonitor #{shoryuken_service_name}"
          rescue
            # no worries here
          end
      end
    end

    desc 'Start Shoryuken monit-service'
    task :start do
      on roles(fetch(:shoryuken_role)) do
          sudo_if_needed "#{fetch(:monit_bin)} start #{shoryuken_service_name}"
      end
    end

    desc 'Stop Shoryuken monit-service'
    task :stop do
      on roles(fetch(:shoryuken_role)) do
          sudo_if_needed "#{fetch(:monit_bin)} stop #{shoryuken_service_name}"
      end
    end

    desc 'Restart Shoryuken monit-service'
    task :restart do
      on roles(fetch(:shoryuken_role)) do
        sudo_if_needed"#{fetch(:monit_bin)} restart #{shoryuken_service_name}"
      end
    end

    def shoryuken_service_name
      fetch(:shoryuken_service_name, "shoryuken_#{fetch(:application)}_#{fetch(:shoryuken_env)}")
    end

    def sudo_if_needed(command)
      send(use_sudo? ? :sudo : :execute, command)
    end

    def use_sudo?
      fetch(:shoryuken_monit_use_sudo)
    end

    def upload_shoryuken_template(from, to, role)
      template = shoryuken_template(from, role)
      upload!(StringIO.new(ERB.new(template).result(binding)), to)
    end

    def shoryuken_template(name, role)
      local_template_directory = fetch(:shoryuken_monit_templates_path)

      search_paths = [
        "#{name}-#{role.hostname}-#{fetch(:stage)}.erb",
        "#{name}-#{role.hostname}.erb",
        "#{name}-#{fetch(:stage)}.erb",
        "#{name}.erb"
      ].map { |filename| File.join(local_template_directory, filename) }

      global_search_path = File.expand_path(
        File.join(*%w[.. .. .. generators capistrano shoryuken monit templates], "#{name}.conf.erb"),
        __FILE__
      )


      search_paths << global_search_path
      puts search_paths.inspect
      template_path = search_paths.detect { |path| File.file?(path) }
      File.read(template_path)
    end
  end
end
