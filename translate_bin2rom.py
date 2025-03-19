import sys


cnt = 0

with open(sys.argv[1], "rb") as file:
    while byte := file.read(1):  # Read one byte at a time
        v = int.from_bytes(byte, "little")

        print("\trom_contents[{0}] = {1};".format(cnt, v))
        cnt += 1

