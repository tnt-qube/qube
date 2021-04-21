# Qube

HTTP API layer over Tarantool Queue.

## Installation

1. Install [Tarantool](https://github.com/tarantool/tarantool) or `brew install tarantool`
2. Install [Queue](https://github.com/tarantool/queue) or `tarantoolctl rocks install queue`
2. `git clone https://github.com/tnt-qube/qube`
3. Edit config:

```lua
-- config.lua

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
```

4. Run server `tarantool init.lua`