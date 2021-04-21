local Config = {}

Config.http = {
  root  = '/api/v1',
  host  = '127.0.0.1',
  port  = '5672',
  token = '77c04ced3f915240d0c5d8d5819f84c7',
  log_requests = true,
  log_errors   = true
}

Config.tarantool = {
  access = {
    user     = 'qube',
    password = '77c04ced3f915240d0c5d8d5819f84c7',
  },
  node = {
    pid_file     = '/var/run/tarantool',
    memtx_memory = 1024 * 1024 * 1024 * 2,
    memtx_dir    = '/var/backup/qube',
    wal_dir      = '/var/backup/qube',
    log          = '/var/log/qube/qube.log',
    background   = false,
    custom_proc_title = 'qube'
  }
}

return Config