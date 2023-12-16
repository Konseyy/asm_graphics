#include "agra.h"

int main()
{
  pixcolor_t *frameBuffer = FrameBufferGetAddress();
  int frameWidth = FrameBufferGetWidth();
  int frameHeight = FrameBufferGetHeight();

  // pixel(0, 0, &(pixcolor_t){1000, 0, 1000, 0});
  // pixel(27, 4, &(pixcolor_t){0, 550, 1000, 0});


  for(int i=0; i< frameWidth; i++)
  {
    for (int j = 0; j < frameHeight; j++)
    {
      pixel(i, j, &(pixcolor_t){1, 1, 1, 0});
    }
  }

    pixel(0, 0, &(pixcolor_t){1, 0, 0, 0});
  pixel(1, 0, &(pixcolor_t){0, 1, 0, 0});
  pixel(0, 1, &(pixcolor_t){0, 0, 1, 0});

  FrameShow();
  return 0;
}