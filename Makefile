all:
	arm-linux-gnueabi-gcc agra.s agra_main.c framebuffer.c -o agra
