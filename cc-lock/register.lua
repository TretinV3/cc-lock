


local basalt = require("basalt")

local main = basalt.createFrame()

local debug = function(text)
    return
end

debug("Hello world")

local user = {};

local function registerWindows()
    local f = main:addMovableFrame()
        :setSize(30, 14)
        :setPosition("{parent.w / 2 - self.w / 2}", "{parent.h / 2  - self.h / 2}")
        :setBackground(colors.gray)
        :setZ(1)


    f:addLabel()
        :setSize("{parent.w}", 1)
        :setBackground(colors.black)
        :setForeground(colors.lightGray)
        :setText(" Register")

    f:addButton()
        :setSize(1, 1)
        :setText("X")
        :setBackground(colors.black)
        :setForeground(colors.red)
        :setPosition("{parent.w - 1}", 1)
        :onClick(function()
            f:remove()
            sleep(0.1)
            basalt.stopUpdate()
            --shell.exit()
            shell.run('clear')
        end)

    f:addLabel()
        :setText(" Username")
        :setPosition(1, 3)
        :setForeground(colors.black)
    local identity = f:addInput()
        :setInputType('text')
        :setPosition(2, 4)
        :setSize(28, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.gray)

    f:addLabel()
        :setText(" Password")
        :setPosition(1, 6)
        :setForeground(colors.black)
    local password = f:addInput()
        :setInputType('password')
        :setPosition(2, 7)
        :setSize(28, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.gray)

    f:addLabel()
        :setText(" Repeat password")
        :setPosition(1, 8)
        :setForeground(colors.black)
    local repeatPassword = f:addInput()
        :setInputType('password')
        :setPosition(2, 9)
        :setSize(28, 1)
        :setBackground(colors.lightGray)
        :setForeground(colors.gray)

    f:addLabel()
        :setText(" Auth 2")
        :setPosition(1, 12)
        :setForeground(colors.black)
    local auth2 = f:addCheckbox()
        :setPosition(9, 12)

    f:addButton()
        :setSize(15, 3)
        :setText("Register User")
        :setBackground(colors.green)
        :setForeground(colors.black)
        :setPosition("{parent.w / 2 - 2}", 11)
        :onClick(function()
            debug(identity:getValue() .. ':' .. password:getValue())

            register(identity:getValue(), password:getValue(), repeatPassword:getValue(), auth2:getValue())
        end)

    return f
end

function register(username, pass1, pass2, auth2)
    local error = nil;

    if (username == "") or (pass1 == "") then
        error = "Please fill the\n form"
    elseif #pass1 < 4 then
        error = "Pasword must be at\n least 4 long"
    elseif not (pass1 == pass2) then
        error = "Pasword mismatch"
    end



    if error then
        local f = main:addMovableFrame()
            :setSize(20, 6)
            :setPosition("{parent.w / 2 - self.w / 2}", "{parent.h / 2  - self.h / 2}")
            :setBackground(colors.lightGray)
            :setZ(5)
            :setBorder(colors.gray)
            :show()

        f:addLabel()
            :setPosition(2, 2)
            :setBackground(colors.red)
            :setForeground(colors.gray)
            :setText(error)

        f:addButton()
            :setSize(4, 1)
            :setText("ok")
            :setBackground(colors.black)
            :setForeground(colors.red)
            :setPosition("{parent.w / 2 - 2}", "{parent.h - 2}")
            :onClick(function()
                f:remove()
            end)

        main:setFocusedChild(f)
        return;
    end

    debug('registering')

    user.username = username
    user.password = pass1
    user.twoAuth = auth2

    if auth2 then
        authTwoWindows(username)
    else
        --loading = true;
        --local waiting = main:addThread()
        --waiting:start(showWaitingPage)
        saveCredential(nil, username, pass1)
        debug('done !')
        sleep(0.1)
        basalt.stopUpdate()
        --shell.exit()
        shell.run('clear')
        term.setTextColour(colors.white)
        term.write('Registration Complete !')
        sleep(2)
        os.reboot()
    end
end

-- function showWaitingPage()
--     local f = main:addMovableFrame()
--         :setSize(20, 6)
--         :setPosition("{parent.w / 2 - self.w / 2}", "{parent.h / 2  - self.h / 2}")
--         :setBackground(colors.lightGray)
--         :setZ(10)
--         :setBorder(colors.gray)
--         :show()

--     f:addLabel()
--         :setPosition(2, 2)
--         :setBackground(colors.lightGray)
--         :setForeground(colors.gray)
--         :setText('Registering Account\nPlease wait')

--     local dots = f:addLabel()
--         :setSize(4, 1)
--         :setText("")
--         :setBackground(colors.black)
--         :setForeground(colors.orange)
--         :setPosition("{parent.w / 2 - 2}", "{parent.h - 2}")

--     main:setFocusedChild(f)

--     local seconds = 0

--     while true do
--         seconds = seconds + 1;
--         debug("Running in the background:", seconds)
--         dots:setText(string.rep(".", seconds % 5))
--         os.sleep(0.5)
--     end
-- end

