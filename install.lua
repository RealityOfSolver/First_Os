-- installer.lua
-- GitHub Installer for CC:Tweaked
-- [R] = Reinstall (overwrite existing files)
-- [D] = Delete + reinstall
-- [C] = Cancel

local BASE_URL = "https://raw.githubusercontent.com/RealityOfSolver/First_Os/main/"

-- Put your files here (root files like ".config.lua" and folders like "os/.config.lua")
local files = {
    "os/.config.lua",
    "setup.lua",
}

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

local function downloadFile(path)
  ensureDir(path)

  local url = BASE_URL .. path
  print("Downloading: " .. path)

  local ok = shell.run("wget", "-f", url, path)

  if not ok then
    print("FAILED: " .. path)
    return false
  end

  return true
end

local function install(mode)
  if mode == "D" then
    print("")
    print("Deleting old files...")
    for _, f in ipairs(files) do
      if fs.exists(f) then
        print("Deleting: " .. f)
        deleteFile(f)
      end
    end
  end

  print("")
  print("Installing files...")

  local failed = {}

  for _, f in ipairs(files) do
    local ok = downloadFile(f)
    if not ok then
      table.insert(failed, f)
    end
  end

  print("")
  if #failed > 0 then
    print("INSTALL FINISHED WITH ERRORS!")
    print("Failed files:")
    for _, f in ipairs(failed) do
      print("- " .. f)
    end
    print("")
    print("Check if the files exist on GitHub and the branch is correct.")
  else
    print("INSTALL SUCCESS!")
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

install(mode)

shell.run("/setup.lua")