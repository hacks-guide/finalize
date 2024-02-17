# Troubleshooting script errors
*As of v1.6.0 (2024/02/03)*

## Script-integrated error checking (finalize.gm9)

- **ERROR**: "Error #01: No Nintendo 3DS folder"
- **CAUSE**: Script is outdated (error no longer exists). Was caused by lack of Nintendo 3DS folder before implementation of NOSPACE.
- **FIX  **: Update script

- **ERROR**: "Error #02: Missing essential.exefs"
- **CAUSE**: SYSNAND VIRTUAL:/essential.exefs does not exist, because the user denied GodMode9's prompt to make an essential.exefs backup
- **FIX  **: Tell the user to re-enter GodMode9 (by holding START on boot) and to say Yes (press A) to the essential.exefs backup prompt

- **ERROR**: "Error #03: Missing files" (also: 03a, 03b, 03c, 03d, 03e, 03f, 03g)
- **CAUSE**: Script is outdated (error no longer exists). Was caused by lack of 0:/finalize (which should no longer happen with scriptrunner).
- **FIX  **: Update script

- **ERROR**: "Error #04: No space"
- **CAUSE**: Insufficient space for NAND backup
- **FIX  **: Make sufficient space (.nospace as contingency)

- **ERROR**: "Error #05: No title database"
- **CAUSE**: Script is outdated (error has been renamed; if it says 'error' and not 'information', this version of the script will create a dummy title database)
- **FIX  **: Update script

- **ERROR**: "Information #05: No title database"
- **CAUSE**: title.db does not exist
- **FIX  **: Allow prompt to import title database
NOTE : If script release between 1.3.0 and 1.3.2, this will use the dummy title database, which will require reboot and DBRESET. This shouldn't happen as this version isn't known to be distributed anywhere

- **ERROR**: "Error #06: NAND backup fail"
- **CAUSE**: NAND backup failed to complete for some reason
- **FIX  **: Unknown (check for space/partition issues, try another SD card...)
NOTE : Will display as "#06*" on top screen if occuring during NOSPACE, as remaining SD space is not checked if Nintendo 3DS folder does not exist

- **ERROR**: "(Fatal) Error #07: No SD size"
- **CAUSE**: SD size check portion failed to run. Should not ever happen
- **FIX  **: Pray

- **ERROR**: "Error #08: Dummy title database"
- **CAUSE**: Script is outdated (error no longer exists)
- **FIX  **: Update script. Will most likely cause Error #16 (Title database mount fail) on a rerun. Alternatively, run user through DBRESET and rerun outdated script.

- **ERROR**: "Error #09: Unsupported GodMode9 version"
- **CAUSE**: Script is outdated (error no longer exists). Was caused by GodMode9 not being version 2.1.1.
- **FIX  **: Update script

- **ERROR**: "(Fatal) Error #10: Application install fail"
- **CAUSE**: Script is outdated (error no longer exists because the check did not make sense), but if this happens then something seriously wrong has happened
- **FIX  **: Pray

- **ERROR**: "Error #11: Missing donor database"
- **CAUSE**: Script is outdated (error no longer exists)
- **FIX  **: Update script or provide donor.db to SD:/finalize

- **ERROR**: "Error #12a: Copy title.db fail" (also 12b: Copy import.db fail)
- **CAUSE**: donor.db could not be copied to A:/dbs/title.db
- **FIX  **: Most likely due to MSET9 being applied and A:/ not being mounted, so try removing MSET9

- **ERROR**: "Fatal Error #13a: Fix CMAC fail" (also 13b)
- **CAUSE**: CMACs could not be fixed for title.db (13a) or import.db (13b)
- **FIX  **: Pray

- **ERROR**: "Error #14a: CIA install fail"
- **CAUSE**: CIA (Anemone3DS) is corrupt, or issue with title database
- **FIX  **: Check for title database issues, assuming there are none check for issues with Anemone3DS.cia / with the SD card, or use FBI for verbose error details

