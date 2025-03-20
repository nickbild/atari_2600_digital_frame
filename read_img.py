from PIL import Image

im = Image.open('img/3-convert.png')
pix = im.load()

addr = 5000

# Left side of image.
cnt = 0
val = ""
for y in range (im.size[1]):
    for x in range (0, 48):
        if pix[x, y] > 0:
            val += "1"
        else:
            val += "0"
        
        cnt += 1

        if cnt == 8:
            cnt = 0
            print("\trom_contents[{0}] = {1};".format(addr, int(val, 2)))
            val = ""
            addr += 1

# Right side of image.
cnt = 0
val = ""
for y in range (im.size[1]):
    for x in range (48, 64):
        if pix[x, y] > 0:
            val += "1"
        else:
            val += "0"
        
        cnt += 1

        if cnt == 8:
            cnt = 0
            print("\trom_contents[{0}] = {1};".format(addr, int(val, 2)))
            val = ""
            addr += 1

# View ASCII version of image.
for y in range (im.size[1]):
    for x in range (0, 64):
        if pix[x, y] > 0:
            print("1", end="")
        else:
            print("0", end="")
        
    print()




# print("\talign 256")
# print("sprite7")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (56, 64):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1


# print("sprite6")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (48, 56):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1


# print("sprite5")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (40, 48):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1

# print("\talign 256")
# print("sprite4")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (32, 40):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1


# print("sprite3")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (24, 32):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1


# print("sprite2")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (16, 24):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1

# print("\talign 256")
# print("sprite1")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (8, 16):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1

# print("\talign 256")
# print("sprite0")
# cnt = 0
# val = ""
# for y in range (im.size[1]-1, -1, -1):
#     for x in range (0, 8):
#         if pix[x, y]> 0:
#             val += "1"
#         else:
#             val += "0"
        
#         cnt += 1

#         if cnt == 8:
#             cnt = 0
#             print("\t.byte {1}".format(addr, int(val, 2)))
#             val = ""
#             addr += 1
