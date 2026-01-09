local events = require "adev-common.utils.events"
local adev_ai_assistant = Adev.ai_assistant

if adev_ai_assistant then
    return {
        adev_ai_assistant.plugin,
        enabled = adev_ai_assistant.enabled,
        cmd = adev_ai_assistant.command,
        event = { events.insert.enter },
        opts = adev_ai_assistant.opts,
    }
else
    return {}
end
