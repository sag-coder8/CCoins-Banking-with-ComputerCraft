-- CCoins Client - Clean UI with Arrow Keys
local BANK_ID = 3   -- <<< CHANGE TO YOUR BANK COMPUTER ID !!!
local PLAYER = os.getComputerLabel() or "Unknown"

rednet.open("back")

local function clear()
    term.clear()
    term.setCursorPos(1,1)
end

local function sendCommand(cmdTable)
    rednet.send(BANK_ID, cmdTable)
    local id, resp = rednet.receive(nil, 5)
    return resp
end

local function register()
    clear()
    print("=== Register Account ===")
    print("Choose 4-digit PIN:")
    local pin = read()
    if #pin ~= 4 then
        print("PIN must be 4 digits!")
        os.sleep(2)
        return
    end
    local resp = sendCommand({cmd = "REGISTER", player = PLAYER, pin = pin})
    print(resp and resp.msg or "No response")
    os.sleep(2)
end

local function checkBalance()
    local resp = sendCommand({cmd = "BALANCE", player = PLAYER})
    clear()
    print("=== Your Balance ===")
    if resp and resp.balance then
        print(resp.balance .. " CCoins")
    else
        print("Error getting balance")
    end
    print("\nPress any key to return...")
    os.pullEvent("key")
end

local function transfer()
    clear()
    print("=== Transfer CCoins ===")
    print("Target username:")
    local target = read()
    print("Amount:")
    local amount = tonumber(read())
    print("Your PIN:")
    local pin = read()

    if not amount or amount <= 0 then
        print("Invalid amount")
        os.sleep(2)
        return
    end

    local resp = sendCommand({cmd = "TRANSFER", player = PLAYER, target = target, amount = amount, pin = pin})
    print(resp and (resp.success and resp.msg or "Failed: " .. (resp.msg or "Unknown error")) or "No response from bank")
    os.sleep(3)
end

-- Main Menu with Arrow Navigation
local options = {
    "Check Balance",
    "Transfer CCoins",
    "Register Account",
    "Exit"
}

local selected = 1

while true do
    clear()
    print("=== CCoins Bank ===")
    print("Use up and down arrows, Enter to select\n")

    for i, option in ipairs(options) do
        if i == selected then
            print("> " .. option)
        else
            print("  " .. option)
        end
    end

    local event, key = os.pullEvent("key")
    
    if key == keys.up and selected > 1 then
        selected = selected - 1
    elseif key == keys.down and selected < #options then
        selected = selected + 1
    elseif key == keys.enter or key == keys.numPadEnter then
        if selected == 1 then
            checkBalance()
        elseif selected == 2 then
            transfer()
        elseif selected == 3 then
            register()
        elseif selected == 4 then
            clear()
            print("Goodbye!")
            break
        end
    end
end
