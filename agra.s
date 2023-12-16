.text
.align 2
.global pixel
.type pixel, %function
.global setPixColor
.type setPixColor, %function
.global line
.type line, %function

@ pixel(x, y, *color)
pixel:
  stmfd sp!, {r5-r12, lr}
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
  mul r1, r5, r0 // x *= 4 (4 bytes per pixel)
  mul r2, r6, r8 // y *= width
  mul r3, r2, r0 // y *= 4 (4 bytes per pixel)
  add r5, r1, r3 // x += y (offset from the beginning of the framebuffer)
  add r5, r5, #4 // x += 4 (skip the first 4 bytes of the framebuffer)

  bl FrameBufferGetAddress // r0 = framebuffer base address
// Calculate the pixel address in r5
// Add the offset to the base address to get the pixel address
  add r5, r0, r5

// Load the 32-bit color value from the color pointer
  ldr r10, [r7]

// Store the color value at the pixel address of the framebuffer
  str r10, [r5]
  b end

@ setPixColor(*color)
setPixColor:
  stmfd sp!, {r5-r12, lr}
  mov r5, r0 // r5 = color pointer
  bl FrameBufferGetAddress // r0 = framebuffer base address
  ldr r3, [r5] // r3 = color
  str r3, [r0] // store color at the framebuffer address
  b end

@ line(x0, y0, x1, y1)
line:
  stmfd sp!, {r5-r12, lr}
  mov r5, r0 // r5 = x0
  mov r6, r1 // r6 = y0
  mov r7, r2 // r7 = x1
  mov r8, r3 // r8 = y1
  bl FrameBufferGetWidth
  mov r9, r0 // r9 = width
  bl FrameBufferGetHeight
  mov r10, r0 // r10 = height
  bl FrameBufferGetAddress // r0 = framebuffer base address
  mov r11, r0 // r11 = framebuffer base address
  @ mov r0, r5
  @ mov r1, r6
  @ mov r2, r11
  @ bl pixel // draw first pixel
  @ mov r0, r7
  @ mov r1, r8
  @ mov r2, r11
  @ bl pixel // draw second pixel
  @ b end
  sub r0, r7, r5 // r0 = delta x
  sub r1, r8, r6 // r1 = delta y
  // y1 coordinate no longer needed as we have the slope
  mov r8, r0 // r7 = delta x
  mov r12, r1 // r12 = delta y
  // slope = r8 / r12

line_loop:
  cmp r5, r6 // if x0 >= x1
  bgt end
  mov r0, r5
  mov r1, r6
  mov r2, r11
  bl pixel // draw pixel
  add r5, r5, #1 // x0++
  mul r0, r6, r8 // y0 * delta x
  add r0, r0, r12
  mov r1, r8
  bl divide // (y0 * d_x + d_y) / delta x
  mov r6, r0 // y0 = (y0 * d_x + d_y) / delta x
  b line_loop

@ (x, y) returns x/y
divide:
  mov r2, #0 @ r3 will hold the result
  mov r4, r1           @ Copy divisor to r4
  asr r4, r4, #1       @ r4 = r1 / 2 (half of divisor for rounding)

  add r0, r0, r4 @ Add half of divisor to dividend for rounding

division_loop:
@ Compare dividend with divisor
  cmp r0, r1
@ Subtract divisor from dividend if dividend >= divisor
  subcs r0, r0, r1
@ Increment result if subtraction was performed
  addcs r2, r2, #1
@ Repeat if dividend was greater or equal to divisor
  bcs division_loop
@ Move result to r0
  mov r0, r2
  bx lr // return

end:
  ldmfd sp!, {r5-r12, lr}
  bx lr // return
