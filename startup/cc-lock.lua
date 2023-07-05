shell.setDir("/")
package.path = "/cc-lock/?;/cc-lock/?.lua;/?;/?.lua;/?/init.lua;" .. package.path



if not fs.exists(".credentials") then
    print("Use the register command to lock the computer.")
else
    local shield = require("shield")
    shield(require('cc-lock.login'))

end
