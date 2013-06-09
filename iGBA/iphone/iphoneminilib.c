
/*
  GP2X minimal library v0.5 by rlyeh, 2005.
 
  + GP2X video library with double buffering.
  + GP2X soundring buffer library with double buffering.
  + GP2X joystick library.
 
  Thanks to Squidge, Robster, snaff and NK, for the help & previous work! :-)
 
 
  What's new
  ==========
 
  0.5: patched sound for real stereo (using NK's solution); better init code.
 
  0.4: lots of cleanups; sound is threaded now, double buffered too; 8 bpp video support; better exiting code.
 
  0.3: shorter library; improved joystick diagonal detection.
 
  0.2: better code layout; public release.
 
  0.1: beta release
*/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include "gp2x.h"

#include "../common.h"

extern void gp2x_sound_frame(void *blah, void *bufferg, int samples);

__inline u32 coord_in_rect(int x, int y, int rectx, int recty, int rectw, int recth)
{
  if( x >= rectx && x <= rectx + rectw )
  {
    if( y >= recty && y <= recty + recth )
    {
      return 1;
    }
  }
  return 0;
}

u32 gp2x_get_mouse(int x, int y)
{
	u32 keys = 0;
	if( coord_in_rect(	x,	y,		         0,		     0,		99,		99) ) keys |= GP2X_L;
	if( coord_in_rect(	x,	y,		   320-100,		     0,		99,		99) ) keys |= GP2X_R;
	if( coord_in_rect(	x,	y,		     0+100,     480-100-100-50,	 	99,		99) ) keys |= GP2X_UP;
	if( coord_in_rect(	x,	y,  		       0+0, 	   480-100-100, 	99, 		99) ) keys |= GP2X_LEFT;
	if( coord_in_rect(	x,	y, 		     0+100,    	       480-100,		99, 		99) ) keys |= GP2X_DOWN;
	if( coord_in_rect(	x,	y,		 0+100+100, 	   480-100-100, 	99, 		99) ) keys |= GP2X_RIGHT;
	if( coord_in_rect(	x,	y,   		   480-100, 	       480-100, 	99, 		99) ) keys |= GP2X_START;
	if( coord_in_rect(	x,	y,  		         0, 	       480-100,		99, 		99) ) keys |= GP2X_SELECT;
	if( coord_in_rect(	x,	y, 	           480-100,    480-100-100-100, 	99, 		99) ) keys |= GP2X_X;
	if( coord_in_rect(	x,	y,   	       480-100-100,        480-100-100, 	99, 		99) ) keys |= GP2X_Y;
	if( coord_in_rect(	x,	y, 		   480-100,        480-100-100,		99, 		99) ) keys |= GP2X_A;
	if( coord_in_rect(	x,	y, 	       480-100-100, 	       480-100, 	99, 		99) ) keys |= GP2X_B;

	return keys;
}

void gp2x_getMillis(void) 
{
	//printf("getMillis()\n");

	struct timeval currentTime;
	gettimeofday(&currentTime, NULL);
	return (uint32)(((currentTime.tv_sec - _startTime.tv_sec) * 1000) +
	                ((currentTime.tv_usec - _startTime.tv_usec) / 1000));
}

