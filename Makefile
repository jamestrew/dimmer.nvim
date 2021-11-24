lint:
	luacheck lua/ --globals vim

fmt:
	stylua lua/

pr-ready: fmt lint
