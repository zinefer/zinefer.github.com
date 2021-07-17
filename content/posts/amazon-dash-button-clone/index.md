+++
date = "2021-03-22T11:29:53-06:00"
title = "Amazon dash button clone"
description = "Designing a diy dash button clone using an ESP-12"
categories = "Hardware"
tags = ["Electronics", "Fusion 360", "ESP32", "3D Printing"]
+++

I had an idea to use Amazon dash buttons for presence tracking in my smarthome. Essentially, I can press a button when I go to sleep/wake or leave/return to the house. Unfortunately, since Amazon has bricked their buttons I sought out some sort of product replacement. After searching around, I wasn't satisfied with really anything I found. It was all either too expensive or too many features for what I wanted to use it for.

There are a couple of great projects that have been documented on the subject:
- [DIY IoT Button(Amazon Dash Button)
](https://www.instructables.com/DIY-IoT-ButtonAmazon-Dash-Button/)
- [Dash Button DIY with ESP-01
](https://www.thingiverse.com/thing:3678995)

The way these work is to use an ESP01 that connects to a WiFi network and sends a HTTP request to a specific endpoint. My main issue with these solutions were their power sources. One is using a usb power supply and the other has a coincell. I was attached to the idea of using a single triple-a battery like the original dash button.

Since the AAA voltage range is ~1-1.5v and the ESP boards need ~3.2 volts I would need to figure out how to boost the voltage.

With a little searching [I learned about](https://www.electroschematics.com/1-2v1-5v-single-cell-3-3v-boost-converter/) the **MCP1640** which are readily available from DigiKey. 

Looking into the MCP1640 datasheet there's this great schematic and even a suggested part/mfg list to source the supporting components from.

<center>
  {{< image "mcp-schem.png" "Resize" "700x" />}}
</center>

Since this circuit requires way more discreet components than any of my projects before I figured now would be a good time to try to learn how to create a PCB design for manufacturing. Additionally, I could swap out the ESP-01 for an ESP-12 which was made to be attached to PCBs. 

I went looking for Eagle but learned they had been bought out by Fusion-360 and since I was already familiar with the program I decided to use that instead of [KiCad](https://kicad.org/).

<center>
    {{< image "20210227_092527.jpg" "Resize" "700x" />}}
</center>

After waiting for a delivery from Digikey I tested the circuit on a breadboard, and then I was ready to get to work on the PCB design.

# How an electronics project fits together in Fusion

In Fusion there are quite a few pieces that you must know about in order to create an electronics design. For me, I needed to:

- [Create an electronics library](#electronics-library)
    - [Create Custom Components](#create-custom-components)
- [Create an electronics design](#electronics-design)
    - [Build the schematic](#schematic)
    - [Design my 2D PCB](#2d-pcb)
    - [Generate 3D PCB](#3d-pcb)

# Electronics Library

Fusion has a robust component library, but this project had many components that I had to create. 

## Create Custom Components

What needs to be done to create a custom component really depends on what you're working on. The MCP1640 component for example was able to be created with the [Package Generator](https://www.youtube.com/watch?v=uygVegKuBdw) in Fusion.

The battery clips and the ESP-12 were more complicated. In general this was the workflow I executed:

- Create a component symbol
- Create a component footprint
- Create the component package

You can import a fusion design or mesh for the package step and align it with your footprint. I didn't end up needing to do any 3D design for any of the components in this project.

You can also link more than one package/footprint with a symbol. I planned on using the through-hole battery clips and trim the backside manually, but it would be easy to create a new SMD package and update the board to use that instead.

# Electronics Design

The electronics design is more or less a file that maintains the relationship between your schematic, pcb and 3d pcb.

## Schematic

<center>
  {{< image "dash-schem.png" "Resize" "700x" />}}
</center>

Once I managed to get all my dependencies set up, this step was a breeze.

## 2D PCB

The first step was to link my electronics design with my case that contained a sketch for the overall shape of my desired PCB. Arranging my components and even basic routing was pretty obvious. The biggest difficulty I had here was actually understanding the layers. After watching a [webinar](https://www.youtube.com/watch?v=Vv3jlLv5q_I) I was able to suss out how to create top/bottom silk for the battery and move connections from top to bottom with vias.

<center>
  {{< image "2d-pcb.png" "Resize" "700x" />}}
</center>

### 3D PCB

This might have been the easiest part of the entire project! Once all the prior steps are complete, Fusion automatically generates a 3D PCB that can be used to complete your assembly.

<center>
  {{< image "3d-pcb.png" "Resize" "700x" />}}
</center>

<center>
  {{< mosaic "1x1" "assem-inspect.png" "assem.png" >}}
</center>

<center>
  {{< mosaic "1x1" "20210322_195809.jpg" "20210227_093630.jpg" >}}
</center>

Unfortunately it was about this point when the [Ikea Shortcut](https://www.ikea.com/ca/en/p/tradfri-shortcut-button-white-20356382/) button was released and did everything this project did better. With a slightly different form factor and battery, but Zigbee is better than wifi, it reports its battery usage, we can detect a long press, and it's somewhat water resistant. All this at a price that this project can't really beat. 

If you'd like to check out the design, or you want to create your own dash button clone for some reason you can download the files [here](diy-dash-button.zip). I have no idea how usable they will be after the Fusion export process, however.