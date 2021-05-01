local Config = {}

-- TNT configuration
Config.tarantool = {
  access = {
    user     = 'qube',
    password = '77c04ced3f915240d0c5d8d5819f84c7',
  },
  node = {
    pid_file          = '/var/run/qube.pid',
    memtx_memory      = 1024 * 1024 * 1024 * 1,
    memtx_dir         = './',
    wal_dir           = './',
    background        = false,
    custom_proc_title = 'qube',
    -- log_format        = 'json'
  }
}

-- HTTP Server
Config.http = {
  root         = '/api/v1',
  host         = '127.0.0.1',
  port         = '5672',
  token        = '77c04ced3f915240d0c5d8d5819f84c7',
  log_requests = true,
  log_errors   = true
}

-- Shipper
Config.shipper = {
  enable       = true,
  user_agent   = 'QubeShipper',
  token        = '77c04ced3f915240d0c5d8d5819f84c7',
  webhook_url  = 'http://localhost:3000/qube/_jobs',
  task_check   = 1
}

return Config