shell.setDir("/")
package.path = "/cc-lock/?;/cc-lock/?.lua;/?;/?.lua;/?/init.lua;" .. package.path



if not fs.exists(".credentials") then
    print("Use the register command to lock the computer.")
else
    if not fs.exists("basalt.lua") then
        shell.run("wget run https://basalt.madefor.cc/install.lua packed basalt.lua master")
    end
    
    local shield = require("shield")
    shield(require('cc-lock.login'))

end
