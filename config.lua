local Config = {}

-- TNT configuration
Config.tarantool = {
  access = {
    user     = 'qube',
    password = '1234567890',
  },
  node = {
    pid_file          = './tmp/qube.pid',
    -- pid_file          = '/var/run/qube.pid',
    memtx_memory      = 1024 * 1024 * 1024 * 1,
    memtx_dir         = './tmp',
    wal_dir           = './tmp',
    background        = false,
    custom_proc_title = 'qube',
    log_level         = 5,
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
  enable      = true,
  user_agent  = 'QubeShipper',
  token       = '77c04ced3f915240d0c5d8d5819f84c7',
  webhook_url = 'http://localhost:3000/_jobs',
  delay       = 0
}

return Config