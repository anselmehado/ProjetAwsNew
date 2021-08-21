$worker  = 2
$timeout = 30
#Your application name (note that current is included)
$anselme_dir = "/var/www/ProjetAwsNew/current"
$listen  = File.expand_path 'tmp/sockets/unicorn.sock', $anselme_dir
$pid     = File.expand_path 'tmp/pids/unicorn.pid', $anselme_dir
$std_log = File.expand_path 'log/unicorn.log', $anselme_dir
# Defined so that what is Settings above is applied
worker_processes  $worker
working_directory $anselme_dir
stderr_path $std_log
stdout_path $std_log
timeout $timeout
listen  $listen
pid $pid
preload_app true
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      Process.kill "QUIT", File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
