+++
date = "2021-11-20T09:07:08-07:00"
title = "Festival Totem: Pressurized"
description = "Recreating my interestingly flawed totem from 2019"
categories = "Making"
tags = ["ESP32", "APA102", "Fusion 360", "Soldering", "Prototyping", "PCB Design", "Electronics", "3D Printing", "C++"]
+++

Earlier this year with EDC 2021 getting scheduled, I decided I wanted to take a stab at creating a new totem with a bunch of the accidental features I loved from my [cobbled together in 24-hours version from 2019]().

- Highly compliant for maximum wiggles
- Rattles for audio/haptic stimulus
- Minimum weight so it can be reasonably carried for 10+ hours

## Skip Ahead 

- [Pressurized tube](#pressurized-tube)
- [Coring out a pool noodle](#coring-out-a-pool-noodle)
- [Custom PCBs](#custom-pcbs)
- [Handle](#handle)
- [Code](#code)
- [Wiggle](#wiggle)

# Pressurized Tube

I decided to pressurize the main body of the totem as my hunch for the prior totem's failure was a repeated stress fracture right in the middle of the tube. I figured pressurizing it would make quite a bit harder for the plastic to 'kink' while still being very wiggleable.

Creating the pressurized tube took a bunch of prototyping and while I tried many things to avoid epoxying everything shut, in the end that's what happened. This part of the project was drawn out over months because how apprehensive I am when working with epoxy as glue.

## Parts of the tube

- [Tube](#tube)
- [Spine](#spine)
- [Passthrough conductors](#passthrough-conductors)
- [Endcaps](#endcaps)

### Tube

The tube is made from a T8 Fluorescent Tube Guard 96"

### Spine

The spine is created from a plastic coated steel cable and has 3d printed platforms epoxied at regular intervals and radial offset to hold the led strip and give it a little twist.

<center>
  {{< mosaic "1x1" "spine.png" "20210518_221752.jpg" >}}
</center>

### Passthrough conductors

My first sealed tube with conductors had a major flaw in that I attempted to simply epoxy wires through the endcap. Not only would the insulation have pulled away but also I think the air leaked out through the space between the strands in the wiring.

I ended up using some solid 2mm brass rods, which worked wonderfully. I was also able to use some off the shelf 2mm female bullet connectors without any modifications.

<center>
  {{< mosaic "1x1" "20210628_203633.jpg" "20210728_232738.jpg" >}}
</center>

### Endcaps

The endcaps have a few functions they must perform:

- Seal the tube
- Hold the shrader valve
- Provide electrical passthrough
- Accomodate spine tension during assembly

<center>{{< image "endcaps.png" Resize "700x" />}}</center>

The endcaps are made from three pieces, an innermost piece that is epoxied to the inside of the tube and provides threads for the inner cap that holds the spine, schrader and conductors. The final piece is a ring that is epoxied onto the outside of the tube to strengthen and protect the epoxy that is providing the seal.

<center>{{< video "endcaps-two.mp4" "700" "autoplay loop" >}}</center>

<center>
  {{< mosaic "1x1" "20210704_100608.jpg" "20210706_073637.jpg" >}}
</center>

<center>
  {{< youtube "sUQj55CrHE4" >}}
</center>


# Coring out a pool noodle

I needed to shave off about 3 mm from the diameter of the inner hole in the pool noodle. Trying to force the tube into the foam just created too much friction regardless of adding lube. I was also worried that most lubes would have a negative effect on the foam.

For the original totem I just cut the foam long ways and added in a section to fill the gap once wrapped around the tube. For this totem, I wanted a cleaner look.

With some help from [Jason](https://accidental.engineering/) I made a 4 foot long foam cutter.

<center>{{< image "20210701_075131.jpg" Resize "700x" />}}</center>

It only took a couple tries with a bit of tweaking before we had a great result.

<center>
  {{< mosaic "1x1" "20210913_083922.jpg" "20210913_083929.jpg" >}}
</center>

# Custom PCBs

I decided I wanted this project to finally be the one where I create custom boards and have a fabshop create them for me.

<center>{{< image "controller-four.png" Resize "700x" />}}</center>

The controller board has a level-shifter to be able to communicate with the APA102s as well as a [BNO055 Position sensor]().

I also created an input board that has a parallel-shift-in to read from 3 position slide switches.

<center>{{< image "input-four.png" Resize "700x" />}}</center>

<center>{{< image "20211012_104035.jpg" Resize "700x" />}}</center>

I was so happy to get the boards, but then I quickly realized I had sized pretty much every single pad hole smaller than the component's legs. I panicked and immediately fixed the GERBERS and sent them back off to the fab shop. This was about a week before we had to leave, so I started on a new plan to use the laser and some acid to try to etch my own.

It's actually a simple process: get a [copper blank](https://www.amazon.com/dp/B01MCVLDDZ) and give it a nice, even coat with a spray primer. Since we'll be creating our mask with the laser we probably don't want a high heat paint, but I have not tested it.

Once the mask is created just submerge it in some [Ferric Chloride](https://www.amazon.com/dp/B008O9XMYA/) acid. I suggest using a clear bottom container and placing it ontop of a nice even backlight. The acid will remove any exposed copper and you'll begin to see the light shining through. Then it's just a matter of waiting for all of your traces to be nicely separated.

<center>
  {{< mosaic "2x1" "20211016_222528.jpg" "20211016_223123.jpg" "20211017_025513.jpg" >}}
</center>

The last step was to drill the holes. I ended up pulling out my Dremel 4000 and got really lucky and found a [Dremel press workstation](https://www.amazon.com/dp/B00068P48O) at a store locally. I threw in a cheap [PCB drill bit](https://www.amazon.com/dp/B07CXQZPK1/) from a set I got for free with the purchase of some other tool and this combo was exceptional. I did have to go back a single time and repeat the process because I initially made my pads too small. Make any pads you'll be drilling through as large as you can as there's an upwards force when the bit comes up and it has a tendency to rip your pad up.

<center>
  {{< mosaic "1x1" "20211017_025800.jpg" "20211017_215826.jpg" >}}
</center>

Now I had a really nice board in the same layout as the PCB fab although it would be a little thicker and was only single sided I figured it would do the job.

<center>{{< image "20211017_223430.jpg" Resize "700x" />}}</center>

I threw it on the bench and warmed up the soldering iron when it hit me. I didn't need a new board. I could use really thin pins instead of headers for pretty much all the components. The Input board had enough extra pad area that I was able to use the dremel pcb drill setup to enlarge them enough for the switch leads without too much trouble.

For some reason I did not get a complete photo of the boards outside the handle `¯\_(ツ)_/¯`

<center>{{< image "20211020_214613.jpg" Resize "700x" />}}</center>

# Handle

The handle was the last thing created and was designed to screw onto one end of the core tube and hold the PCB boards. Pretty straightforward here, 3d print, iterate and repeat 10-12 times as necessary until satisfied.

<center>
  {{< mosaic "2x1" "handle-left.png" "handle-mid.png" "handle-right.png" >}}
</center>

The handle is in two pieces, an inner and an outer. The inner gets epoxied to the tube so the outer can be twisted into place.

<center>{{< video "handle-two.mp4" "700" "autoplay loop" >}}</center>

<center>
  {{< mosaic "1x1" "20211018_110444.jpg" "20211018_110450.jpg" >}}
</center>

# Code

I decided to use Arduino to program the ESP32 because then I could leveredge all my old FastLED animations from the old totem. I dedicated one core to reading input and controlling animation transition timing, while the other core drove the LEDs as fast as possible.

[Github](https://github.com/zinefer/festival-totem-2021)

# Wiggle

<center>
  {{< youtube "XeZGM8LBNJs" >}}
</center>

<br/>

<center>
  {{< youtube "pWOYUGrYr0o" >}}
</center>

<center>{{< image "thumb.jpg" Resize "700x" />}}</center>