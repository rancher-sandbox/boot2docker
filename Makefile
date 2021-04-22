boot2tcl.iso:
	docker build -t boot2tcl/boot2tcl --pull --force-rm .
	docker run --rm boot2tcl/boot2tcl > boot2tcl.iso
