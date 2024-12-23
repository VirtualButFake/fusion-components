local fs = require("@lune/fs")

local executeCommand = require("./lib/executeCommand")
local logger = require("./lib/logger").new(4)

if fs.isDir("packages") then
	fs.removeDir("packages")
end

executeCommand("wally", {
	"install",
}, nil, true)

if not fs.isDir("packages") then
	fs.writeDir("packages")
end

-- do this so the project file doesn't refer to files that don't exist and cause rojo to fail
if fs.isDir(".zap") then
	executeCommand("zap", { "src/server/network.zap" })
end

executeCommand("rojo", {
	"sourcemap",
	fs.isFile("sourcemap.project.json") and "sourcemap.project.json" or "default.project.json",
	"-o",
	"sourcemap.json",
})

if fs.isDir("Packages") then
	executeCommand("wally-package-types", {
		"--sourcemap",
		"sourcemap.json",
		"./Packages",
	}, nil, true)

	fs.move("./Packages", "./packages", true)
end

logger:info("Installed packages!")
