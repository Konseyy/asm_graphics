#include "agra.h"


int main() {
  pixcolor_t *frameBuffer = FrameBufferGetAddress();
  int frameWidth = FrameBufferGetWidth();
  int frameHeight = FrameBufferGetHeight();

  FrameShow();
  return 0;
}