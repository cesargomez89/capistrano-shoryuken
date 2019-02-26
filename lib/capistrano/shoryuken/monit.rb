if Gem::Specification.find_by_name('capistrano').version >= Gem::Version.new('3.0.0')
  load File.expand_path('../../tasks/monit.rake', __FILE__)
else
  puts "Monit template is not compatible with Capistrano 2"
end
