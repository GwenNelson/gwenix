#!/usr/bin/env python3

################################################################################
# Convert PDP-11 a.out format files to PDP-11 paper tape absolute loader format
#
# Martin Renters, Mar/2020
################################################################################

import argparse
import sys

################################################################################
# Write out PDP-11 LDA record (paper tape format)
# Format is: 0x01, 0x00, LSB len, MSB len, LSB addr, MSB addr, data, checksum
################################################################################
def write_lda_record(output, buffer):
    if not buffer:
        return
    length = len(buffer)
    buffer[2] = length & 0xFF
    buffer[3] = length // 256
    checksum = (-sum(buffer)) & 0xFF
    buffer.append(checksum)
    output.write(buffer)

################################################################################
# CONVERT - converts textual numeric constant to integer
################################################################################
def convert(s):
    if s[0:2] == '0x' or s[0:2] == '0X':
        base = 16
    elif s[0] == '0':
        base = 8
    else:
        base = 10

    return int(s, base)

################################################################################
# MAIN
################################################################################
def main():
    parser = argparse.ArgumentParser(
        description='Convert SREC file to PDP-11 LDA (papertape) format')
    parser.add_argument('--aout', default='a.out', help='a.out input file')
    parser.add_argument('--lda', default='a.ptap', help='LDA output file')
    parser.add_argument('--text', default='01000', help='text load address')
    parser.add_argument('--data-align', default='256', help='data alignment')
    parser.add_argument('--vector0', action='store_true',
        help='store JMP entry at vector 0')

    args = parser.parse_args()

    # Open input and output files
    try:
        input = open(args.aout, 'rb')
    except IOError:
        print('Unable to open', args.aout, 'for reading')
        sys.exit(2)

    try:
        output = open(args.lda, 'wb')
    except IOError:
        print('Unable to open', args.lda, 'for writing')
        sys.exit(2)

    # Convert text address and data alignment
    try:
        text_addr = convert(args.text)
    except:
        print('Invalid text address specified:', args.text)
        sys.exit(2)
    try:
        data_align = convert(args.data_align)
    except:
        print('Invalid data_alignment specified:', args.data_align)
        sys.exit(2)

    # Read the a.out header
    bytes = input.read()
    magic = bytes[0]*256+bytes[1]

    if magic == 0x0701 and data_align != 2:
        print('*** WARNING: impure executable, but alignment not 2');

    text_len = bytes[3]*256+bytes[2]
    data_addr = (text_addr + text_len + data_align - 1) & ~(data_align-1)
    data_len = bytes[5]*256+bytes[4]
    bss_len = bytes[7]*256+bytes[6]
    sym_len = bytes[9]*256+bytes[8]
    entry = bytes[11]*256+bytes[10]
    unused = bytes[13]*256+bytes[12]
    flags = bytes[15]*256+bytes[14]
    total = data_addr + data_len + bss_len
    print('      Magic    Text +    Len    Data +    Len     BSS = MaxMem   Entry')
    print('Hex:   {0:04x}    {1:04x} +   {2:04x}    {3:04x} +   {4:04x}    {5:04x}     {6:04x}    {7:04x}'.format(
        magic, text_addr, text_len,
        data_addr, data_len,
        bss_len, total, entry))
    print('Dec:  {0:5d}   {1:5d} +  {2:5d}   {3:5d} +  {4:5d}   {5:5d}    {6:5d}   {7:5d}'.format(
        magic, text_addr, text_len,
        data_addr, data_len,
        bss_len, total, entry))
    print('Oct: {0:06o}  {1:06o} + {2:06o}  {3:06o} + {4:06o}  {5:06o}   {6:06o}  {7:06o}'.format(

        magic, text_addr, text_len,
        data_addr, data_len,
        bss_len, total, entry))


    # Text section
    out_buffer = bytearray([1,0,0,0,text_addr & 0xFF, text_addr // 256])
    out_buffer.extend(bytes[16:16+text_len])
    write_lda_record(output, out_buffer)

    # Data (and BSS) section
    out_buffer = bytearray([1,0,0,0,data_addr & 0xFF, data_addr // 256])
    out_buffer.extend(bytes[16+text_len:16+text_len+data_len])

    # Make sure BSS section starts evenly aligned and initialize with zeros
    if data_len & 1:
        out_buffer.append(0)
    out_buffer.extend([0] * bss_len)
    write_lda_record(output, out_buffer)

    # Entry
    if args.vector0:
        out_buffer = bytearray([1,0,0,0,0,0,
            0x5f,0,entry & 0xFF, entry // 256]) # JMP _entry
        write_lda_record(output, out_buffer)

    out_buffer = bytearray([1,0,0,0,entry & 0xFF, entry // 256])
    write_lda_record(output, out_buffer)

if __name__ == '__main__':
    main()
