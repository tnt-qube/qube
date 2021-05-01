local fiber  = require('fiber')
local config = require('config')
local client = require('http.client').new()
local json   = require('json')
local logger = require('log')

local M = {}
M.queue = require('queue')

M.transport = {
  finder     = { sid = nil, fb = nil },
  sender     = { sid = nil, fb = nil },
  tunnel     = fiber.channel(1),
}

M.client_opts = {
  ['headers'] = {
    ['User-Agent']   = config.shipper.user_agent,
    ['X-Auth-Token'] = config.shipper.token,
    ['Content-Type'] = 'application/json',
  }
}

-- Check if module can start
function M.can_start()
  local queue_status = M.queue ~= nil
  local shipper_status = config.shipper.enable == true
  return (queue_status and shipper_status)
end

-- Pack task before send to app
function M.serialize(task)
  return {
    task_id = task['task_id'],
    queue   = task['tube'],
    data    = task[3]
  }
end

-- Taking the new task from channel
-- and send to the external app
function M.sender_worker()
  local webhook = config.shipper.webhook_url
  local options = M.client_opts
  local queue   = M.queue

  -- Save fiber session id
  M.transport.sender.sid = queue.identify()
  while true do
    if M.transport.tunnel:is_empty() then
      logger.debug('Sender: channel is empty')
      fiber.testcancel()
      fiber.sleep(config.shipper.task_check)
    else
      local task = M.transport.tunnel:get(0)
      logger.debug('Sender: received new task')
      local success, push_err = pcall(function()
        return client:post(webhook, json.encode(task), options)
      end)
      if success then
        local tube_name = task['tube']

        -- Before call ack need apply finder's session
        -- or will be raised 'Task was not taken'
        queue.identify(M.transport.finder.sid)
        local ok, resp = pcall(function()
          return M.queue.tube[tube_name]:ack(task['task_id'])
        end)
        if ok then
          logger.info('Sender: task %s#%s has been shipped', task['task_id'], task['tube'])
        else
          logger.error('Sender: failed to ack task, %s', tostring(resp))
        end
      else
        logger.error('Sender: failed to shipped task: ' .. tostring(push_err))
      end
      fiber.testcancel()
      fiber.sleep(config.shipper.task_check)
    end
  end
end

-- Iterating over tubes, find new task
-- and pass to the sender_worker
function M.finder_worker()
  local queue = M.queue
  M.transport.finder.sid = queue.identify()
  while true do
    queue.identify(M.transport.finder.sid)
    for tube_name, _ in pairs(queue.tube) do
      local success, item = pcall(function()
        return queue.tube[tube_name]:take(0)
      end)
      if success and item ~= nil then
        local task = M.serialize(item)
        task['tube'] = tube_name
        M.transport.tunnel:put(task)
        logger.verbose('Finder: found new task')
      else
        logger.verbose('Finder: waiting for new task...')
      end
    end
    fiber.testcancel()
    fiber.sleep(config.shipper.task_check)
  end
end

-- Run shipper
function M.start()
  if M.can_start() then
    -- Start workers
    local finder = M.transport.finder
    finder.fb = fiber.create(M.finder_worker)
    finder.fb:name('finder')
    local sender = M.transport.sender
    sender.fb = fiber.create(M.sender_worker)
    sender.fb:name('sender')

    return true
  else
    logger.error('Failed to start workers')
    return false
  end
end

-- Stop shipper
function M.stop()
  local finder = M.transport.finder
  local sender = M.transport.sender
  for fib in pairs({finder, sender}) do
    fib.fb:kill();
  end
end

return M