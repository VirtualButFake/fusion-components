local process = require("@lune/process")
local fs = require("@lune/fs")
local task = require("@lune/task")

function executeCommand(command, args)
    local data = process.spawn(command, args, {
        stdio = "inherit",
    })

    if data.code ~= 0 then
        error("Command failed with code " .. data.code)
    end

    return data
end

task.spawn(executeCommand, "rojo", { "sourcemap", "./sourcemap.project.json", "-o", "sourcemap.json", "--watch" })
task.wait(0.5) -- allow the sourcemap to be generated (prevents an annoying error)

if fs.isFile(".darklua.json") then
    task.spawn(executeCommand, "darklua", { "process", "src", "build", "--watch" })
    task.wait(0.5) -- allow darklua to generate a build, so that rojo doesn't refer to unknown paths and error
end

task.spawn(executeCommand, "rojo", { "serve", fs.isFile("dev.project.json") and "dev.project.json" or "default.project.json" })
