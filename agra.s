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
  mov r2, r0
  mov r11, r0 // r11 = framebuffer base address
  sub r0, r7, r5 // r0 = delta x
  sub r1, r8, r6 // r1 = delta y
// End point no longer needed as we have deltas
  mov r7, r0 // r7 = delta x
  mov r8, r1 // r8 = delta y
  cmp r0, #0
  rsblt r0, r0, #0 // r0 = -delta x
  cmp r1, #0
  rsblt r1, r1, #0 // r1 = -delta y
  cmp r0, r1 // if delta x > delta y
  movgt r9, r0 // r9 = delta x
  movle r9, r1 // r9 = delta y
// r9 = step count
  mov r10, #0 // r10 = current step

line_loop:
  cmp r10, r9 // if current step >= step count
  bgt end
  stmfd sp!, {r2}
  mul r11, r10, r7 // r11 = current step * delta x
  mul r12, r10, r8 // r12 = current step * delta y
  stmfd sp!, {r12}
  mov r0, r11 // r0 = x0 + current step * delta x
  mov r1, r9 // r1 = step count
  bl divide // r0 = x_current
  ldmfd sp!, {r12} // restore r12
  stmfd sp!, {r0}// save x_current
  mov r0, r12 // r0 = y0 + current step * delta y
  mov r1, r9 // r1 = step count
  bl divide // r0 = y_current
  mov r1, r0 // r1 = y_current
  ldmfd sp!, {r0}// restore x_current
// draw pixel
  add r0, r0, r5 // x_increment += x0
  add r1, r1, r6 // y_icrement += y0
  ldmfd sp!, {r2} // restore framebuffer base address
  bl pixel
  add r10, r10, #1 // current step++
  b line_loop

@ (x, y) returns x/y
divide:
  stmfd sp!, {r5-r12, lr}
  @ r0 = dividend, r1 = divisor
  @ Result will be placed in r0
  stmfd sp!, {r5-r12, lr}
  mov r1, r0
  ldr r0, f__i
  bl printf
  ldmfd sp!, {r5-r12, lr}
  stmfd sp!, {r5-r12, lr}
  ldr r0, f__i
  bl printf
  ldr r0, f__i
  mov r1, #-111
  bl printf
  ldmfd sp!, {r5-r12, lr}
  @ Check for divisor = 0 to avoid division by zero
  cmp r1, #0
  beq divide_by_zero

  @ Preserve the sign of the result
  mrs r2, CPSR         @ Move the current program status register to r2
  eor r3, r0, r1       @ XOR dividend and divisor to check if signs are different
  bic r4, r2, #0x40000000     @ Clear the negative flag in r2
  orrne r4, r4, #0x40000000   @ Set the negative flag if signs are different

  @ Make dividend and divisor positive
  rsblt r0, r0, #0     @ If r0 is negative, negate it
  rsblt r1, r1, #0     @ If r1 is negative, negate it

  @ Initialize result and temporary counter
  mov r5, #0           @ r5 is the result
  mov r6, #1           @ r6 is a temporary counter

division_loop:
  cmp r1, r0, LSL#1        @ Compare divisor with (dividend shifted left by 1)
  movls r1, r1, LSL#1      @ Shift divisor left by 1 if it's less or equal
  movls r6, r6, LSL#1      @ Shift temporary counter left by 1 if divisor shifted
  bls division_loop

division_calculation:
  subs r0, r0, r1          @ Subtract divisor from dividend
  addcs r5, r5, r6         @ Add counter to result if subtraction did not borrow
  MOVS r6, r6, LSR#1       @ Shift counter right by 1
  MOVS r1, r1, LSR#1       @ Shift divisor right by 1
  bne division_calculation

  @ Apply rounding
  add r0, r5, #1           @ Add 1 for rounding
  asrs r0, r0, #1          @ Shift right to divide by 2 (rounding)
  orr r0, r0, r4           @ Apply the original sign to the result
  b end

divide_by_zero:
  mov r0, #0
  b end

end:
  ldmfd sp!, {r5-r12, lr}
  bx lr // return

f__i:     .word formati
.data
formati:  .asciz "from assembly: %d\n"
