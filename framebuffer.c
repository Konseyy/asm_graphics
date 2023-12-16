#include "agra.h"
#include <stdio.h>
#include <stdlib.h>

#define frameWidth 40
#define frameHeight 20

// Frame buffer that contains all pixels
// First element is used as currently set color
pixcolor_t *frameBuffer = 0;

// Kadra bufera sākuma adrese
pixcolor_t *FrameBufferGetAddress()
{
  // If buffer already exists, return it
  if (frameBuffer != 0)
    return frameBuffer;

  // If buffer does not exist, create it
  frameBuffer = malloc((frameWidth * frameHeight + 1) * sizeof(pixcolor_t));
  // Fill buffer with default color
  pixcolor_t *curr_color = &frameBuffer[0];
  (*curr_color).r = 0;
  (*curr_color).g = 0;
  (*curr_color).b = 0;
  (*curr_color).op = 0;
  for (int i = 0; i < frameHeight; i++)
  {
    for (int j = 0; j < frameWidth; j++)
    {
      pixcolor_t *pixel = &frameBuffer[i * frameWidth + j + 1];
      (*pixel).r = 0;
      (*pixel).g = 0;
      (*pixel).b = 0;
      (*pixel).op = 0;
    }
  }
  return frameBuffer;
};

// Kadra platums
int FrameBufferGetWidth()
{
  return frameWidth;
};

// Kadra augstums
int FrameBufferGetHeight()
{
  return frameHeight;
};

// Kadra izvadīšana uz "displeja iekārtas".
int FrameShow()
{
  for (int i = 0; i < frameHeight; i++)
  {
    for (int j = frameWidth - 1; j >= 0; j--)
    {
      pixcolor_t pixel = frameBuffer[i * frameWidth + j + 1];
      char color = ' ';
      if (pixel.r > 0 && pixel.g > 0 && pixel.b > 0)
      {
        color = '*';
      }
      else if (pixel.r > 0 && pixel.g > 0)
      {
        color = 'Y';
      }
      else if (pixel.r > 0 && pixel.b > 0)
      {
        color = 'M';
      }
      else if (pixel.g > 0 && pixel.b > 0)
      {
        color = 'C';
      }
      else if (pixel.r > 0)
      {
        color = 'R';
      }
      else if (pixel.g > 0)
      {
        color = 'G';
      }
      else if (pixel.b > 0)
      {
        color = 'B';
      }
      printf("%c", color);
    }
    printf("\n");
  }
  return 0;
};