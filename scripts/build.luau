local process = require("@lune/process")
local fs = require("@lune/fs")

function executeCommand(command, args)
	local data = process.spawn(command, args, {
		stdio = "inherit",
	})

	if data.code ~= 0 then
		error("Command failed with code " .. data.code)
	end

	return data
end

if not fs.isDir("packages") and not fs.isDir("Packages") and fs.isFile("wally.toml") then
	executeCommand("lune", { "run", "scripts/install-packages" })
end

local hasDarkLua = fs.isFile(".darklua.json")

if not fs.isDir("build") then
	print("Creating build directory..")
	executeCommand("rojo", { "sourcemap", "sourcemap.project.json", "-o", "sourcemap.json" })
	executeCommand("darklua", { "process", "src", "build" })
end

executeCommand("rojo", { "sourcemap", "sourcemap.project.json", "-o", "sourcemap.json" })

if hasDarkLua then
	executeCommand("darklua", { "process", "src", "build" })
end

executeCommand("rojo", { "build", "default.project.json", "-o", "build.rbxlx" })
