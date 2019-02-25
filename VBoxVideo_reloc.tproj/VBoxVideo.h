/*==========================================================================

    VirtualBox Video Adapter
    NeXTSTEP 3.3 and Rhapsody DR2 Video Driver for Oracle VirtualBox

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
#ifndef __VBOXVIDEO_H__
#define __VBOXVIDEO_H__

#import <driverkit/IOFrameBufferDisplay.h>
 
@interface VBoxVideo:IOFrameBufferDisplay {
    int selectedMode;       // Selected video mode
}

+ (BOOL) probe: deviceDescription;
- initFromDeviceDescription: deviceDescription;
- (void) enterLinearMode;
- (void) revertToVGAMode;
- (BOOL) checkVideoModes;
- (BOOL) updateMemoryRange: deviceDescription;
- free;
@end

@interface VBoxVideo (Adapter)
+ (BOOL) isVideoCfgAvailable;
- (unsigned short) getMaxWidth;
- (unsigned short) getMaxHeight;
- (unsigned short) getMaxBPP;
- (unsigned long) getVideoRAMSize;
- (unsigned long) getVideoRAMAddress;
- (void) setIndex: (unsigned short) index;
- (void) setIndex: (unsigned short) index withValue: (unsigned short) value;
- (unsigned short) getDataWord;
- (unsigned long) getDataLong;
@end

#endif	// __VBOXVIDEO_H__