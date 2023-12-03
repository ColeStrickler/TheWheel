import os

size = os.stat('./bootsector.bin').st_size

if size > 510:
    printf(f"FAILED TO BUILD BOOTSECTOR. OVERSIZED: {size} bytes\n")
    exit(-1)

with open('./bootsector.bin', 'ab') as f:
    for i in range(510-size):
        f.write(b'\x00')
    f.write(b'\x55\xaa')


size = os.stat('./bootsector.bin').st_size


if size != 512:
    print(F"FAILED TO BUILD BOOTSECTOR. END SIZE: {size}")
