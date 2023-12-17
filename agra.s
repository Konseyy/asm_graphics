.text
.align 2
.global pixel
.type pixel, %function
.global setPixColor
.type setPixColor, %function
.global line
.type line, %function
.global triangleFill
.type triangleFill, %function
.global circle
.type circle, %function

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
  cmp r9, #0 // if step count == 0
  beq end
  mov r10, #0 // r10 = current step

  bl FrameBufferGetAddress // r0 = framebuffer base address
  mov r11, r0 // r2 = framebuffer base address

line_loop:
  cmp r10, r9 // if current step > step count
  bgt end
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
  mov r2, r11
  bl pixel
  @ b end
  add r10, r10, #1 // current step++
  b line_loop

@ triangleFill(int x1, int y1, int x2, int y2, int x3, int y3)
triangleFill:
  mov r4, r0 // r4 = x1
  mov r5, r1 // r5 = y1
  mov r6, r2 // r6 = x2
  mov r7, r3 // r7 = y2
  ldr r8, [sp, #0] // r8 = x3
  ldr r9, [sp, #4] // r9 = y3

  stmfd sp!, {r4-r12, lr}


  bl FrameBufferGetAddress // r0 = framebuffer base address
  mov r10, r0 // r10 = framebuffer base address

  mov r0, r4 // r0 lowest x value
  cmp r0, r6 // if x1 > x2
  movgt r0, r6 // r0 = x2
  cmp r0, r8 // if x0 > x3
  movgt r0, r8 // r0 = x3

  mov r1, r5 // r1 lowest y value
  cmp r1, r7 // if y1 < y2
  movgt r1, r7 // r1 = y2
  cmp r1, r9 // if y0 < y3
  movgt r1, r9 // r1 = y3

  mov r2, r4 // r2 highest x value
  cmp r2, r6 // if x1 < x2
  movlt r2, r6 // r2 = x2
  cmp r2, r8 // if x2 < x3
  movlt r2, r8 // r2 = x3

  mov r3, r5 // r3 highest y value
  cmp r3, r7 // if y1 < y2
  movlt r3, r7 // r3 = y2
  cmp r3, r9 // if y2 < y3
  movlt r3, r9 // r3 = y3

  mov r11, r1 // r11 = y_min

for_x:
  cmp r0, r2 // if x_min > x_max
  bgt after_loop // finish loop
  mov r1, r11
for_y:
  cmp r1, r3 // if y_min > y_max
  addgt r0, r0, #1 // x0++
  bgt for_x // next x

  // loop body
  stmfd sp!, {r0-r11} // save everything

  mov r2, r4
  mov r3, r5
  mov r4, r6
  mov r5, r7
  mov r6, r8
  mov r7, r9

  // P = {r0, r1}
  // A = {r2, r3}
  // B = {r4, r5}
  // C = {r6, r7}

  // https://stackoverflow.com/a/2049593
  // (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
  // D1 = sign of P A B
  sub r8, r0, r4
  sub r9, r3, r5

  mul r10, r8, r9
  mov r8, r10

  sub r10, r2, r4
  sub r11, r1, r5

  mul r9, r10, r11

  sub r8, r8 ,r9 // D1 = sign of P A B
  cmp r8, #0 // if D1 == 0
  mov r9, #0
  movlt r9, #-1 // r9 = -1 if D1 < 0
  movgt r9, #1 // r9 = 1 if D1 > 0
  stmfd sp!, {r9}

  // D2 = sign of P B C
  sub r8, r0, r6
  sub r9, r5, r7

  mul r10, r8, r9
  mov r8, r10

  sub r10, r4, r6
  sub r11, r1, r7

  mul r9, r10, r11

  sub r8, r8 ,r9 // D2 = sign of P B C
  cmp r8, #0 // if D2 == 0
  mov r9, #0
  movlt r9, #-1 // r9 = -1 if D2 < 0
  movgt r9, #1 // r9 = 1 if D2 > 0
  stmfd sp!, {r9}

  // D3 = sign of P C A
  sub r8, r0, r2
  sub r9, r7, r3

  mul r10, r8, r9
  mov r8, r10

  sub r10, r6, r2
  sub r11, r1, r3

  mul r9, r10, r11

  sub r8, r8 ,r9 // D3 = sign of P C A
  cmp r8, #0 // if D3 == 0
  mov r9, #0
  movlt r9, #-1 // r9 = -1 if D3 < 0
  movgt r9, #1 // r9 = 1 if D3 > 0
  stmfd sp!, {r9}
  // Finished calculating signs

  ldmfd sp!, {r0-r2}
  // r0 = d1
  // r1 = d2
  // r2 = d3
  add r0, r0, r1 // d1 + d2
  add r0, r0, r2 // d1 + d2 + d3
  cmp r0, #0
  rsblt r0, r0, #0 // r0 = -r0
  cmp r0, #3 // if d1 + d2 + d3 == 3  ---- all signs were the same --- in triangle

  ldmfd sp!, {r0-r11} // restore everything
  beq in_triangle // if in triangle
  b check_next // if not in triangle


in_triangle:
  mov r2, r10 // r2 = framebuffer base address
  stmfd sp!, {r0-r3} // save x0, y0, x_max, y_max
  bl pixel // draw pixel
  ldmfd sp!, {r0-r3}
check_next:
  // cleanup
  add r1, r1, #1 // y0++
  b for_y // next y


after_loop:
  ldmfd sp!, {r4-r12, lr}
  bx lr // return


// circle(int x1, int y1, int radius)
circle:
  stmfd sp!, {r4-r12, lr}
  mov r4, r0 // r4 = x1
  mov r5, r1 // r5 = y1
  mov r6, r2 // r6 = radius
  mov r7, #0 // x offset
  mov r8, r6 // y offset
  rsb r9, r6, #1 // d

  bl FrameBufferGetAddress // r0 = framebuffer base address
  mov r10, r0 // r10 = framebuffer base address

circle_loop:
  cmp r7, r8 // if x_offset > y_offset
  bgt end // finish loop
  add r0, r4, r7 // x0 = x1 + x_offset
  add r1, r5, r8 // y0 = y1 + y_offset
  mov r2, r10
  bl pixel // draw pixel
  sub r0, r4, r7 // x0 = x1 - x_offset
  add r1, r5, r8 // y0 = y1 + y_offset
  mov r2, r10
  bl pixel // draw pixel
  add r0, r4, r7 // x0 = x1 + x_offset
  sub r1, r5, r8 // y0 = y1 - y_offset
  mov r2, r10
  bl pixel // draw pixel
  sub r0, r4, r7 // x0 = x1 - x_offset
  sub r1, r5, r8 // y0 = y1 - y_offset
  mov r2, r10
  bl pixel // draw pixel
  add r0, r5, r8 // x0 = y1 + y_offset
  add r1, r4, r7 // y0 = x1 + x_offset
  mov r2, r10
  bl pixel // draw pixel
  sub r0, r5, r8 // x0 = y1 - y_offset
  add r1, r4, r7 // y0 = x1 + x_offset
  mov r2, r10
  bl pixel // draw pixel
  add r0, r5, r8 // x0 = y1 + y_offset
  sub r1, r4, r7 // y0 = x1 - x_offset
  mov r2, r10
  bl pixel // draw pixel
  sub r0, r5, r8 // x0 = y1 - y_offset
  sub r1, r4, r7 // y0 = x1 - x_offset
  mov r2, r10
  bl pixel // draw pixel

  cmp r9, #0 // if d == 0
  blt d_less_than_zero
  b d_else

d_less_than_zero:
  add r9, r9, #3
  add r9, r9, r7, LSL #1
  b d_next
d_else:
  add r9, r9, #5
  sub r0, r7, r8
  add r9, r9, r0, LSL #1
  sub r8, r8, #1

d_next:
  add r7, r7, #1
  b circle_loop

@ (x, y) returns x/y
divide:
  stmfd sp!, {r4-r12, lr}
  mov r4, #1 // -1 if result negative, otherwise 1
  cmp r0, #0
  rsblt r0, r0, #0 // r0 = -x
  rsblt r4, r4, #0 // r4 *= -1
  cmp r1, #0
  rsblt r1, r1, #0 // r1 = -y
  rsblt r4, r4, #0 // r4 *= -1
  mov r2, #0 // r2 = result

  beq divide_by_zero

divide_loop:
  cmp r0, r1 // if x >= y
  blt divide_end
  sub r0, r0, r1 // x -= y
  add r2, r2, #1 // result++
  b divide_loop

divide_end:
  cmp r1, r0, LSL #1 // if y >= x * 2
  addge r0, r2, #1 // result++
  mul r0, r2, r4 // r0 = result * sign
  ldmfd sp!, {r4-r12, lr}
  bx lr // return

divide_by_zero:
  mov r0, #0
  ldmfd sp!, {r4-r12, lr}
  bx lr // return
   
end:
  ldmfd sp!, {r4-r12, lr}
  bx lr // return

f__i:     .word formati
f__r:     .word formatr
f__x:     .word formatx
f__y:     .word formaty
.data
formati:  .asciz "var: %d\n"
formatr:  .asciz "res: %d\n"
formatx:  .asciz "x: %d\n"
formaty:  .asciz "y: %d\n"
