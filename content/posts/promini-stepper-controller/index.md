+++
date = "2018-09-23T20:47:22-06:00"
title = "Promini Stepper Controller"
description = "Working on a single motor stepper controller using an Arduino Promini and a A4988 for my desk lift project"
categories = "Hardware"
tags = ["Electronics", "Robotics", "Arduino", "Soldering", "Prototyping"]
+++

# Prototyping

I worked on this on an off for the past couple of weeks. Using the [A4988 product page](https://www.pololu.com/product/1182) I had this functional on the breadboard pretty quickly.

<center>
  {{< video "20180914_180049.mp4" "325" >}}
  {{< image "20180914_171939.jpg" "Fill" "325x180" />}}
</center>

I was running things off two separated power rails here and forgot about it after getting excited and plowing through to a premature prototype phase.

<center>
  {{< mosaic "3x1" "20180914_200423.jpg" "20180914_200646.jpg" "20180914_202928.jpg" "20180914_172345.jpg" >}}
</center>

For power I have 29V DC so I need something that can step that down. I found two buck modules that I found interesting. One based on the [LM2596](http://www.oddwires.com/lm2596-dc-dc-buck-converter-module-power-supply-output-fixed-5v/) and one on [MP1584](https://www.amazon.com/gp/product/B077TC3812/). I went with the MP1584 even though the listed maximum input voltage is 28V. I looked at the datasheet for the MP1584 and found that it lists an absolute maximum input voltage of 30 and I am not going to need anywhere near 3A to power a promini and the logic rails of the A4988.

<center>
  {{< image "20180920_163738.jpg" "Fill" "325x245" />}}
  {{< image "20180920_164032.jpg" "Resize" "325x" />}}
</center>

I did some testing on the bench with this setup and it seems to perform pretty well, driving the stepper motor for far longer periods of time than I will require for this project. The capacitor recommended by the A4988 product page is pretty neccesary.

During this project I wanted to try out some new techniques. I haven't done a circuit layout on paper in quite a while so I went for it. I had to learn some old lessons like not to use a ball point pen. On a trip to get a new pencil I learned about dot grid. Apparently though, dot grid index cards are complicated to get your hands on (shoutout to this [incredibly detailed blog post](https://www.mountainofink.com/blog/index-card-vortex)) so I made my own.

<center>
  {{< mosaic "1x3" "20180921_113953.jpg" "20180920_173831.jpg" "20180921_105049.jpg" "20180921_105903.jpg" >}}
</center>

# Main Build

I had a little trouble because this MP1584 wasn't quite 0.1" pitch. :(

<center>
  {{< mosaic "2x1" "20180921_123013.jpg" "20180921_123356.jpg" "20180921_123934.jpg" >}}
</center>

I normally build my circuit prototypes by bridging traces on a proto-pcb. For this one I wanted to just try making perfectly sized wire segments.

<center>
  {{< mosaic "1x3" "20180921_141232.jpg" "20180921_125233.jpg" "20180921_132616.jpg" "20180921_140025.jpg" >}}
</center>

# Finished

<center>
  {{< image "20180921_141239.jpg" "Fill" "325x245" />}}
  {{< image "thumb.jpg" "Resize" "325x" />}}
</center>

As a bonus, I took apart the switch I am considering using. I found that if you swap the output/power terminals on your standard automotive illuminated switch the led will be on regardless of the switch position, which is actually what I was looking for with this project.

<center>
  {{< mosaic "1x2" "20180921_155808_e.jpg" "20180921_155608.jpg" "20180921_160121.jpg" >}}
</center>
