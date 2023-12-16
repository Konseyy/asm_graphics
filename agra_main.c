#include "agra.h"

int main()
{
  pixcolor_t *frameBuffer = FrameBufferGetAddress();
  int frameWidth = FrameBufferGetWidth();
  int frameHeight = FrameBufferGetHeight();

  pixel(0, 0, &(pixcolor_t){1000, 0, 1000, 0});
  pixel(27, 4, &(pixcolor_t){0, 550, 1000, 0});
  pixel(0, 0, &(pixcolor_t){0, 550, 0, 0});
  pixel(1, 0, &(pixcolor_t){1000, 550, 1000, 0});
  pixel(0, 1, &(pixcolor_t){1000, 550, 0, 0});

  FrameShow();
  return 0;
}