# Atari 2600 Digital Photo Frame

*More info coming soon...*

Turn your family photos into retro 8-bit masterpieces with this Atari 2600 digital frame. It is powered by a custom cartridge containing a Raspberry Pi Pico, so it can do a lot of other tricks as well.

![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/img1-1_sm.jpg)

## How It Works

I recently picked up an Atari 2600 and, after repairing it (the left joystick port did not work; fortunately it turned out to be just broken pins), I wanted to do something special with it. I thought about making something like a Game Boy Camera for it (which I think is a good idea and may still do), or making a really advanced game by incorporating some modern hardware (also a good idea, but I previously made a [2600 game](https://github.com/nickbild/journey_to_xenos) and know how painful it is). In the end, I settled on a digital photo frame. The 8-bit graphics of the Atari 2600 are so beautiful (in their own special way) that it would be nice to be able to cycle through a collection of images during the day.

But without bankswitching, a cartridge can only contain 4KB of data. The largest bankswitched cartridge (that I know of, anyway), is still only 64KB, and it takes a lot of monkeying around to keep track of all of that and switch as needed — especially with the limited CPU cycles available to the programmer. Any way you slice it, you cannot store a lot of images in that space.

For this reason, I built what I call a Picotari cartridge. It is a customized version of my [PicoROM ROM emulator](https://github.com/nickbild/picoROM) that has edge connectors for an Atari 2600 cartridge port, as well as supporting hardware to put the onboard Raspberry Pi Pico on the Atari's address and data busses.

| ![](https://raw.githubusercontent.com/nickbild/atari_2600_digital_frame/refs/heads/main/img/picotari_sm.jpg) | 
|:--:| 
| *What bodge wire? I don't see any bodge wires.* |

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
