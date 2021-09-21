#!/usr/bin/env python3

import random


def gen_bytes(width, delimiter, sum_nums):
    bytes = ''
    for i in range(width):
        bytes += '{:02X}'.format(random.randint(0, 255))
        if i + 1 < width:
            bytes += ' '
    bytes += delimiter
    format_str = '{:0'+str(sum_nums)+'X}'
    bytes += format_str.format(random.randint(0, 255))
    return bytes


ADDR = 0
with open('hex.training_text', 'w') as f:
    while ADDR < 0x20000:
        for width in [8, 16]:
            for delimiter in [':', ' ']:
                for sum in ['SUM ', 'Sum ', 'sum ']:
                    for sum_nums in [2, 3]:
                        for j in range(16):
                            line = '{:04X}'.format(ADDR % 0x10000)+delimiter
                            line += gen_bytes(width, delimiter, sum_nums)
                            ADDR += width
                            f.write(line+'\n')
                        line_width = len(line)
                        f.write('-'*line_width+'\n')
                        line = sum + delimiter
                        line += gen_bytes(width, delimiter, sum_nums)
                        f.write(line+'\n\n')
