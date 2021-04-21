local M = {}

-- Taken from https://t.me/tarantoolru/35012
M.dd = function(...)
   local x = debug.getinfo(2)
   local dbg = string.format('[%s:%d][%s]', x.source, x.currentline, x.name)
   local formatter_yaml = require('yaml').new()
   formatter_yaml.cfg {
      encode_invalid_numbers = true;
      encode_load_metatables = true;
      encode_use_tostring = true;
      encode_invalid_as_nil = true;
   }
   require('log').info('\n ++VAR DUMP++ %s %s \n  %s', dbg,
      require('json').encode({ debug.traceback() }),
   formatter_yaml.encode({ ... }))
end

return M