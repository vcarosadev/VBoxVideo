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
#import "VBoxVideo.h"
#include "VBoxDefines.h"
#include "VBoxModes.h"

#include <stdio.h>
#import <driverkit/i386/IOPCIDeviceDescription.h>
#import <driverkit/i386/IOPCIDirectDevice.h>
#import <driverkit/i386/ioPorts.h>

@implementation VBoxVideo

/*
	Called by the OS to inizialize the driver.

	Performs the following:
	- get the video adapter PCI configuration
	- check if the video adapter version is correct
	- get memory to create a video adapter object
	- initialize the object

	Return YES on success, NO on failure.
*/
+ (BOOL) probe: deviceDescription {
	IOPCIConfigSpace pciConfig;				// PCI Configuration
	IOReturn configReturn;					// Return value from getPCIConfigSpace
	VBoxVideo *theDriver;					// Instance of the driver

	IOLog("VBoxVideo - VirtualBox Video Adapter Driver\n");
	IOLog("VBoxVideo - Version 1.0 (built on %s at %s)\n", __DATE__, __TIME__);

	// Get the PCI configuration
	configReturn = [self getPCIConfigSpace: &pciConfig withDeviceDescription: deviceDescription];
	if (configReturn != IO_R_SUCCESS ) {
		IOLog("VBoxVideo - Failed to get PCI config data - Error: '%s'\n", [self stringFromReturn:configReturn]);
		return NO;
	}

	// Check if the vendor is correct
	if (pciConfig.VendorID != PCI_VENDOR_ID) {
		IOLog("VBoxVideo - Invalid vendor '%04x'!\n", pciConfig.VendorID);
		return NO;
	}

	// Check if the device is correct
	if (pciConfig.DeviceID != PCI_DEVICE_ID) {
		IOLog("VBoxVideo - Invalid device '%04x'!\n", pciConfig.VendorID);
		return NO;
	}
	IOLog ("VBoxVideo - PCI Vendor: '%04x' Device: '%04x'\n", pciConfig.DeviceID, pciConfig.VendorID);

	// Check if the video adapter has the correct version
	if([VBoxVideo isVideoCfgAvailable] == NO) {
		IOLog ("VBoxVideo - The video adapter doesn't support configuration querys!\n");
		return NO;
	}

	// Allocate memory for the new driver
	theDriver = [self alloc];
	if (theDriver == nil) {
		IOLog ("VBoxVideo - Unable to allocate memory for the driver!\n");
		return NO;
	}

	// Initialize the driver
	if([theDriver initFromDeviceDescription: deviceDescription] == nil) {
		IOLog ("VBoxVideo - Unable to initialize the driver!\n");
		return NO;
	}

	return YES;
}

/*
	Initialize the video adapter driver

	- Check which of the predefined video modes are supported by the current adapter
	- Get the frame buffer address and video ram size and set the ranges accordingly
	- Map the frame buffer in the address space
	- Register the device driver
*/
- initFromDeviceDescription: deviceDescription {
	IODisplayInfo *displayInfo;		// Display information for the selected mode
	IOReturn ret;

	// Call the base class
	if ([super initFromDeviceDescription:deviceDescription] == nil)
		return [super free];

	IOLog ("VBoxVideo - Initializing...\n");

	// Check which of the video modes in modesTable are supported by the adapter
	if ([self checkVideoModes] == NO) {
		IOLog("VBoxVideo - Unable to find a video mode supported by the video adapter\n");
		return [super free];
	}
	// The current displyInfo struct now is set to point to the selected video mode
	*[self displayInfo] = modesTable[selectedMode];
	displayInfo = [self displayInfo];

	// Update the memory ranges
	if ([self updateMemoryRange: deviceDescription] == NO) {
		IOLog("VBoxVideo - Unable to update memory ranges!\n");
		return [super free];
	}

	// Map the framebuffer (memory range 0) in the processor address space
	ret = [self mapMemoryRange:0  to:(vm_address_t *)&(displayInfo->frameBuffer)
		findSpace:YES cache:IO_DISPLAY_CACHE_WRITETHROUGH];
    if (ret != IO_R_SUCCESS)	{
    	IOLog("VBoxVideo - Unable to map the frame buffer - '%s'!\n", [self stringFromReturn:ret]);
		return [super free];
    }
	
	// Tell the OS the kind of device then register the device
	[self setDeviceKind: "Linear Framebuffer"];
	[self registerDevice];

	IOLog ("VBoxVideo - Initialization successfully done\n");
	return self;
}

