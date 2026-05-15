-- vein_scanner.lua

local SERVER_CHANNEL = 777
local REPLY_CHANNEL = 778

local SCAN_SPACING = 16 -- chunk-sized movement

rednet.open(peripheral.getName(peripheral.find("modem")))

local veinFinder = peripheral.find("coe_vein_finder")

if not veinFinder then
    error("No ore vein finder peripheral found")
end

local function send(data)
    modem.transmit(SERVER_CHANNEL, REPLY_CHANNEL, data)
end

modem = peripheral.find("modem")

if not modem then
    error("No modem attached")
end

modem.open(REPLY_CHANNEL)

local function getPos()
    local x, y, z = gps.locate(2)

    if not x then
        return nil
    end

    return {
        x = math.floor(x),
        y = math.floor(y),
        z = math.floor(z)
    }
end

local function scanCurrentChunk()
    local ok, veinId, size = veinFinder.search()

    local pos = getPos()

    local packet = {
        type = "scan",
        timestamp = os.epoch("utc"),
        position = pos,
        hasVein = ok
    }

    if ok then
        packet.vein = veinId
        packet.size = size
    end

    send(packet)

    print("Scan complete")

    if ok then
        print("Found vein:")
        print(veinId)
        print("Size: " .. tostring(size))
    else
        print("No vein")
    end
end

local function forwardSafe()
    while not turtle.forward() do
        turtle.dig()
        turtle.attack()
        sleep(0.4)
    end
end

local function moveChunk()
    for i = 1, SCAN_SPACING do
        forwardSafe()
    end
end

-- MAIN LOOP

while true do
    local cd = veinFinder.getCooldown()

    if not cd then
        print("Cooldown: " .. cd)
        sleep(cd / 20)
    end

    scanCurrentChunk()

    moveChunk()

    sleep(1)
end
