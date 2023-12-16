#include "agra.h"

// void pixel(int x, int y, pixcolor_t *color)
// {
//   pixcolor_t *frameBuffer = FrameBufferGetAddress();
//   int frameWidth = FrameBufferGetWidth();
//   int frameHeight = FrameBufferGetHeight();
//   if (x >= 0 && x < frameWidth && y >= 0 && y < frameHeight)
//   {
//     frameBuffer[y * frameWidth + x] = *color;
//   }
// }

int main()
{
  pixcolor_t *frameBuffer = FrameBufferGetAddress();
  int frameWidth = FrameBufferGetWidth();
  int frameHeight = FrameBufferGetHeight();

  pixel(0, 0, &(pixcolor_t){1000, 0, 1000, 0});
  pixel(27, 4, &(pixcolor_t){0, 550, 1000, 0});

  FrameShow();
  return 0;
}