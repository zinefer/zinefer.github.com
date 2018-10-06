+++
date = "2018-09-21T09:19:07-06:00"
title = "Modeling an enclosure with snap-fits"
description = "Modeling an enclosure for the electronics and motor in the desk lift project"
categories = "Modeling"
tags = ["3D Printing", "Fusion 360", "Desk Lift"]
+++

I iterated on this for quite a while. Here are some highlights.

<center>
  {{< image "20180911_153919.jpg" "Fill" "325x236" />}}
  {{< image "one.png" "Resize" "325x" />}}
</center>

<center>
  {{< mosaic "1x2" "two.png" "20180914_135213.jpg" "20180923_154243.jpg" >}}
</center>

<center>
  {{< image "three.png" "Resize" "325x" />}}
  {{< image "20180922_144653.jpg" "Fill" "325x265" />}}
</center>

<center>
  {{< mosaic "3x1" "four.png" "20180927_191957.jpg" "20180926_002241.jpg" "20180924_023101.jpg" >}}
</center>

There are three types of snap-fits ([design guide](Plastic_Snap_fit_design.pdf)):

- Annular - the kind you find on a pen cap
- Cantilever - the most common joint
- Torsion - as best I can tell, these are defined by having a lever connected to the joint for release

<center>
  {{< image "section_analysis.png" "Resize" "700x" />}}
</center>

I believe all of these snap fits are cantilevers but I am a little unsure about the ones that hold the board in. There's not much of an arm to deflect.

<center>
  {{< video "20180927_192040.mp4" "700" >}}
</center>

<center>
  {{< image "thumb.jpg" "Resize" "700x" />}}
</center>
