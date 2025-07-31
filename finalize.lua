--[[
Script for https://3ds.hacks.guide/finalizing-setup
This script is not intended be run manually.
Credits have been moved to within the script's optional menu.
--]]
local scriptVersion = "2.0.0"
local lastModified = "2025-07-30"
local json = require('json')
local finalizeRomfs = "0:/finalize.romfs"

local langCode = "en_US" -- translation support will be added later(TM)
local langPath = CURRDIR .. "/lang/" .. langCode .. ".json"
local lang = json.decode(fs.read_file(langPath, 0, fs.stat(langPath).size))

ui.show_text(lang["INIT_MESSAGE"])

if not fs.sd_is_mounted() then
    ui.echo(string.format("%s\n \n%s", lang["ERROR_26"], lang["ASK_FOR_HELP"]))
    sys.power_off()
end

local minBytes
if CONSOLE_TYPE == "O3DS" then
    minBytes = (1024 ^ 3)
else
    minBytes = (1024 ^ 3) * 1.4
end
local bytesFree = fs.stat_fs("0:/").free
if bytesFree < minBytes then
    ui.echo(string.format(lang["ERROR_04"], ui.format_bytes(minBytes), ui.format_bytes(bytesFree)))
end

local write = "0:/WRITE"
pcall(fs.remove, write)
local success = pcall(fs.make_dummy_file, write, 0x400)
if not success then
    ui.echo(string.format("%s\n \n%s", lang["ERROR_25"], lang["ASK_FOR_HELP"]))
    sys.power_off()
end
pcall(fs.remove, write)

local romfsCheckDirectoryList = {"0:", "0:/3ds", "0:/luma/payloads", "0:/luma", "0:/DCIM"}
local filenameMatchList = {"finalize.romfs", "finalize(*).romfs", "finalize (*).romfs"}
for _,dir in ipairs(romfsCheckDirectoryList) do
    for _,filename in ipairs(filenameMatchList) do
        local success, filesFound = pcall(fs.find_all, dir, filename)
        if success then
            for _,path in ipairs(filesFound) do
                if path ~= "0:/finalize.romfs" then
                    pcall(fs.remove, "0:/finalize.romfs")
                    pcall(fs.move, path, finalizeRomfs, {no_cancel = true, silent = true, overwrite = true})
                end
            end
        end
    end
end
for _,filename in ipairs(filenameMatchList) do
    local success, filesFound = pcall(fs.find_all, "0:/Nintendo 3DS/", filename)
    if success then
        for _,path in ipairs(filesFound) do
            ui.echo(lang["INFO_23"])
            pcall(fs.move, "0:/Nintendo 3DS/" .. path, finalizeRomfs, {no_cancel = true, silent = true, overwrite = true})
        end
    end
end

if not fs.exists("0:/finalize.romfs") then
    ui.echo(lang["ERROR_21"])
    sys.power_off()
end

local success, expectedHash = pcall(fs.read_file, CURRDIR.."/finalize-romfs-hash", 0, 64)
if not success then
    ui.echo(string.format("%s\n \n%s\nfinalize romfs hash file does not exist", lang["ERROR_00"], lang["ASK_FOR_HELP"]))
    sys.power_off()
end

local success, result = pcall(fs.hash_file, finalizeRomfs, 0, 0)
if not success then
    ui.echo(string.format(lang["ERROR_22"], expectedHash, "hash failed"))
    sys.power_off()
end
local gotHash = util.bytes_to_hex(result)

if gotHash ~= expectedHash then
    ui.echo(string.format(lang["ERROR_22"], expectedHash, gotHash))
    sys.power_off()
end

ui.echo("The script finished without errors.\n(This script is still in development)")
sys.power_off()