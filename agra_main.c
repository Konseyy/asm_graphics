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

  // pixel(0, 0, &(pixcolor_t){1, 0, 0, 0});
  // pixel(1, 0, &(pixcolor_t){0, 1, 0, 0});
  // pixel(0, 1, &(pixcolor_t){0, 0, 1, 0});

  setPixColor(&(pixcolor_t){1, 0, 1, 0});

  printf("5/2 = %d, 5/3 = %d\n", divide(5, 2), divide(5, 3));

  line(19, 3, 0, 6);

  FrameShow();
  return 0;
}