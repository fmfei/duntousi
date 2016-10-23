rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || "/var/www/p2p/current"

God.watch do |w|
  pid_file   = "#{rails_root}/tmp/pids/resque-scheduler.pid"
  w.dir      = "#{rails_root}"
  w.name     = "resque_scheduler"
  w.interval = 30.seconds
  w.env      = {"RAILS_ENV"=>rails_env, "PIDFILE"=>pid_file}
  w.start    = "bundle exec rake resque:scheduler BACKGROUND=yes"
  w.log      = "#{rails_root}/log/resque_scheduler.log"
  w.err_log  = "#{rails_root}/log/resque_scheduler_error.log"
  w.pid_file = pid_file
  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end