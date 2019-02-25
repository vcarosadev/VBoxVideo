/*==========================================================================

    VirtualBox Video Adapter
    NeXTSTEP 3.3 and Rhapsody DR2 Video Driver for Oracle VirtualBox

    Values used to interact with the video adapter
    The values were collected from the VirtualBox source codes

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

/*
 * Copyright (C) 2006-2019 Oracle Corporation
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef __VBOX_DEFINES_H__
#define __VBOX_DEFINES_H__

/*
    PCI Video adapter identifiers
*/
#define PCI_VENDOR_ID   0x80EE          // PCI Vendor identifier
#define PCI_DEVICE_ID   0xBEEF          // PCI Device identifier

/*
    Video adapter I/O port
*/
#define VBE_DISPI_IOPORT_INDEX          0x01CE  // This port select the value to read or write
#define VBE_DISPI_IOPORT_DATA           0x01CF  // This port return or set the value

/*
    Set the following in VBE_DISPI_IOPORT_INDEX to read/write the corresponding values
*/
#define VBE_DISPI_INDEX_ID              0x0     // Get the adapter identifier
#define VBE_DISPI_INDEX_XRES            0x1     // Video mode X resolution
#define VBE_DISPI_INDEX_YRES            0x2     // Video mode Y resoultion
#define VBE_DISPI_INDEX_BPP             0x3     // Vidoe mode bits per pixel (i.e. color depth)
                                                // Valid values are 4, 8, 15, 16, 24, 32
#define VBE_DISPI_INDEX_ENABLE          0x4     // Enabale/Disable the required video mode
#define VBE_DISPI_INDEX_BANK            0x5     // Banked video memory access
#define VBE_DISPI_INDEX_VIRT_WIDTH      0x6     // Virtual Width
#define VBE_DISPI_INDEX_VIRT_HEIGHT     0x7     // Virtual Hight
#define VBE_DISPI_INDEX_X_OFFSET        0x8     // X offset (for virtual screen)
#define VBE_DISPI_INDEX_Y_OFFSET        0x9     // Y offset (for virtual screen)
#define VBE_DISPI_INDEX_FB_BASE_HI      0xb     // Return the high value of the frame buffer address (the low value is 0000)
#define VBE_DISPI_INDEX_CFG             0xc     // Read the video adapter configuration

/*
    Video adapter identifier, as returned by VBE_DISPI_INDEX_ID
*/
#define VBE_DISPI_ID0                   0xB0C0
#define VBE_DISPI_ID1                   0xB0C1
#define VBE_DISPI_ID2                   0xB0C2
#define VBE_DISPI_ID3                   0xB0C3
#define VBE_DISPI_ID4                   0xB0C4
#define VBE_DISPI_ID_CFG                0xBE03 /* VBE_DISPI_INDEX_CFG is available. */

/*
    VBE_DISPI_INDEX_ENABLE
*/
#define VBE_DISPI_DISABLED              0x00    // Revert the adapter to standard VGA
#define VBE_DISPI_ENABLED               0x01    // Enable the desidered video mode
#define VBE_DISPI_GETCAPS               0x02    // Return the capacities of the video adapter

/*
    VBE_DISPI_INDEX_CFG

    Configuration information if VBE_DISPI_INDEX_CFG is supported by the adapter
*/
#define VBE_DISPI_CFG_MASK_SUPPORT      0x1000  // Query whether the identifier is supported
#define VBE_DISPI_CFG_MASK_ID           0x0FFF  // Identifier of a configuration value
#define VBE_DISPI_CFG_ID_VERSION        0x0000  // Version of the configuration interface
#define VBE_DISPI_CFG_ID_VRAM_SIZE      0x0001  // Video RAM size

#endif // __VBOX_DEFINES_H__