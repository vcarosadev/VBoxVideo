/*==========================================================================

    VirtualBox Video Adapter
    NeXTSTEP 3.3 and Rhapsody DR2 Video Driver for Oracle VirtualBox

    Category Adapter of VBoxVideo: low level logic to communicate with the
	video adapter.

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

#import "VBoxVideo.h"
#import <driverkit/i386/ioPorts.h>
#include "VBoxDefines.h"

@implementation VBoxVideo (Adapter)

/*
	Return YES if the video adapter support configuration querys
*/
+ (BOOL) isVideoCfgAvailable {
	unsigned short portData;

	// The version of the adapter must be at least VBE_DISPI_ID_CFG
    outw(VBE_DISPI_IOPORT_INDEX, VBE_DISPI_INDEX_ID);
    outw(VBE_DISPI_IOPORT_DATA, VBE_DISPI_ID4);
    portData = inw(VBE_DISPI_IOPORT_DATA);

	IOLog("VBoxVideo - Video adapter identifier: '%x'\n", portData);
    if (portData == VBE_DISPI_ID4)
        return YES;
    else
        return NO;
}

/*
	Return the maximum width supported by the video adapter
*/
- (unsigned short) getMaxWidth {
	// Get the video adapter capabilities
	unsigned short ret;

	// Put the adapter in VGA mode, just in case
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];
	// Tell the adapter we're querying for capabilities
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED | VBE_DISPI_GETCAPS];
	// Query for the required value
	[self setIndex: VBE_DISPI_INDEX_XRES];
	ret = [self getDataWord];
	// Set the query mode off
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];

	return ret;
}

/*
	Return the maximum height supported	by the video adapter
*/
- (unsigned short) getMaxHeight {
	// Get the video adapter capabilities
	unsigned short ret;
    
	// Put the adapter in VGA mode, just in case
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];
	// Tell the adapter we're querying for capabilities
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED | VBE_DISPI_GETCAPS];
	// Query for the required value
	[self setIndex: VBE_DISPI_INDEX_YRES];
	ret = [self getDataWord];
	// Set the query mode off
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];

	return ret;
}

/*
	Return the maximum bit per pixels (i.e. color depth) supported
	by the video adapter
*/
- (unsigned short) getMaxBPP {
	// Get the video adapter capabilities
	unsigned short ret;

	// Put the adapter in VGA mode, just in case
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];
	// Tell the adapter we're querying for capabilities
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED | VBE_DISPI_GETCAPS];
	// Query for the required value
	[self setIndex: VBE_DISPI_INDEX_BPP];
	ret = [self getDataWord];
	// Set the query mode off
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];

	return ret;
}

/*
    Return the video adapter RAM size
*/
- (unsigned long) getVideoRAMSize {
    unsigned short retw = 0;
    unsigned long retRAMSize = 0L;
    
	// Ask the adapter if supports this configuration query
	[self setIndex: VBE_DISPI_INDEX_CFG withValue: VBE_DISPI_CFG_MASK_SUPPORT | VBE_DISPI_CFG_ID_VRAM_SIZE];
	retw = [self getDataWord];
	if ((retw & VBE_DISPI_CFG_MASK_ID) == VBE_DISPI_CFG_ID_VRAM_SIZE) {
		[self setIndex: VBE_DISPI_INDEX_CFG withValue: VBE_DISPI_CFG_ID_VRAM_SIZE];
		retRAMSize = [self getDataLong];
	} else {
		// Reading a 32 bit value from the data port should return the RAM size in older adapters
		retRAMSize = [self getDataLong];
	}
	
    return retRAMSize;
}

/*
    Return the address of the video adapter RAM
*/
-(unsigned long) getVideoRAMAddress {
    unsigned short retw = 0;
    unsigned long ramAddress = 0L;

    // The video adapter returns the hi word of the address, the lo word is 0000
	[self setIndex: VBE_DISPI_INDEX_FB_BASE_HI];
    retw = [self getDataWord];
    
    // The returned value is tranformed into a valid address
    ramAddress = (unsigned long)(retw << 16);
    return ramAddress;
}

/*
    Set index into the index port
*/
- (void) setIndex: (unsigned short) index {
	outw(VBE_DISPI_IOPORT_INDEX, index);
}

/*
    Set index into the index port and value into the data port
*/
- (void) setIndex: (unsigned short) index withValue: (unsigned short) value {
	outw(VBE_DISPI_IOPORT_INDEX, index);
    outw(VBE_DISPI_IOPORT_DATA, value);
}

/*
    Read a word (16 bit) from the data port
*/
- (unsigned short) getDataWord {
    return inw(VBE_DISPI_IOPORT_DATA);
}

/*
    Read a long word (32 bit) from the data port
*/
- (unsigned long) getDataLong {
    return inl(VBE_DISPI_IOPORT_DATA);
}

@end
