--[[
Script for https://3ds.hacks.guide/finalizing-setup
This script is not intended be run manually.
Credits have been moved to within the script's optional menu.
--]]
local scriptVersion = "2.0.0"
local lastModified = "2026-01-18"
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
-- BuildEssentialBackup() will return 1 (failure) if any of these files are missing. As well as nand_hdr.bin, but like lol
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

ui.show_text("This script will make system file backups, install some homebrew applications, and finalize your CFW installation.\n\nFor more information on all the actions this script will take, go to:\nhttps://github.com/hacks-guide/finalize/blob/mane/README.md")
ui.echo("Press (A) to continue.")

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

-- Check for missing Nintendo 3DS folder

if not fs.exists("0:/Nintendo 3DS") == false then
    -- todo: come back to this once we handle nand backup
end

-- Okay, at this point, we have the Nintendo 3DS folder. But do we have A: ?

if not fs.exists("A:") then
    -- We don't. Why not?

    local success = pcall(fs.hash_file, "1:/private/movable.sed", 0x110, 0x10)
    if not success then
        -- At this stage, we have essential.exefs.
	    -- I could copy it. But how do we know that this isn't like, a failed/cancelled Manual Movable Moveover? The user might have been doing something.
        finalizeUtil.error(lang["ERROR_31"] .. "\n \n" .. lang["ASK_FOR_HELP"], "error31", true)
    end

    -- Okay, we have an ID0. Is it there?
    local sysID0 = "0:/Nintendo 3DS/" .. sys.sys_id0
    if not fs.exists(sysID0) then
        -- todo: come back to this once we handle nand backup (nospace)

        finalizeUtil.error(lang["INFO_33"], "error33", true)
    end

    local mset9Fixed
    local mset9UserID1 = fs.find(sysID0 .. "/????????????????????????????????_user-id1")
    local mset9AffectsUserID1 -- ugly someone will make this less gross later I hope
    if mset9UserID1 then
        mset9AffectsUserID1 = true
        finalizeUtil.error(lang["ERROR_18a"], "error18a", false)
        repeat
            local success = fs.allow("0:/Nintendo 3DS", {ask_all=true})
        until success == true
        local success = pcall(fs.move, mset9UserID1, string.sub(mset9UserID1, 50, 82), {no_cancel=true})
        if not success then
            finalizeUtil.error(lang["ERROR_19a"] .. " " .. lang["ASK_FOR_HELP"], "error19a", true)
        end
    end

    local mset9HaxID1 = fs.find(sysID0 .. "/*sdmc*b9")
    if mset9HaxID1 then
        if not mset9AffectsUserID1 then
            finalizeUtil.error(lang["ERROR_18b"], "error18b", false)
            repeat
                local success = fs.allow("0:/Nintendo 3DS", {ask_all=true})
            until success == true
        end
        local success = pcall(fs.remove, mset9HaxID1, {recursive=true})
        if not success then
            finalizeUtil.error(lang["ERROR_19b"] .. " " .. lang["ASK_FOR_HELP"], "error19b", true)
        end
        mset9Fixed = true
    end

    if mset9Fixed then
        ui.show_png("9:/finalize/img/mset9_reinsert.png")
        fs.switch_sd(lang["SWITCH_SD"])
        if not fs.exists("A:") then
            -- SYSID0 path exists at this point, yet not SYSNAND SD. Why?
            finalizeUtil.error(lang["ERROR_32"] .. "\n \n" .. lang["ASK_FOR_HELP"], "error32", true)
        end
    end
end

ui.echo("The script finished without errors.\n(This script is still in development)")
sys.power_off()