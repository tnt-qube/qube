require('strict').on()

local config = require('config')
box.cfg(config.tarantool.node)

local json    = require('json')
local qube    = require('lib.qube')
local shipper = require('lib.shipper')
      shipper.start()

local http_router = require('http.router')
local http_server = require('http.server')
local tsgi        = require('http.tsgi')

local function send_response(code, payload)
  if not type(payload) == 'table' then
    return { status = code, body = json.encode({ message = tostring(payload) }) }
  else
    return { status = code, body = json.encode(payload) }
  end
end

local function auth_request(env)
  local request_token = env:header('x-auth-token')
  if not request_token == config.http.token then
    return send_response(403, 'Failed to authenticate request')
  else
    return tsgi.next(env)
  end
end

local function forward_request(controller, request)
  local success, result = pcall(qube[controller], request)
  if not success then
    return send_response(500, result)
  else
    return send_response(200, result)
  end
end

local routes = {
  { method = 'GET',    path = '/tubes',                    controller = 'tube_list'   },
  { method = 'POST',   path = '/tubes',                    controller = 'create_tube' },
  { method = 'DELETE', path = '/tubes/:tube',              controller = 'delete_tube' },
  { method = 'POST',   path = '/tubes/:tube',              controller = 'add_task'    },
  { method = 'GET',    path = '/tubes/:tube',              controller = 'take_task'   },
  { method = 'PUT',    path = '/tubes/:tube/:task_id/ack', controller = 'ack_task'    },
}

local router = http_router.new()
local auth_opts = {
  preroute = true,  name = 'auth',
  method   = 'GET', path = '/api/.*'
}
router:use(auth_request, auth_opts)

local server_opts = {
  log_requests = config.http.log_requests,
  log_errors   = config.http.log_errors
}
local server = http_server.new(config.http.host, config.http.port, server_opts)

for _, r in ipairs(routes) do
  router:route({ method = r.method, path = config.http.root .. r.path }, function(request)
    return forward_request(r.controller, request)
  end)
end

server:set_router(router)
server:start()