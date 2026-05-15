-- vein_server.lua

local SERVER_CHANNEL = 777

local modem = peripheral.find("modem")

if not modem then
    error("No modem found")
end

modem.open(SERVER_CHANNEL)

print("Ore Vein Server Online")
print("Listening on channel " .. SERVER_CHANNEL)

local logFile = "vein_log.txt"

local function log(text)
    local h = fs.open(logFile, "a")

    h.writeLine(text)
    h.close()
end

while true do
    local event, side, channel, replyChannel, message, distance =
        os.pullEvent("modem_message")

    if channel == SERVER_CHANNEL then

        if type(message) == "table" and message.type == "scan" then

            local pos = message.position

            local line = ""

            if message.hasVein then
                line =
                    string.format(
                        "[FOUND] %s | Size=%s | Pos=%d,%d,%d | Dist=%.1f",
                        message.vein,
                        tostring(message.size),
                        pos and pos.x or 0,
                        pos and pos.y or 0,
                        pos and pos.z or 0,
                        distance
                    )

                print(line)
            else
                line =
                    string.format(
                        "[EMPTY] Pos=%d,%d,%d",
                        pos and pos.x or 0,
                        pos and pos.y or 0,
                        pos and pos.z or 0
                    )

                print(line)
            end

            log(line)
        end
    end
end
