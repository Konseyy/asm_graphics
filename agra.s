.text
.align 2
.global pixel
.type pixel, %function

pixel:
  mov r5, r0 // r5 = x
  mov r6, r1 // r6 = y
  mov r7, r2 // r7 = color pointer
  bl FrameBufferGetWidth
  mov r8, r0 // r8 = width
  bl FrameBufferGetHeight
  mov r9, r0 // r9 = height
  cmp r5, r8 // if x >= width
  bge end
  cmp r6, r9 // if y >= height
  bge end
  cmp r5, #0 // if x < 0
  blt end
  cmp r6, #0 // if y < 0
  blt end
  mov r0, #4
  mul r5, r5, r0 // x *= 4
  mul r6, r6, r8 // y *= width
  add r5, r5, r6 // x += y

  bl FrameBufferGetAddress // r0 = framebuffer base address
  // Calculate the pixel address in r5
  ADD r5, r0, r5           // Add the offset to the base address to get the pixel address

  // Load the color value
  LDR r10, [r7]            // Load the 32-bit color value from the color pointer

  // Store the color value at the pixel address
  STR r10, [r5]            // Store the color value in the framebuffer
end:
  bx lr // return
