+++
date = "2019-04-02T23:35:26-06:00"
title = "Diagnosing apparent step loss on the laser cutter"
description = "I thought I was having step loss on my new laser cutter but it turned out to be backlash accumulation"
categories = "Making"
tags = ["Laser Cutting"]
+++

Recently I was asked by [Julia Williams](http://designosaur.work/) to help out with her Game of Thrones art project. She has some rather complicated hand drawn stencils she wanted me to cut out of A4 cardstock.

<center>
  {{< image "ramsayart.png" "Resize" "700x" />}}
</center>

# The issue

<center>
  {{< mosaic "1x1" "20190320_162212.jpg" "ramsayzoom.png" >}}
</center>

As you can see, my first run had some pretty obvious errors. My first impression was that I was losing steps so I tried to remove all the extra appliances from the circuit to see if that increased accuracy. Also, due to the way my laser operates, I can issue a pulse at origin, start the program and then when it is finished it will attempt to return to the origin where I can pulse again and see the error much easier

<center>
  {{< mosaic "1x1" "20190320_162433.jpg" "20190320_162501.jpg" >}}
</center>

At this point I was starting to lose confidence that my issue was actually step-loss or signal noise. The main reason I was doubting this was that the error was very replicatable. Every time I would run the program and I measured the error it had very little deviation.

# What is backlash

<center>
  <img src="backlash.svg" width="600"/>
</center>

[Backlash](https://en.wikipedia.org/wiki/Backlash_(engineering)) is the space between the teeth of engaged gears. Every geared system has some amount of backlash and since my laser does not have [encoders](https://en.wikipedia.org/wiki/Encoder) like some of the more expensive machines so there is no feedback after a move command. Because of this, each time either axis motor reverses direction there is a small amount of backlash error that gets added to the position of the laser head. With a complicated enough path, over time the error will accumulate and every relative move will slowly drift off position.

# A solution

My laser has the ability to rehome and then return to the relative origin. This can be used to clear backlash error inbetween program runs. I grouped up paths into about 8 separate runs and the results were pretty great.

<center>
  {{< mosaic "1x1" "ramsaycolor.png" "20190403_002308.jpg" >}}
</center>