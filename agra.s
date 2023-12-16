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
  bl FrameBufferGetAddress // r0 = framebuffer base address
  stmfd sp!, {r0} // save framebuffer base address
  mov r11, r0 // r11 = framebuffer base address
  sub r0, r7, r5 // r0 = delta x
  sub r1, r8, r6 // r1 = delta y
// End point no longer needed as we have deltas
  mov r7, r0 // r7 = delta x
  mov r8, r1 // r8 = delta y
  mov r2, #-1
  cmp r7, #0 // if delta x < 0
  mullt r0, r7, r2 // delta x *= -1
  cmp r8, #0 // if delta y < 0
  mullt r1, r8, r2 // delta y *= -1
  cmp r0, r1 // if delta x >= delta y
  movgt r9, r0 // r9 = delta x
  movle r9, r1 // r9 = delta y
// r9 = step count
  mov r10, #0 // r10 = current step

line_loop:
  ldr r0, f__i
  mov r1, r5 // r1 = x0
  bl printf
  cmp r10, r9 // if current step >= step count
  bgt line_end
  mul r11, r10, r7 // r11 = current step * delta x
  mul r12, r10, r8 // r12 = current step * delta y
  mov r0, r11 // r0 = x0 + current step * delta x
  mov r1, r9 // r1 = step count
  bl divide // r0 = x_current
  stmfd sp!, {r0}// save x_current
  mov r0, r12 // r0 = y0 + current step * delta y
  mov r1, r9 // r1 = step count
  bl divide // r0 = y_current
  mov r1, r0 // r1 = y_current
  ldmfd sp!, {r0}// restore x_current
// draw pixel
b end
  add r0, r0, r5 // x_increment += x0
  add r1, r1, r6 // y_icrement += y0
  ldmfd sp, {r2} // restore framebuffer base address
  bl pixel
  add r10, r10, #1 // current step++
  b line_loop

line_end:
  ldmfd sp!, {r2} // restore framebuffer base address
  ldmfd sp!, {r5-r12, lr}
  bx lr // return

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

f__i:     .word formati
.data
formati:  .asciz "from assembly: %d\n"