function saveCredential(filename, username, password, enable2FA, otpInstance)
    filename = filename or ".credentials"
    local file = fs.open(filename, 'w')
    local credentials = {
        username = username,
    }
    if enable2FA ~= nil then
        credentials.totpSecret = otpInstance.secret
    end
    local sha1 = require("cc-lock.otp")("sha1")
    local hpassword = sha1.sha1(password)
    credentials.password = hpassword
    file.write(
        textutils.serializeJSON(credentials)
    )
    file.close()

    --loading = false;
end

function genQRcode(uri)
    local qrencode = require("cc-lock.qrencode")

    local _, qrcode = qrencode.qrcode(uri)

    local screen = {}

    local height = math.ceil(#(qrcode) / 3)
    local width = math.ceil(#(qrcode) / 2)

    for y = 1, height * 3, 1 do
        local line = {}
        for x = 1, width * 2, 1 do
            line[x] = 0
        end
        screen[y] = line
    end

    for y = 1, #(qrcode), 1 do
        line = qrcode[y]
        for x = 1, #(line), 1 do
            if line[x] > 0 then
                screen[y][x] = 1
            end
        end
    end

    local foreground = '0'
    local background = 'f'

    function getFgColor(line, column)
        local charId = getCharId(line, column)
        if charId < 32 then
            return foreground
        else
            return background
        end
    end

    function getBgColor(line, column)
        local charId = getCharId(line, column)
        if charId < 32 then
            return background
        else
            return foreground
        end
    end

    function getCharId(line, column)
        local id = 0
        for localY = 3, 1, -1 do
            for localX = 2, 1, -1 do
                local screenAdd = screen[(line - 1) * 3 + localY][(column - 1) * 2 + localX]
                id = id * 2 + screenAdd
            end
        end
        return id
    end

    function getChar(line, column)
        local charId = getCharId(line, column)
        if charId < 32 then
            return string.char(charId + 128)
        else
            return string.char(63 - charId + 128)
        end
    end

    local image = {}

    for y = 1, height, 1 do
        imageLine = ""
        foregroundLine = ""
        backgroundLine = ""
        for x = 1, width, 1 do
            imageLine = imageLine .. getChar(y, x)
            foregroundLine = foregroundLine .. getFgColor(y, x)
            backgroundLine = backgroundLine .. getBgColor(y, x)
        end
        image[y] = {
            imageLine,
            foregroundLine,
            backgroundLine,
        }
    end


    local bimg = {
        version = "1.0.0",
        animated = false,
        [1] = image
    }

    return bimg;
end

function authTwoWindows(username)
    registerFrame:hide()

    local totp = require("cc-lock.otp")("totp")
    local util = require("cc-lock.otp")("util")

    local secretKey = util.random_base32()
    local otpInstance = totp.new(secretKey, 6, "sha1", 30)

    local uri = totp.as_uri(
        otpInstance,
        username,
        "CraftOS Lock"
    )

    user.otpInstance = otpInstance;

    local qrimage = genQRcode(uri)



    local f = main:addMovableFrame()
        :setSize(43, math.max(14, #qrimage[1] + 1))
        :setPosition("{parent.w / 2 - self.w / 2}", "{parent.h / 2  - self.h / 2}")
        :setBackground(colors.gray)
        :setZ(2)


    f:addLabel()
        :setSize("{parent.w}", 1)
        :setBackground(colors.black)
        :setForeground(colors.lightGray)
        :setText(" Register Step 2")

    f:addButton()
        :setSize(1, 1)
        :setText("X")
        :setBackground(colors.black)
        :setForeground(colors.red)
        :setPosition("{parent.w-1}", 1)
        :onClick(function()
            f:remove()
            registerFrame:show()
        end)

    local img = f:addImage()
        :setImage(qrimage)
        :setPosition(1, 2)

    f:addLabel()
        :setPosition("{parent.w/2+1}", 3)
        :setBackground(colors.gray)
        :setForeground(colors.lightGray)
        :setText("Your secret key is:\n" .. secretKey)

    f:addLabel()
        :setPosition("{parent.w/2+1}", 6)
        :setBackground(colors.gray)
        :setForeground(colors.lightGray)
        :setText("Enter your code:")

    local code = f:addInput()
        :setInputType('number')
        :setPosition("{parent.w/2+1}", 7)
        :setSize(7, 1)
        :setInputLimit(6)
        :setBackground(colors.black)
        :setForeground(colors.lightGray)

    f:addButton()
        :setSize(10, 3)
        :setText("Complete")
        :setBackground(colors.green)
        :setForeground(colors.gray)
        :setPosition("{parent.w/2+1}", 9)
        :onClick(function()
            debug("done !")

            verifyTOTP(code:getValue())

        end)
    end
    
    function verifyTOTP(code)

        local totp = require("cc-lock.otp")("totp")

        local now = math.floor(os.epoch("utc") / 1000)
        if #(code) < 6 then
            error = "Please enter a 6 digits code"
        elseif not totp.verify(
                user.otpInstance,
                code,
                now
            ) then
            error = "Incorect TOTP"
        else
            saveCredential(nil, user.username, user.password, true, user.otpInstance)

            --f:remove()
            sleep(0.1)
            basalt.stopUpdate()
            --shell.exit()
            shell.run('clear')
            print('Registration Complete !')
            sleep(2)
            os.reboot()
        end

end

registerFrame = registerWindows()

basalt.autoUpdate()
