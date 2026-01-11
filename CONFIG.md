# config.json
In order to set up advanced configuration, you need to create a file named `config.json` and place it in a folder named `finalize` on the root of the SD card.

The default config can be seen [here](data/config.json). Here's an example for how you would make one of these config files (this one disables checking for a MSET9 ID1):
```json
{
    "checkExploit": {
        "mset9": false
    }
}
```
Here's a list of all the keys, their valid values and what they do.

## checkExploit
This object contains config for checking for remnants of exploits that should have been removed earlier on in the installation of custom firmware.

### mset9
Valid values: `true` (default), `false`

This checks whether a MSET9 ID1 exists, and if it does, it displays an error explaining that the user forgot to remove it and attempts to remove it after requesting permission. After it is removed, the script has the user remove and reinsert the SD card to continue to remount the `A:` drive.

### menuhax67
Valid values: `true` (default), `false`

This checks whether the menuhax67 exploit is installed, and if it is, asks the user for permission to remove it. This uses the [`configSavegame.lua`](data/luapackages/configSavegame.lua) library.

## apps
Contains booleans `Anemone3DS`, `Checkpoint`, `FBI`, `ftpd`, `Homebrew_Launcher`, and `Universal-Updater`.

These options can be modified within the script's menu.

## gm9
Valid values: `true` (default), `false`

Copies `GodMode9.firm` to `0:/luma/payloads` and `GM9Megascript.gm9` to `0:/gm9/scripts`

This *does not* change whether GodMode9 is copied to the NAND via payloadCopy.

## payloadCopy
Valid values: `"all"`, `"GodMode9"` (default), `false`

* If `"all"`: Copies all payloads from `0:/luma/payloads` to `1:/sys/rw/luma/payloads` after GodMode9 is copied to the SD card (if enabled).
* If `"GodMode9"`: Only copies GodMode9.firm from the romfs directly to `1:/sys/rw/luma/payloads`
* If `false`: Does not make any copies of payloads on the NAND.

This option *cannot* be modfied within the script's menu because GodMode9 provides brick protection.

## dspDump
Valid values: `true` (default), `false`

Dumps the DSP firmware to `0:/3ds/dspfirm.cdc`. This does essentially the same thing as navigating to `Miscellaneous options...` > `Dump DSP firmware` in the Rosalina menu.

## nullifyUserTimeOffset
Valid values: `true` (default), `false`

This does essentially the same thing as navigating to `Miscellaneous options...` > `Nullify user time offset` in the Rosalina menu. 

This option can be modified within the script's menu because there is some debate about whether it should be done or not, and ultimately, it doesn't really make much difference.

## nandBackup
Valid values: `true` (default), `"essential"`, `false`

* If `true`: Creates backups of `nand_minsize.bin` (alongside a `.sha` SHA256 hash file) and `essential.exefs` in `0:/gm9/backups`
* If `"essential"`: Only creates a backup of `essential.exefs` in `0:/gm9/backups`
* If `false`: NAND backup is skipped. `complete_backupflag.png` is shown at the end of the script.

## copyBootFirmToNAND
Valid values: `true`, `false` (default)

Copies `0:/boot.firm` to `1:/boot.firm` so that the console can boot without a SD card inserted. Largely unnecessary since Luma3DS v11.0+ copies itself to the NAND whenever Luma3DS is updated or launched for the first time, but there are some situations where it might not be copied.