/*
	Enable the selcted video mode

	Check which of the predefined video mode is supported by the current adapter
*/
- (void) enterLinearMode {
	IODisplayInfo *displayInfo;
	unsigned short selBPP = 0;

	IOLog ("VBoxVideo - Enter linear mode\n");
	
	// Set the adapter in VGA mode, just in case
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];

	// Set the required Width and Height
	displayInfo = [self displayInfo];
	[self setIndex: VBE_DISPI_INDEX_XRES withValue: displayInfo->width];
	[self setIndex: VBE_DISPI_INDEX_YRES withValue: displayInfo->height];
	
	// Set the bit per pixel
	if (displayInfo->bitsPerPixel == IO_8BitsPerPixel) {
		selBPP = 8;
	} else if (displayInfo->bitsPerPixel == IO_15BitsPerPixel) {
		selBPP = 15;
	} else if (displayInfo->bitsPerPixel == IO_24BitsPerPixel) {
		selBPP = 32;
	}
	[self setIndex: VBE_DISPI_INDEX_BPP withValue: selBPP];
	IOLog ("VBoxVideo - Video mode %dx%d %ubpp\n", displayInfo->width, displayInfo->height, selBPP);

	// Put the adapter in the reuired mode
	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_ENABLED];
}

/*
	Return to VGA mode
*/
- (void)revertToVGAMode {
	IOLog ("VBoxVideo - Revert to VGA mode\n");

	[self setIndex: VBE_DISPI_INDEX_ENABLE withValue: VBE_DISPI_DISABLED];
	[super revertToVGAMode];
}

/*
	Check which of the predefined video modes are supported by the current adapter and
	set the video mode according to the user selection, if it's supported.

	Return YES if at least one predefined video was selected, NO otherwise.
*/
- (BOOL) checkVideoModes {
	BOOL validModes[modesTableCount];				// Flag for checking valid modes
	unsigned short maxWidth, maxHeight, maxBPP;		// Video adapter capabiities
	unsigned long videoRAMSize;
	unsigned long requiredRAM;						// RAM required by a video mode
	IOBitsPerPixel bppRequired;
	int countYesModes = 0;							// Count the valid modes
	int k;

	// Get the current adapter capabilities
	maxWidth = [self getMaxWidth];
	maxHeight = [self getMaxHeight];
	maxBPP = [self getMaxBPP];
	videoRAMSize = [self getVideoRAMSize];

	IOLog("VBoxVideo - Video adapter capabilities:\n");
	IOLog("VBoxVideo - Max Width:\t%u\t\tMax Height:\t%u\n", maxWidth, maxHeight);
	IOLog("VBoxVideo - Max BPP:\t%u\t\tRAM Size:\t%lu\n", maxBPP, videoRAMSize);

	// Check every video mode
	for (k = 0; k < modesTableCount; k++) {
		// Check if the current video mode width and height is within the apapter limits
		if (modesTable[k].width > maxWidth || modesTable[k].height > maxHeight) {
			// Unsupported mode
			validModes[k] = NO;
			// No more check required, this video mode is unsupported
			continue;
		}

		// Check the bits per pixel required by this mode
		bppRequired = modesTable[k].bitsPerPixel;
		// This two modes are not supported
		if (bppRequired == IO_2BitsPerPixel || bppRequired == IO_12BitsPerPixel) {
			// Unsupported mode
			validModes[k] = NO;
			continue;
		}
		// 8 bits grayscale
		if (bppRequired ==  IO_8BitsPerPixel && maxBPP < 8) {
			// Unsupported mode
			validModes[k] = NO;
			continue;
		}
		// 15 bits per pixel
		if (bppRequired == IO_15BitsPerPixel && maxBPP < 15) {
			// Unsupported mode
			validModes[k] = NO;
			continue;
		}
		// 32 bits per pixel
		if (bppRequired == IO_24BitsPerPixel && maxBPP < 24) {
			// Unsupported mode
			validModes[k] = NO;
			continue;
		}

		// Compute how many RAM is required by the video mode
		requiredRAM = modesTable[k].rowBytes * modesTable[k].height;
		if (requiredRAM > videoRAMSize) {
			validModes[k] = NO;

			IOLog("VBoxVideo - There is not enough video RAM for the video mode %d!\n", k);
			IOLog("VBoxVideo - Required %lu - Available %lu!\n", requiredRAM, videoRAMSize);
			// Next video mode
			continue;
		}

		// Set the mode as valid
		validModes[k] = YES;
		countYesModes++;
	}
	IOLog("VBoxVideo - The adapter supports %d modes out of %lu\n", countYesModes, modesTableCount);

	// Select the video mode
	selectedMode = [self selectMode: modesTable count: modesTableCount valid: validModes];
	if(selectedMode < 0) {
		IOLog("VBoxVideo - No video mode available for this adapter!\n");
		selectedMode = defaultMode;
		return NO;
	}

	return YES;
}

