local targetWords = { "TriggerServerEvent", "TriggerServerEventInternal" }
local foundScripts = {}

local ignoredResources = {
    ["es_extended"] = true,
    ["monitor"] = true,
    ["baseevents"] = true,
    ["oxmysql"] = true,
}

function BetterPrint(text, type)
    local types = {
        ["warning"] = "^7[^3 WARNING ^7] ",
        ["info"] = "^7[^5 INFO ^7] ",
        ["success"] = "^7[^2 SUCCESS ^7] ",
    }
    return print((types[type or "info"]) .. text)
end

function ScanResource(resourceName)
    local numFiles = GetNumResourceMetadata(resourceName, "client_script") or 0

    for j = 0, numFiles - 1 do
        local luaFilePath = GetResourceMetadata(resourceName, "client_script", j)
        if luaFilePath and not foundScripts[luaFilePath] then
            local fileContent = LoadResourceFile(resourceName, luaFilePath)
            if not fileContent then return end

            for line in fileContent:gmatch("[^\r\n]+") do
                for _, targetWord in ipairs(targetWords) do
                    if line:find(targetWord) then
                        foundScripts[luaFilePath] = true
                        BetterPrint(("An event was found in ^3%s^7"):format(resourceName), "warning")
                        BetterPrint(("Snippet: ^3%s^7"):format(json.encode(line):gsub("%s+", "")), "info")
                    end
                end
            end
        end
    end
end

RegisterCommand("findtriggers", function()
    local resources = GetNumResources()
    for i = 0, resources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if not ignoredResources[resourceName] then
            ScanResource(resourceName)
        end
    end
    BetterPrint("Scan complete!", "success")
end)
