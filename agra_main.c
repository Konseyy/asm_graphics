#include "agra.h"

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

  pixel(0, 0, &(pixcolor_t){1, 0, 0, 0});
  pixel(1, 0, &(pixcolor_t){0, 1, 0, 0});
  pixel(0, 1, &(pixcolor_t){0, 0, 1, 0});

  line(2,3,10,28);

  FrameShow();
  return 0;
}