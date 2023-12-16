.text
.align 2
.global pixel
.type pixel, %function
.global setPixColor
.type setPixColor, %function
.global line
.type line, %function
.global divide
.type divide, %function

@ pixel(x, y, *color)
pixel:
  stmfd sp!, {r4-r12, lr}
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
  stmfd sp!, {r4-r12, lr}
  mov r5, r0 // r5 = color pointer
  bl FrameBufferGetAddress // r0 = framebuffer base address
  ldr r3, [r5] // r3 = color
  str r3, [r0] // store color at the framebuffer address
  b end

@ line(x0, y0, x1, y1)
line:
  stmfd sp!, {r4-r12, lr}
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
  cmp r7, #0
  rsblt r0, r0, #0 // r0 = -delta x
  cmp r8, #0
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
  mul r0, r10, r7 // r0 = current step * delta x
  mov r1, r9 // r1 = step count
  bl divide // r0 = x_current
  stmfd sp!, {r0}// save x_current
  mul r0, r10, r8 // r12 = current step * delta y
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
  mov r2, #0  // Initialize quotient
  cmp r1, #0  // Check if divisor is 0
  beq div_end     // If divisor is 0, end the program to avoid division by zero
  cmp r0, #0  // Check if dividend is 0
  beq div_end     // If dividend is 0, end the program as the quotient is 0

  // Make dividend positive and remember if it was negative
  mov r3, #0  // Initialize flag for negative dividend
  cmp r0, #0  // Compare dividend with 0
  bge check_divisor  // If dividend is positive, check divisor
  rsb r0, r0, #0  // Make dividend positive
  mov r3, #1  // Set flag for negative dividend

check_divisor:
  // Make divisor positive and remember if it was negative
  mov r4, #0  // Initialize flag for negative divisor
  cmp r1, #0  // Compare divisor with 0
  bge start_division  // If divisor is positive, start division
  rsb r1, r1, #0  // Make divisor positive
  mov r4, #1  // Set flag for negative divisor

start_division:
  // Start division
  loop:
    cmp r0, r1  // Compare dividend with divisor
    blt end_loop  // If dividend is less than divisor, end loop
    sub r0, r0, r1  // Subtract divisor from dividend
    add r2, r2, #1  // Increment quotient
    b loop  // Repeat loop

end_loop:
  // If both dividend and divisor were negative or both were positive, quotient is positive
  // If one of them was negative, quotient is negative
  eor r3, r3, r4  // XOR flags for negative dividend and divisor
  cmp r3, #0  // Compare result with 0
  beq div_end  // If result is 0, end the program as the quotient is positive
  rsb r2, r2, #0  // Make quotient negative

div_end:
  mov r0, r2  // Move quotient to r0
  bx lr  // Return

end:
  ldmfd sp!, {r4-r12, lr}
  bx lr // return

f__i:     .word formati
.data
formati:  .asciz "from assembly: %d\n"
