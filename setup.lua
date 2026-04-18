local config = dofile("/os/.config.lua")

shell.run("clear")
term.clear()

term.setCursorPos(1,1)
term.write("Installing " .. config.OS_NAME)
term.setCursorPos(1,2)
term.write("Installing " .. config.OS_VER)