/*
	Update the memory ranges for the video adapter RAM according to the information collected.
	The first memory range is the one used by the frame buffer and should be updated, the other
	two are standard VGA memory ranges and will remain untouched. The first memory range will 
	be used to map the video adapter memory in the processor address space.

	Both NeXTSTEP and Rhapsody have some issue with updating the memory ranges, the method can fail
	reporting an error about insufficent resources. If this is the case and the start adress is the one
	configured in the Daefault.table file we try to go on without updating the memory ranges. It usually works.

	Return YES on success, NO otherwsie.
*/
- (BOOL) updateMemoryRange: deviceDescription {
    unsigned long videoRAMSize = 0l;
	unsigned long videoRAMAddress = 0l;
	IORange *oldMemRange, newMemRange[3];    // Old and new memory range
	unsigned int numRanges;					 // Memory range count
	IOReturn ret;
	int i;

	// Get the information about the video adapter RAM: stard address and size
	videoRAMAddress = [self getVideoRAMAddress];
	videoRAMSize = [self getVideoRAMSize];
	if (videoRAMAddress == 0 || videoRAMSize == 0) {
		IOLog ("VBoxVideo - Unable to get video RAM address and/or size!\n");
		return NO;
	}

	// Get the video memory range address
	oldMemRange = [deviceDescription memoryRangeList];
	numRanges = [deviceDescription numMemoryRanges];
	if (numRanges != 3) {
		IOLog ("VBoxVideo - Unexpected number of memory ranges %u!\n", numRanges);
		return NO;
	}

	// Copy the memory ranges into the new array
	for (i = 0; i < numRanges; i++) {
		newMemRange[i] = oldMemRange[i];
    }
	// Update the frame buffer address
	newMemRange[0].start = (unsigned int) videoRAMAddress;
	newMemRange[0].size = (unsigned int) videoRAMSize;
	
	// Set the new memory ranges
	ret = [deviceDescription setMemoryRangeList:newMemRange num:3];
	if (ret == IO_R_SUCCESS) {
		IOLog("VBoxVideo - New RAM range: %08lX-%08lX Size: %ld\n", videoRAMAddress, videoRAMAddress + videoRAMSize, videoRAMSize);
		return YES;
	}

	/*
		It may happen in both NeXTSTEP and Rhapsody that the memory range update doesn't work. If this is the case and
		the video RAM address reported by the adapter is the same as the one configured in Default.table we try to
		continue without updating the memoery ranges. The memory size can be an issue if the configured RAM is more
		than the RAM in the current adapter.
	*/
	if(videoRAMAddress == oldMemRange[0].start) {
		IOLog("VBoxVideo - Using default RAM range: %08X-%08X Size: %d\n", oldMemRange[0].start, oldMemRange[0].start + oldMemRange[0].size, oldMemRange[0].size);
		return YES;
	}

	/*
		The videoRAMAddress is different from the one configured in Default.table and since there is no way to update
		the memory range we must quit. The adapter can't be used.
	*/
	IOLog("VBoxVideo - Default RAM address: %08X - Adapter RAM address: %08lX - unable to update\n", oldMemRange[0].start, videoRAMAddress);
	return NO;
}

/*
	Perform the cleanup when this object is freed
*/
- free {
	IOLog("VBoxVideo - Cleaning up\n");

	// Unmap the framebuffer
	[self unmapMemoryRange:0 from:(vm_address_t)[self displayInfo]->frameBuffer];
    return [super free];
}

@end
