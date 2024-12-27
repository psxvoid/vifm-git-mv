local function isGitDir()
	local exitStatus = vifm.run({ cmd = "if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then exit 1; else exit 0; fi;"})
	return exitStatus == 1
end
local function isGitDirPath(path)
	local exitStatus = vifm.run({ cmd = "if git -C '" .. path .."' rev-parse --is-inside-work-tree >/dev/null 2>&1; then exit 1; else exit 0; fi;"})
	return exitStatus == 1
end

local function debug()
	vifm.sb.info("Tabs count: " .. tostring(vifm.tabs.getcount()))
	local currentTabIndex = vifm.tabs.getcurrent()
	vifm.sb.info("Current tab index: " .. tostring(currentTabIndex))
	local currentTab = vifm.tabs.get({ index = currentTabIndex, other = false })
	vifm.sb.info("Current tab: " .. tostring(currentTab))

	local currentView = vifm.currview()
	vifm.sb.info("Current tab: " .. tostring(currentView))
	vifm.sb.info("View CWD (c): " .. currentView.cwd)

	local otherView = vifm.otherview()
	vifm.sb.info("Other tab: " .. tostring(otherView))
	vifm.sb.info("View CWD (o): " .. otherView.cwd)


	vifm.sb.info("Is Git DIR: " .. tostring(isGitDir()))
	vifm.sb.info("Is Git DIR (c): " .. tostring(isGitDirPath(currentView.cwd)))
	vifm.sb.info("Is Git DIR (o): " .. tostring(isGitDirPath(otherView.cwd)))
end

local function isGitAnnexRepoBoundary()
	local currentView = vifm.currview()
	vifm.sb.info("Current tab: " .. tostring(currentView))
	vifm.sb.info("View CWD (c): " .. currentView.cwd)

	local otherView = vifm.otherview()
	vifm.sb.info("Other tab: " .. tostring(otherView))
	vifm.sb.info("View CWD (o): " .. otherView.cwd)

	-- TODO: ensure the same repo
	-- TODO: detect git annex
	return isGitDirPath(currentView.cwd) and isGitDirPath(otherView.cwd)
end

local toTrash = {}
local lastOp = nil

local function getSourceFileName(event)
	local currentDir = vifm.currview().cwd
	local index = string.find(event.path, currentDir, 1, true)
	if index >= 0 then
		return string.sub(event.path, string.len(currentDir) + 2)
	end
end

local function getTargetFileName(event)
	return string.match(event.path, "vifm.Trash.%d+.%d+_(.*)")
end

vifm.events.listen({
	event = "app.fsop",
	---@param event vifm.events.FsopEvent
	handler = function(event)
		debug()
		vifm.sb.info("OP: " .. event.op .. ", FT: " .. tostring(event.fromtrash) .. ", DIR: " .. tostring(event.isdir))
		vifm.sb.info("source: " .. tostring(event.path))
		if event.op == "move" then
			if event.totrash then
				if (isGitAnnexRepoBoundary()) then
					if event.isdir then
						-- not implemented
					else
						if lastOp ~= "totrash" then
							toTrash = {}
						end
						local filename = getSourceFileName(event)
						vifm.sb.info("filename(s): " .. filename)
						toTrash[filename] = {
							name = filename,
							source = event.path,
						}
						lastOp = "totrash"
					end
				end
			elseif event.fromtrash then
				vifm.sb.info("File move detected.")
				if (isGitAnnexRepoBoundary()) then
					if event.isdir then
						-- not implemented
					else
						vifm.sb.info("git mv")
						local filename = getTargetFileName(event)
						vifm.sb.info("filename(d): " .. filename)
						if toTrash[filename] ~= nil then
							vifm.sb.info("works")
							local src = toTrash[filename].source
							local dst = event.path
							vifm.fs.mv(dst, src) --restore original location
							vifm.run("git mv '" .. src .. "' '" .. dst .."'") --TODO: handle fail status
						end
						lastOp = "fromtrash"
					end
				end
			else
			end
		end
	end,
})

return {}
