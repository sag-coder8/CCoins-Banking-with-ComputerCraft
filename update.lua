-- updater.lua - Self-Updatable Remote Updater
local BANK_ID = 3

local function clear()
    term.clear()
    term.setCursorPos(1,1)
end

clear()
print("=== CCoins Updater ===")
print("Contacting bank for updates...\n")

rednet.open("back")

rednet.send(BANK_ID, {cmd = "GET_UPDATE", player = os.getComputerLabel() or "Unknown"})

local _, response = rednet.receive(BANK_ID, 8)

if response and response.files then
    print("Downloading updates...")
    
    for _, f in ipairs(response.files) do
        print("→ " .. f.localFile)
        local resp = http.get(f.url)
        
        if resp then
            local code = resp.readAll()
            resp.close()
            
            if code and #code > 50 then
                local file = fs.open(f.localFile, "w")
                file.write(code)
                file.close()
                print("Updated")
            end
        else
            print("!!! Failed")
        end
    end
    
    print("\nUpdate complete!")
    os.sleep(1)
    
    if response.restart then
        shell.run("bank_client")
    end
else
    print("No update available.")
    os.sleep(1)
    shell.run("bank_client")
end
