--[[
Script for https://3ds.hacks.guide/finalizing-setup
This script is not intended be run manually.
Credits have been moved to within the script's optional menu.
--]]
local scriptVersion = "2.0.0"
local lastModified = "2025-07-30"
local json = require('json')
local finalizeUtil = require('finalizeUtil')
local finalizeRomfs = "0:/finalize.romfs"

local langCodes = {
    English="en_US"
}

ui.show_png(CURRDIR .. "/language_select.png")

local languageNames = {}
for k, v in pairs(langCodes) do
    table.insert(languageNames, k)
end

local userSelection = ui.ask_selection("", languageNames)
if not userSelection then
    sys.power_off()
end
local languageSel = languageNames[userSelection]
local langCode = langCodes[languageSel]

-- Load temporary locale file, complete one is stored in finalize.romfs because all of the locales don't fit in VRAM
local tempLangPath = CURRDIR .. "/lang/" .. langCode .. ".json"
local lang = json.decode(fs.read_file(tempLangPath, 0, fs.stat(tempLangPath).size))

ui.show_text(lang["INIT_MESSAGE"])

if not fs.sd_is_mounted() then
    ui.echo(string.format("%s\n \n%s", lang["ERROR_26"], lang["ASK_FOR_HELP"]))
    sys.power_off()
end

-- Check for known-fake SD cards and warn the user about it
local sdCID = fs.read_file("M:/sd_cid.mem", 0xC, 0x3)
sdCID = util.bytes_to_hex(sdCID)
local fakeSDCards = {"003000", "000000", "0c0005"}
for i, v in ipairs(fakeSDCards) do
    if sdCID == v then
        ui.echo(string.format("%s", lang["INFO_34"]))
    end
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

local success, result = pcall(fs.img_mount, finalizeRomfs)
if not success then
    ui.echo(string.format(lang["ERROR_22"], expectedHash, gotHash) .. "\nImage mount failed... somehow?")
    sys.power_off()
end

local success, result = pcall(fs.copy, "G:/finalize", "9:/finalize", {overwrite=true, recursive=true, silent=true})
if not success then
    ui.echo(string.format(lang["ERROR_22"], expectedHash, gotHash) .. "\nCopying to RAM failed... somehow?")
    sys.power_off()
end

-- We're done with finalize.romfs now
fs.img_umount()


-- New locale files can now be mounted, some finalizeUtil functions become usable too.
local newLangPath = "9:/finalize/lang/" .. langCode .. ".json"
lang = json.decode(fs.read_file(newLangPath, 0, fs.stat(newLangPath).size))

-- Check for missing essentials
-- sys.check_embedded_backup() will fail if any of these files are missing. As well as nand_hdr.bin, but like lol
local missingEssential = ""

if not (fs.find("1:/rw/sys/SecureInfo_A") or fs.find("1:/rw/sys/SecureInfo_B")) then
    missingEssential = missingEssential .. "SecureInfo\n"
end

if not (fs.find("1:/rw/sys/LocalFriendCodeSeed_B") or fs.find("1:/rw/sys/LocalFriendCodeSeed_A")) then
    missingEssential = missingEssential .. "LocalFriendCodeSeed\n"
end

if not fs.find("1:/private/movable.sed") then
    missingEssential = missingEssential .. "movable.sed\n"
end

-- Check for essential.exefs, create if doesn't exist

local success = sys.check_embedded_backup()
if (not success) or (not fs.find("S:/essential.exefs")) then
    if missingEssential ~= "" then
        finalizeUtil.error(string.format(lang["ERROR_30"], missingEssential) .. "\n \n" .. lang["ASK_FOR_HELP"], "error30", true)
    else
        finalizeUtil.error(lang["ERROR_02"], "error02", true)
    end
end

local minBytes
if CONSOLE_TYPE == "O3DS" then
    minBytes = (1024 ^ 3)
else
    minBytes = (1024 ^ 3) * 1.4
end
local bytesFree = fs.stat_fs("0:/").free
if bytesFree < minBytes then
    finalizeUtil.error(string.format(lang["ERROR_04"], ui.format_bytes(minBytes), ui.format_bytes(bytesFree)), "error04", true)
end


ui.echo("The script finished without errors.\n(This script is still in development)")
sys.power_off()