unsigned long gp2x_joystick_read(void)
{
	static u32 gp2x_keys = 0;
	int eventType;
	float xUnit, yUnit;

	if (iPhone_fetchEvent(&eventType, &xUnit, &yUnit)) {
		int x = (int)((1.0 - yUnit) * _screenWidth);
		int y = (int)(xUnit * _screenHeight);

		long curTime = gp2x_getMillis();

		switch ((InputEvent)eventType) {
			case kInputMouseDown:
				//printf("Mouse down at (%u, %u)\n", x, y);
				_lastMouseDown = curTime;
				_mouseX = x;
				_mouseY = y;

				gp2x_keys |= gp2x_get_mouse(x, y);
				return gp2x_keys;

				break;
			case kInputMouseUp:
				//printf("Mouse up at (%u, %u)\n", x, y);

				if (curTime - _lastMouseDown < 250) {

					gp2x_keys &= ~(gp2x_get_mouse(_mouseX, _mouseY));
					_lastMouseTap = curTime;
					
					// if (curTime - _lastMouseTap < 250 && !_overlayVisible) {
					// 	event.type = Common::EVENT_KEYDOWN;
					// 	_queuedInputEvent.type = Common::EVENT_KEYUP;
					// 
					// 	event.kbd.flags = _queuedInputEvent.kbd.flags = 0;
					// 	event.kbd.keycode = _queuedInputEvent.kbd.keycode = Common::KEYCODE_ESCAPE;
					// 	event.kbd.ascii = _queuedInputEvent.kbd.ascii = 27;		
					// 							
					// 	_lastMouseTap = 0;
					// } else {
					// 
					// }
				} else {
					return gp2x_keys;
				}

				break;
			case kInputMouseDragged:
				//printf("Mouse dragged at (%u, %u)\n", x, y);
				if (_secondaryTapped) {
					int vecX = (x - _gestureStartX);
					int vecY = (y - _gestureStartY);
					int lengthSq =  vecX * vecX + vecY * vecY;
					//printf("Lengthsq: %u\n", lengthSq);

					if (lengthSq > 5000) { // Long enough gesture to react upon.
						_gestureStartX = x;
						_gestureStartY = y;
						
						float vecLength = sqrt(lengthSq);
						float vecXNorm = vecX / vecLength;
						float vecYNorm = vecY / vecLength;

						//printf("Swipe vector: (%.2f, %.2f)\n", vecXNorm, vecYNorm);

						if (vecXNorm > -0.50 && vecXNorm < 0.50 && vecYNorm > 0.75) {
							// Swipe down
							
							gp2x_keys |= GP2X_VOL_DOWN;
						} else if (vecXNorm > -0.50 && vecXNorm < 0.50 && vecYNorm < -0.75) {
							// Swipe up
							gp2x_keys |= GP2X_VOL_UP;
						} else if (vecXNorm > 0.75 && vecYNorm >  -0.5 && vecYNorm < 0.5) {
							// Swipe right
							gp2x_keys |= GP2X_VOL_UP | GP2X_VOL_DOWN;
						} else if (vecXNorm < -0.75 && vecYNorm >  -0.5 && vecYNorm < 0.5) {
							// Swipe left
							return gp2x_keys;
						} else {
							return gp2x_keys;
						}				
					} else {
						return gp2x_keys;						
					}
				} else {
					event.type = Common::EVENT_MOUSEMOVE;
					event.mouse.x = x;
					event.mouse.y = y;
					_mouseX = x;
					_mouseY = y;					
				}
				break;
			case kInputMouseSecondToggled:
				_secondaryTapped = !_secondaryTapped;
				//printf("Mouse second at (%u, %u). State now %s.\n", x, y, _secondaryTapped ? "on" : "off");
				if (_secondaryTapped) {
					_lastSecondaryDown = curTime;
					_gestureStartX = x;
					_gestureStartY = y;
					return gp2x_keys;
				} else if (curTime - _lastSecondaryDown < 250 ) {
					if (curTime - _lastSecondaryTap < 250 && !_overlayVisible) {
						_lastSecondaryTap = 0;
					} else {
						_lastSecondaryTap = curTime;
					}		
				} else {
					return gp2x_keys;
				}
				break;
			default:
				break;
		}

		return gp2x_keys;
	}
	return gp2x_keys;
}

void gp2x_deinit(void)
{
}

void gp2x_flipscreen(void) 
{
	iPhone_updateScreen();
}


void gp2x_init(int bpp, int rate, int bits, int stereo, int Hz)
{
	iPhone_initSurface(320, 480);

	videobuffer = (u16*)iPhone_getSurface();
}


