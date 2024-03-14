.PHONY := builds finalize.romfs finalize_helper.firm clean 

all: builds/finalize_helper.firm

builds:
	@[ -d builds ] || mkdir -p builds

builds/finalize.romfs: builds
	@3dstool -c -t romfs --romfs-dir finalize --file $@

builds/finalize_helper.firm: builds/finalize.romfs
	@cp finalize_helper.gm9 GodMode9/data/autorun.gm9
	@$(MAKE) -C GodMode9 SCRIPT_RUNNER=1
	@cp GodMode9/output/GodMode9.firm $@

clean:
	@rm -rf builds
	@$(MAKE) -C GodMode9 clean
	@rm GodMode9/data/autorun.gm9
