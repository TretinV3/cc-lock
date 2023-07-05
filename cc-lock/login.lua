
local sha1 = require("cc-lock.otp")("sha1")
local totp = require("cc-lock.otp")("totp")

local basalt = require('basalt')

local user = {}
local input = {}

function loadCredentials(filename)
    local filename = filename or ".credentials"
    local file = fs.open(filename, 'r')
    user = textutils.unserialiseJSON(file.readAll())
    file.close()
end

function loadTOTP()
    if user.totpSecret then user.instanceTOTP = totp.new(user.totpSecret, 6, "sha1", 30) end

    basalt.debug(user.totpSecret)
end

local authentificated = false;

local creditentialWindows;

local window = basalt.createFrame()

function login(username, password, code, hasCode)
    local correct = false;
    if hasCode then
        if #code == 6 then
            local now = math.floor(os.epoch("utc") / 1000)
            correct = totp.verify(user.instanceTOTP, code, now);    
        else
            correct = false
        end
    else
        correct = username == user.username and sha1.sha1(password) == user.password
    end

    if correct then
        basalt.stopUpdate()
    else
        local f = window:addMovableFrame()
            :setSize(20, 6)
            :setPosition("{parent.w / 2 - self.w / 2}", "{parent.h / 2  - self.h / 2}")
            :setBackground(colors.lightGray)
            :setZ(5)
            :setBorder(colors.gray)
            :show()

            f:addLabel()
            :setPosition(6, 2)
            :setBackground(colors.red)
            :setForeground(colors.gray)
            :setText("incorect")

            f:addLabel()
            :setPosition(4, 3)
            :setBackground(colors.red)
            :setForeground(colors.gray)
            :setText("creditential")

            

        f:addButton()
            :setSize(4, 1)
            :setText("ok")
            :setBackground(colors.black)
            :setForeground(colors.red)
            :setPosition("{parent.w / 2 - 2}", "{parent.h - 2}")
            :onClick(function()
                f:remove()
            end)

        window:setFocusedChild(f)
    end

    return correct
end

local function main()
    local pullEvent_old = os.pullEvent
    os.pullEvent = os.pullEventRaw

    loadCredentials()
    loadTOTP()


    

    creditentialWindows = window:addMovableFrame()
        :setSize(30, 14)
        :setPosition("{parent.w / 2 - self.w / 2}", "{parent.h / 2  - self.h / 2}")
        :setBackground(colors.gray)
        :setZ(1)


    creditentialWindows:addLabel()
        :setSize("{parent.w}", 1)
        :setBackground(colors.black)
        :setForeground(colors.lightGray)
        :setText(" Login")

    creditentialWindows:addButton()
        :setSize(1, 1)
        :setText("X")
        :setBackground(colors.black)
        :setForeground(colors.red)
        :setPosition("{parent.w - 1}", 1)
        :onClick(function()
            creditentialWindows:remove()
            sleep(0.1)
            basalt.stopUpdate()
            --shell.exit()
            os.reboot()
        end)

    creditentialWindows:addLabel()
        :setText(" Username")
        :setPosition(1, 3)
        :setForeground(colors.black)
    local identity = creditentialWindows:addInput()
        :setInputType('text')
        :setPosition(2, 4)
        :setSize(28, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.gray)

    creditentialWindows:addLabel()
        :setText(" Password")
        :setPosition(1, 6)
        :setForeground(colors.black)
    local password = creditentialWindows:addInput()
        :setInputType('password')
        :setPosition(2, 7)
        :setSize(28, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.gray)

    creditentialWindows:addButton()
        :setSize(15, 3)
        :setText("Login")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :setPosition("{parent.w / 2 - 2}", 11)
        :onClick(function()
            --debug(identity:getValue() .. ':' .. password:getValue())
            input.username = identity:getValue()
            input.password = password:getValue()
            if not user.instanceTOTP then
                authentificated = login(identity:getValue(), password:getValue())
            else
                creditentialWindows:hide()

                totpWindow()
            end
        end)

    basalt.autoUpdate()

    if not authentificated then
        --os.shutdown()
    else
        term.setTextColor(colors.white)
        print("Welcome!")
        os.pullEvent = pullEvent_old
    end
end

function totpWindow()
    local f = window:addMovableFrame()
        :setSize(30, 14)
        :setPosition("{parent.w / 2 - self.w / 2}", "{parent.h / 2  - self.h / 2}")
        :setBackground(colors.gray)
        :setZ(1)


    f:addLabel()
        :setSize("{parent.w}", 1)
        :setBackground(colors.black)
        :setForeground(colors.lightGray)
        :setText(" Login step 2")

    f:addButton()
        :setSize(1, 1)
        :setText("X")
        :setBackground(colors.black)
        :setForeground(colors.red)
        :setPosition("{parent.w - 1}", 1)
        :onClick(function()
            f:remove()
            --sleep(0.1)
            --basalt.stopUpdate()
            --shell.exit()
            --os.reboot()
            creditentialWindows:show()
        end)

    f:addLabel()
        :setText(" TOTP code")
        :setPosition(1, 3)
        :setForeground(colors.black)
    local code = f:addInput()
        :setInputType('number')
        :setPosition(2, 4)
        :setSize(7, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.gray)

    f:addButton()
        :setSize(15, 3)
        :setText("Login")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :setPosition("{parent.w / 2 - 2}", 11)
        :onClick(function()
            --debug(identity:getValue() .. ':' .. password:getValue())
            authentificated = login(input.usernamen, input.password, code:getValue(), true)


        end)
end

return main