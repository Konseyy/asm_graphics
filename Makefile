all:
	arm-linux-gnueabi-gcc framebuffer.s agra_main.c framebuffer.c -o agra
