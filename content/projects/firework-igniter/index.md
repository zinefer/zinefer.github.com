+++
date = "2013-07-03T04:56:00-04:00"
title = "Firework Igniter"
description = "Programmable fuze igniter"
tags = ["Electronics","Soldering","Fireworks","Arduino"]
categories = "Hardware"
+++

Last year my home state, Michigan, legalized aerial fireworks. I put on a small show and really enjoyed it so I wanted to step it up this year. I made a 4 channel firework launcher capable of igniting 16* individual firework fuses.

Finding anything with a fuse in Colorado is actually pretty hard. I had to have some visco fuse mailed and it took a while. Naturally, that didn’t stop me from making stuff.

<center>
  {{< image "clamp1.jpg" Resize "225x" />}}
  {{< image "clamp2.jpg" Resize "225x" />}}
  {{< image "clamp3.jpg" Resize "225x" />}}
</center>

It took forever to whittle those clothespins and they really came out nice. Unfortunately once I received the visco fuse I realized the 40awg nichrome just didn’t have enough oomph to burn through the outer layer. I think this design could still work well with some lower gauge nichrome.

<center>{{< image "thumb.jpg" Resize "700x" />}}</center>

This is the main box. It has a 5v 16mhz ProMini, 12/5v 2a power supply and 2 10F 2.5v super capacitors. These 4 RCA inputs allow an external button to fire each relay individually. When nothing is plugged in they are all routed to the red button under the toggle switch

<center>
  {{< mosaic "1x1" "relaybox1.jpg" "relaybox2.jpg" >}}
</center>

When the input is fired the arduino closes the associated relay in this smaller box giving 4 of the DC barrel jacks 5V.

<center>
  {{< image "diode.png" />}}
</center>

This setup gave me a little more grief than I’d have liked. The arduino could fire 3 of the relays at once but not 4. To fix this, I had to let the arduino sink the current instead of sourcing it which led me to an inductive feedback problem but it was easily solved by adding a diode across the load.

<center>
  {{< image "2013-07-02-10.54.27.jpg" Resize "225x" />}}
  {{< image "2013-07-02-11.03.02.jpg" Resize "225x" />}}
  {{< image "2013-07-02-11.05.30.jpg" Resize "225x" />}}
</center>

The most reliable way I’ve found to ignite visco fuse with 40awg nichrome is to use a needle and thread the wire through the fuse. Throw a little electrical wire so that it doesn’t pull out. I give the wire enough current long enough for it to break.

Everything fit in fairly well, there is a cubby on the box lid to hold the spool of nichrome and the relay box fits fairly snugly.

The arduino is running a simple program that can be found [here](https://github.com/zinefer/arduino-relay-igniter). You can configure a delay before firing each individual relay.

I was too scared to risk burning the state down or getting a fine, so here is a fairly underwhelming demonstration:

{{< youtube oXFAP_K8HsA >}}