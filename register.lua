if not fs.exists("basalt.lua") then
    shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
end

require('cc-lock.register')

