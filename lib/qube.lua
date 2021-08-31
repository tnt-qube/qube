local json = require('json')
-- local xray = require('lib.xray')

local M = {}
M.queue = require('queue')
M.queue.create_tube('default', 'fifo', { if_not_exists = true })

function M.create_tube(request)
  local name = request:post_param('tube')
  local type = request:post_param('type')
  local opts = request:post_param('options')
  if M.queue.create_tube(name, type, opts) then
    return true
  end
end

function M.delete_tube(request)
  local name = request:stash('tube')
  local tube = M.queue.tube[name]
  tube:truncate()
  return tube:drop()
end

function M.add_task(request)
  local name = request:stash('tube')
  local body = json.decode(request:read())
  local task = body['task']
  local opts = body['options'] or {}
  if M.queue.tube[name]:put(task, opts) then
    return true
  end
end

function M.take_task(request)
  local name = request:stash('tube')
  local opts = json.decode(request:read())
  local task = M.queue.tube[name]:take(opts['timeout'])
  if not task then
    return {}
  else
    return { task_id = task[1], data = task[3] }
  end
end

function M.ack_task(request)
  local name    = request:stash('tube')
  local task_id = tonumber(request:stash('task_id'))
  local status  = M.queue.tube[name]:ack(task_id)
  return status
end

function M.tube_list(_)
  local list = {}
  for tube, _ in pairs(M.queue.tube) do
    table.insert(list, tube)
  end
  return list
end

-- Special for Rails adapter
function M.jobs(request)
  local body = json.decode(request:read())
  local tube_name = body['data']['queue_name']

  if M.queue.tube[tube_name] == nil then
    M.queue.create_tube(tube_name, 'fifo')
  end
  
  if M.queue.tube[tube_name]:put(body['data']) then
    return true
  end
end

return M