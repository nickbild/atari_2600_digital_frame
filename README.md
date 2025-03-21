# Atari 2600 Digital Photo Frame

Turn your family photos into retro 8-bit masterpieces with this Atari 2600 digital frame. It is powered by a custom cartridge containing a Raspberry Pi Pico, so it can do a lot of other tricks as well.

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/img1-1_sm.jpg)

## How It Works

I recently picked up an Atari 2600 and, after repairing it (the left joystick port did not work; fortunately it turned out to be just broken pins), I wanted to do something special with it. I thought about making something like a Game Boy Camera for it (which I think is a good idea and may still do), or making a really advanced game by incorporating some modern hardware (also a good idea, but I previously made a [2600 game](https://github.com/nickbild/journey_to_xenos) and know how painful it is). In the end, I settled on a digital photo frame. The 8-bit graphics of the Atari 2600 are so beautiful (in their own special way) that it would be nice to be able to cycle through a collection of images during the day.

But without bankswitching, a cartridge can only contain 4KB of data. The largest bankswitched cartridge (that I know of, anyway), is still only 64KB, and it takes a lot of monkeying around to keep track of all of that and switch as needed — especially with the limited CPU cycles available to the programmer. Any way you slice it, you cannot store a lot of images in that space.

For this reason, I built what I call a Picotari cartridge ([gerber files](https://github.com/nickbild/atari_2600_digital_frame/tree/main/picotari_pcb)). It is a customized version of my [PicoROM ROM emulator](https://github.com/nickbild/picoROM) that has edge connectors for an Atari 2600 cartridge port, as well as supporting hardware to put the onboard Raspberry Pi Pico on the Atari's address and data busses.

| ![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/picotari_sm.jpg) | 
|:--:| 
| *What bodge wire? I don't see any bodge wires.* |

With modern hardware in the mix, there are plenty of options to expand memory (and more). For my digital frame project, the path I chose only requires one byte of ROM (as far as the Atari is concerned) to display an unlimited number of images. This is made possible by addressing a specified byte each time I need the next 8 pixels to draw a player sprite. Each time that address is requested, the Picotari knows to actually look at the next address sequentially in a much larger memory space that it holds internally. In this case, I only used the Pico's onboard memory, but it would be trival to add on an SD card reader and pull from there, making gigabytes of storage possible. The Picotari code [is here](https://github.com/nickbild/atari_2600_digital_frame/blob/main/pico_rom.c).

The Atari [runs a program](https://github.com/nickbild/atari_2600_digital_frame/blob/main/showpic.asm) that displays a 64x84-pixel image. Since the Atari needs to be fed one byte at a time for display (there is no frame buffer), sequential retrieval is ideal for this application. Getting anything like a bitmap to display on the 2600 is very difficult since it was never meant to do any such thing. I made it work by using the well-known 48-pixel image trick, which uses sprite copies and vertical delays to just barely fit 6 8-bit sprites on a single scan line. To get it up to 64, I draw the first 48 pixels on one frame, then the next 16 at a position just after that on the next frame, and repeat that process *ad infinitum*. The height of the image could actually go all the way up to 192 pixels, there is no restriction on that — I just think 64x84 has a nice aspect ratio. The images must be 2 colors — there are absolutely no cycles availble to change the color registers as the image is drawn.

### Preparing the images

I started with a photo, such as this one:

![](https://github.com/nickbild/atari_2600_digital_frame/blob/main/img/for_display/1.jpg)

Then I ran it through [Pixel It](https://giventofly.github.io/pixelit/) to help 8-bit-ify it before doing a little manual touch-up in Gimp. The results are something like this:

![](https://github.com/nickbild/atari_2600_digital_frame/blob/main/img/for_display/1-convert.png)

Next, I used this [Python script](https://github.com/nickbild/atari_2600_digital_frame/blob/main/read_img.py) to read the image data and turn it into a data strucutre that can be used by the Picotari. The Atari ROM is also turned into a data strucure using [this script](https://github.com/nickbild/atari_2600_digital_frame/blob/main/translate_bin2rom.py).

Once the Picotari is flashed with code containing this data, it only needs to be plugged into the Atari like any other cartridge. It is fully self-contained, drawing its power from the Atari.

As presently coded, each image is displayed for about 30 seconds before the next is loaded. After the last image is displayed, it will go back to the first image.

## Media

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/cat.png)

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/hackster_sm.jpg)

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/hackaday_sm.jpg)

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/img1-2_sm.jpg)

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/img1-3_sm.jpg)

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/img1-4_sm.jpg)

## Bill of Materials

- 1 x Atari 2600
- 1 x Raspberry Pi Pico
- 1 x 74LVC245AN octal bus transciever
- 1 x 74AC04N hex inverter
- 3 x 0.1 uF capacitors
- 1 x Picotari 2600 Rom Emulator PCB ([gerber files](https://github.com/nickbild/atari_2600_digital_frame/tree/main/picotari_pcb))

## About the Author

[Nick A. Bild, MS](https://nickbild79.firebaseapp.com/#!/)
