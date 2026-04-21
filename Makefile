.PHONY := builds finalize.romfs x_finalize_helper.firm clean 

all: builds/x_finalize_helper.firm

builds:
	@[ -d builds ] || mkdir -p builds

builds/finalize.romfs: builds
	@3dstool -c -t romfs --romfs-dir romfs --file $@

builds/x_finalize_helper.firm: builds/finalize.romfs
	@cp finalize.lua GodMode9/data/autorun.lua
	@cp data/language_select.png GodMode9/data/
	@cp -r data/lang GodMode9/data/
	@cp -r data/luapackages GodMode9/data/
	@sha256sum $< | awk '{print $$1}' > GodMode9/data/finalize-romfs-hash
	@$(MAKE) -C GodMode9 SCRIPT_RUNNER=1 AUTO_UNLOCK=1
	@cp GodMode9/output/GodMode9.firm $@
	@printf '\001' | dd conv=notrunc bs=1 seek=16 of=$@
clean:
	@rm -rf builds
	@$(MAKE) -C GodMode9 clean
	@rm -f GodMode9/data/autorun.lua
	@rm -f GodMode9/data/finalize-romfs-hash
	@rm -f GodMode9/data/language_select.png
	@rm -rf GodMode9/data/lang
	@rm -f GodMode9/data/luapackages/finalizeUtil.lua
	@rm -f GodMode9/data/luapackages/configSavegame.lua
