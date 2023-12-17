#include "agra.h"
#include <stdio.h>

int main()
{
  pixcolor_t *frameBuffer = FrameBufferGetAddress();
  int frameWidth = FrameBufferGetWidth();
  int frameHeight = FrameBufferGetHeight();

  pixel(25, 2, &(pixcolor_t){0x03ff, 0x03ff, 0x03ff, 0});

  setPixColor(&(pixcolor_t){0, 0, 0x03ff, 0});
  line(0, 0, 39, 19);

  setPixColor(&(pixcolor_t){0, 0x03ff, 0, 0});
  triangleFill(20, 13, 28, 19, 38, 6);

  setPixColor(&(pixcolor_t){0x03ff, 0, 0, 0});
  circle(20, 10, 7);

  FrameShow();
  return 0;
}