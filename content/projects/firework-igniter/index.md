+++
date = "2013-07-03T04:56:00-04:00"
title = "Firework Igniter"
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

<center>{{< image "glam.jpg" Resize "700x" />}}</center>

This is the main box. It has a 5v 16mhz ProMini, 12/5v 2a power supply and 2 10F 2.5v super capacitors. These 4 RCA inputs allow an external button to fire each relay individually. When nothing is plugged in they are all routed to the red button under the toggle switch

<center>
  {{< image "relaybox1.jpg" Resize "350x" />}}
  {{< image "relaybox2.jpg" Resize "350x" />}}
</center>

When the input is fired the arduino closes the associated relay in this smaller box giving 4 of the DC barrel jacks 5V.

<center>
  {{< image "diode.png" />}}
</center>