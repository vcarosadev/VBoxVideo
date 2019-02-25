/*==========================================================================

    VirtualBox Video Adapter
    NeXTSTEP 3.3 and Rhapsody DR2 Video Driver for Oracle VirtualBox

    Predefined video modes for the video adapter

    Copyright (C) 2019 Vittorio Carosa

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

==========================================================================*/
#ifndef __VBOX_MODES_H__
#define __VBOX_MODES_H__

#include <driverkit/displayDefs.h>

/*
    These are all the video modes available:
    - each element is set as follow:
        width
        height
        totalWidth (including undisplayed pixels)
        rowBytes (The number of bytes to get from one scanline to next - totalWidth * bytes_per_pixel)
        refreshRate
        frameBuffer (pointer to the video ram)
        bitsPerPixel (24BitsPerPixel are 3 bytes aligned to a word size i.e. 4 bytes)
        colorSpace (colors encoding method)
        pixelEncoding (how the pixel are organized starting from the most significant byte)
        flags (must be zero)
        parameters (driver specific, if needed)
    - the refresh rate is set to 60hz but is ignored by the virtual adapter
    - the pointer to the frame buffer is set to zero, will be set during the driver init
    
    The number and the order of these modes MUST match the list provided in the Display.modes file
*/
static const IODisplayInfo modesTable[] = {
    {
		/* 640 x 480, RGB:888/32 */
		640, 480, 640, 2560, 60, 0,
		IO_24BitsPerPixel, IO_RGBColorSpace, "--------RRRRRRRRGGGGGGGGBBBBBBBB",
		0, 0
	},
    {
		/* 800 x 600, RGB:888/32 */
		800, 600, 800, 3200, 60, 0,
		IO_24BitsPerPixel, IO_RGBColorSpace, "--------RRRRRRRRGGGGGGGGBBBBBBBB",
		0, 0
	},
	{
		/* 1024 x 768, RGB:888/32 */
		1024, 768, 1024, 4096, 60, 0,
		IO_24BitsPerPixel, IO_RGBColorSpace, "--------RRRRRRRRGGGGGGGGBBBBBBBB",
		0, 0
	},
    {
		/* 1152 x 864, RGB:888/32 */
		1152, 864, 1152, 4608, 60, 0,
		IO_24BitsPerPixel, IO_RGBColorSpace, "--------RRRRRRRRGGGGGGGGBBBBBBBB",
		0, 0
	},
    {
		/* 1280 x 1024, RGB:888/32 */
		1280, 1024, 1280, 5120, 60, 0,
		IO_24BitsPerPixel, IO_RGBColorSpace, "--------RRRRRRRRGGGGGGGGBBBBBBBB",
		0, 0
	},
    {
		/* 1600 x 1200, RGB:888/32 */
		1600, 1200, 1600, 6400, 60, 0,
		IO_24BitsPerPixel, IO_RGBColorSpace, "--------RRRRRRRRGGGGGGGGBBBBBBBB",
		0, 0
	},
    {
		/* 640 x 480, RGB:555/16 */
		640, 480, 640, 1280, 60, 0,
		IO_15BitsPerPixel, IO_RGBColorSpace, "-RRRRRGGGGGBBBBB",
		0, 0
	},
    {
		/* 800 x 600, RGB:555/16 */
		800, 600, 800, 1600, 60, 0,
		IO_15BitsPerPixel, IO_RGBColorSpace, "-RRRRRGGGGGBBBBB",
		0, 0
	},
	{
		/* 1024 x 768, RGB:555/16 */
		1024, 768, 1024, 2048, 60, 0,
		IO_15BitsPerPixel, IO_RGBColorSpace, "-RRRRRGGGGGBBBBB",
		0, 0
	},
    {
		/* 1152 x 864, RGB:555/16 */
		1152, 864, 1152, 2340, 60, 0,
		IO_15BitsPerPixel, IO_RGBColorSpace, "-RRRRRGGGGGBBBBB",
		0, 0
	},
    {
		/* 1280 x 1024, RGB:555/16 */
		1280, 1024, 1280, 2560, 60, 0,
		IO_15BitsPerPixel, IO_RGBColorSpace, "-RRRRRGGGGGBBBBB",
		0, 0
	},
    {
		/* 1600 x 1200, RGB:555/16 */
		1600, 1200, 1600, 3200, 60, 0,        
		IO_15BitsPerPixel, IO_RGBColorSpace, "-RRRRRGGGGGBBBBB",
		0, 0
	} 
};

#define modesTableCount (sizeof(modesTable) / sizeof(IODisplayInfo))  	// Elements in the array
#define defaultMode 0;                                              	// Default mode

#endif // __VBOX_MODES_H__