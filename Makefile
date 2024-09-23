.PHONY: test

test:
	nvim --headless --noplugin -u scripts/init_test.vim -c "PlenaryBustedDirectory ./spec/ { minimal_init = './scripts/init_test.vim' }"
