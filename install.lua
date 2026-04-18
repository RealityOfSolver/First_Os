-- installer.lua
-- Robust GitHub Installer for CC:Tweaked
-- Repo: RealityOfSolver/First_Os
-- [R] = Reinstall (overwrite existing files)
-- [D] = Delete + reinstall
-- [C] = Cancel

-- IMPORTANT:
-- If HTTPS doesn't work on your server, change https -> http below.
local BASE_URL = "https://raw.githubusercontent.com/RealityOfSolver/First_Os/main/"

local files = {
    "os/.config.lua",
    "setup.lua",
}

local RETRIES = 3
local WAIT_SECONDS = 1

local function sleepSeconds(s)
    if sleep then sleep(s) end
end

local function fileExists(path)
    return fs.exists(path)
end

local function ensureDir(path)
    local dir = fs.getDir(path)
    if dir ~= "" and not fs.exists(dir) then
        fs.makeDir(dir)
    end
end

local function deleteFile(path)
    if fs.exists(path) then
        fs.delete(path)
    end
end

local function anyFilesExist()
    for _, f in ipairs(files) do
        if fileExists(f) then
            return true
        end
    end
    return false
end

local function askChoice()
    while true do
        print("")
        print("Some files already exist.")
        print("[R] Install normally (overwrite)")
        print("[D] Delete files then reinstall")
        print("[C] Cancel")
        write("Choice: ")

        local input = read()
        if input then input = input:upper() end

        if input == "R" or input == "D" or input == "C" then
            return input
        end

        print("Invalid choice. Please type R, D, or C.")
    end
end

local function drawProgress(current, total, filename)
    term.clear()
    term.setCursorPos(1, 1)

    print("==== First_OS Installer ====")
    print("Repo: RealityOfSolver/First_Os")
    print("Branch: main")
    print("")

    local percent = math.floor((current / total) * 100)

    print("Progress: " .. current .. "/" .. total .. " (" .. percent .. "%)")
    print("File: " .. filename)
    print("")

    local barWidth = 25
    local filled = math.floor((current / total) * barWidth)
    local bar = "[" .. string.rep("#", filled) .. string.rep("-", barWidth - filled) .. "]"
    print(bar)
    print("")
end

local function tryDownload(url, path)
    -- -f overwrites existing files
    return shell.run("wget", "-f", url, path)
end

local function downloadFile(path, index, total)
    ensureDir(path)

    local url = BASE_URL .. path

    for attempt = 1, RETRIES do
        drawProgress(index, total, path)
        print("Downloading...")
        print("Attempt " .. attempt .. "/" .. RETRIES)

        local ok = tryDownload(url, path)

        if ok and fs.exists(path) then
            return true
        end

        print("")
        print("Download failed: " .. path)

        if attempt < RETRIES then
            print("Retrying in " .. WAIT_SECONDS .. "s...")
            sleepSeconds(WAIT_SECONDS)
        end
    end

    return false
end

local function install(mode)
    if mode == "D" then
        term.clear()
        term.setCursorPos(1, 1)

        print("Deleting old files...")
        for _, f in ipairs(files) do
            if fs.exists(f) then
                print("Deleting: " .. f)
                deleteFile(f)
            end
        end
        sleepSeconds(0.5)
    end

    local failed = {}
    local total = #files

    for i, f in ipairs(files) do
        local ok = downloadFile(f, i, total)
        if not ok then
            table.insert(failed, f)
        end
    end

    term.clear()
    term.setCursorPos(1, 1)

    print("==== First_OS Installer ====")
    print("")

    if #failed > 0 then
        print("INSTALL FINISHED WITH ERRORS!")
        print("")
        print("Failed files:")
        for _, f in ipairs(failed) do
            print("- " .. f)
        end
        print("")
        print("Possible reasons:")
        print("- HTTP is disabled in CC:Tweaked config")
        print("- Wrong branch name (main/master)")
        print("- File path doesn't exist in GitHub")
        print("- GitHub blocked by server firewall")
        print("")
        return false
    else
        print("INSTALL SUCCESS!")
        print("")
        return true
    end
end

-- MAIN
term.clear()
term.setCursorPos(1, 1)

print("==== First_OS Installer ====")
print("Repo: RealityOfSolver/First_Os")
print("Branch: main")
print("")

local mode = "R"

if anyFilesExist() then
    mode = askChoice()
end

if mode == "C" then
    print("")
    print("Cancelled.")
    return
end

local ok = install(mode)

if ok then
    print("Starting setup.lua ...")
    sleepSeconds(1)

    if fs.exists("setup.lua") then
        shell.run("setup.lua")
    else
        print("setup.lua not found after install??")
    end
end