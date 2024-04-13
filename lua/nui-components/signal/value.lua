local fn = require("nui-components.utils.fn")

local SignalValue = {}

SignalValue.__index = SignalValue
SignalValue.__tostring = fn.always("SignalValue")

function SignalValue.create(subject, key)
  local self = {
    _private = {
      key = key,
      subject = subject,
      observable = subject:map(function(value)
        return key ~= nil and value[key] or value
      end),
    },
  }

  return setmetatable(self, SignalValue)
end

function SignalValue:get_value()
  local val = self._private.subject:get_value()
  return self._private.key ~= nil and val[self._private.key] or val
end

function SignalValue:get_observer_value()
  return self._private.current_value
end

function SignalValue:get_observable()
  return self._private.observable:distinct_until_changed(vim.deep_equal)
end

function SignalValue:map(map_fn)
  self._private.observable = self._private.observable:map(map_fn)
  return self
end

function SignalValue:negate()
  self._private.observable = self._private.observable:map(function(value)
    return not value
  end)
  return self
end

function SignalValue:tap(tap_fn)
  self._private.observable = self._private.observable:tap(tap_fn)
  return self
end

function SignalValue:filter(pred_fn)
  self._private.observable = self._private.observable:filter(pred_fn)
  return self
end

function SignalValue:skip(n)
  self._private.observable = self._private.observable:skip(n)
  return self
end

function SignalValue:combine_latest(...)
  self._private.observable = self._private.observable:combine_latest(...)
  return self
end

function SignalValue:scan(scan_fn, initial_value)
  self._private.observable = self._private.observable:scan(scan_fn, initial_value)
  return self
end

function SignalValue:observe(on_next)
  if not self._private.subscription then
    self._private.subscription = self:get_observable():subscribe(function(value)
      self._private.current_value = value
      on_next(value)
    end, function(err)
      vim.notify(vim.inspect(err))
    end)
  end

  return self
end

function SignalValue:unsubscribe()
  if self._private.subscription then
    self._private.subscription:unsubscribe()
  end
end

function SignalValue:dup()
  return SignalValue.create(self._private.subject, self._private.key)
end

return SignalValue
