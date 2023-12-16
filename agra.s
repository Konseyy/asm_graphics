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
    stmfd sp!, {r4-r11, lr}    @ Save callee-saved registers and link register

    @ Check for division by zero
    cmp   r1, #0
    beq   division_by_zero    @ Branch to error handling if divisor is zero

    @ Preserve the signs of the dividend and divisor
    mov   r4, r0              @ r4 = dividend
    mov   r5, r1              @ r5 = divisor
    mov   r6, #0              @ r6 = 0 (to calculate the sign of the result)

    @ Check and make dividend positive
    tst   r4, r4              @ Test if r4 is negative
    rsbmi r4, r4, #0          @ Negate r4 if it's negative
    eormi r6, r6, #1          @ Toggle r6 if dividend was negative

    @ Check and make divisor positive
    tst   r5, r5              @ Test if r5 is negative
    rsbmi r5, r5, #0          @ Negate r5 if it's negative
    eormi r6, r6, #1          @ Toggle r6 if divisor was negative

    @ Perform division
    bl    unsigned_divide     @ Branch to unsigned division routine

    @ Apply sign to the result
    tst   r6, #1              @ Test the sign bit in r6
    rsbmi r0, r0, #0          @ Negate the result if sign bit is set

    ldmfd sp!, {r4-r11, lr}   @ Restore registers and link register
    bx    lr                  @ Return from function

division_by_zero:
    @ Handle division by zero here
    @ For this example, let's return a special error code (e.g., 0xFFFFFFFF)
    mov   r0, #0xFFFFFFFF
    ldmfd sp!, {r4-r11, lr}
    bx    lr

unsigned_divide:
    @ Inputs: r4 = dividend, r5 = divisor
    @ Output: r0 = result
    mov   r0, #0              @ Clear result register
    mov   r7, #1              @ Set r7 to 1 (counter for division loop)

division_loop:
    cmp   r5, r4, LSL #1      @ Compare shifted divisor with dividend
    movls r5, r5, LSL #1      @ Shift divisor left if it's less or equal
    movls r7, r7, LSL #1      @ Shift counter left if divisor shifted
    bls   division_loop

    @ Division calculation
    subs  r4, r4, r5          @ Subtract divisor from dividend
    addcs r0, r0, r7          @ Add counter to result if no borrow
    movs  r7, r7, LSR #1      @ Shift counter right
    movs  r5, r5, LSR #1      @ Shift divisor right
    bne   unsigned_divide     @ Continue if not finished

    bx    lr                  @ Return from unsigned_divide subroutine

end:
  ldmfd sp!, {r4-r12, lr}
  bx lr // return

f__i:     .word formati
.data
formati:  .asciz "from assembly: %d\n"