- **ERROR**: "Error #14b: CIA install fail" (also: 14c, 14d, 14e, 14f)
- **CAUSE**: CIA after Anemone3DS is corrupt, so at least one CIA succeeded installation but one of them failed
- **FIX  **: Most likely a corrupt file, so have user replace file in SD:/finalize (14b = Checkpoint; 14c = FBI; 14d = ftpd; 14e = HBL; 14f = U-U). Alternatively, sketchy SD card

- **ERROR**: "Fatal Error #15: File creation fail"
- **CAUSE**: 0:/gm9/flags/BACKUPFLAG could not be created
- **FIX  **: This might happen if someone runs through NOSPACE more than once, because GodMode9 will not be able to create a file if it already exists. Ensure user has a working NAND backup and if they do then they can continue normally (move NAND backup off of SD, run script as normal).

- **ERROR**: "Fatal Error #16: Title database mount fail"
- **CAUSE**: A:/title.db exists but could not be mounted
- **FIX  **: This may happen if user has a dummy title database, in which case allowing the prompt is fine. Otherwise user's SD might be failing and data should be backed up yesterday.

- **ERROR**: "Information #17: Duplicate NAND backup"
- **CAUSE**: 0:/gm9/flags/BACKUPFLAG exists, and 0:/Nintendo 3DS does not exist (user ran through NOSPACE more than once even though the NAND backup succeeded)
- **FIX  **: Verify user has a NAND backup, and if they do then they should continue NOSPACE (move NAND backup off of SD, move Nintendo 3DS folder back onto SD)

- **ERROR**: "Error #18: MSET9 detected"
- **CAUSE**: MSET9 detected because user ID0 folder has a folder with "_user-id1" appended to it
- **FIX  **: Remove MSET9 (manually if failed to remove through mset9.py/MSET9 Installer, i.e. Chromebook)

> NOTE: There are no errors #19 or #20; I have no idea why I skipped them, I think I thought I already used them when I didn't


## Scriptrunner-integrated error checking (finalize_helper.firm)

- **ERROR**: "Error #21: finalize.romfs not found"
- **CAUSE**: finalize.romfs could not be found in any of the checked locations (SD root, 3ds, Nintendo 3DS, DCIM, luma, /luma/payloads)
- **FIX  **: Have user place finalize.romfs in the right directory

- **ERROR**: "Error #22: finalize.romfs is invalid"
- **CAUSE**: finalize.romfs does not match finalize_helper.firm's hardcoded checksum (corrupted SD? outdated file/)
- **FIX  **: Replace finalize.romfs with freshly downloaded copy

- **ERROR**: "Information #23: finalize.romfs in wrong location
- **CAUSE**: finalize.romfs is placed in 0:/Nintendo 3DS (this folder requires additional consent from GodMode9)
- **FIX  **: Tell user to allow prompts, even though it says "this is not recommended"

- **ERROR**: "Error #24: SD is write-protected"
- **CAUSE**: Script failed to write "0:/WRITE" dummy file (thus, SD is locked)
- **FIX  **: Tell user to unlock SD; if SD is unlocked, try tape-over-the-switch method, otherwise SD card is likely failing
NOTE : You can emulate this by creating a file named WRITE with no file extension on root of SD

## Other script-related errors

- **ERROR**: FBI fails to install CIAs with error 0xD900458A
- **CAUSE**: Corrupted title database, likely caused by running dummy title database creation (from an outdated script) and then opening FBI via Download Play without resetting title database
- **FIX  **: Regardless, tell people to replace the dummy title database (DBRESET). Then, you can either have them install everything through FBI and then run the script again (redundant), or just tell people to run the script.

## Other documentation

### BACKUPFLAG

The script checks for the existence of SD:/gm9/flags/BACKUPFLAG (no file extension). If it exists, it will silently skip the NAND backup. This will be visible to the user through:

- The top screen displaying "Setup complete!*" with an asterisk
- A warning symbol next to the two NAND backup files on the top screen
- Additional text on the bottom screen highlighting that a NAND backup was not made because one already exists


### Checksums and changelog

For versions before migration to a Git repository, see [here](https://gist.github.com/lilyuwuu/8a7ce43263fe498b7fb0a403ea5eaff3).


