#include "agra.h"
#include <stdio.h>

int main()
{
  pixcolor_t *frameBuffer = FrameBufferGetAddress();
  int frameWidth = FrameBufferGetWidth();
  int frameHeight = FrameBufferGetHeight();

  for (int i = 0; i < frameWidth; i++)
  {
    for (int j = 0; j < frameHeight; j++)
    {
      pixel(i, j, &(pixcolor_t){1, 1, 1, 0});
    }
  }

  setPixColor(&(pixcolor_t){1, 0, 1, 0});
  line(19, 3, 0, 6);

  setPixColor(&(pixcolor_t){0, 1, 1, 0});
  line(10, 0, 44, 22);

  setPixColor(&(pixcolor_t){1, 1, 0, 0});
  triangleFill(10, 10, 20, 10, 15, 15);

  setPixColor(&(pixcolor_t){0, 0, 1, 0});
  circle(20, 10, 5);

  FrameShow();
  return 0;
}