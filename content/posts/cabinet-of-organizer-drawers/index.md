+++
date = "2021-08-24T21:35:34-06:00"
title = "Cabinet of Organizer Drawers"
description = "It's a long road to getting a well organized shop but a nice set of drawers goes far"
categories = "Making"
tags = ["CNC Routing", "Fusion 360", "Furniture", "Organization"]
+++

I've been planning this one since the [Parametric assortment bins]({{< ref "/posts/parametric-assortment-bins" >}}) post at the beginning of the year.

# Design

<center>
  {{< image "design.png" "Resize" "700x" />}}
</center>

One of the big wins for this project was discovering a better workflow for laying out my part plates for routing.

<center>
  {{< mosaic "1x1" "spoilboard.png" "20210804_203743.jpg" >}}
</center>

I'm now placing my origin at the origin of my spoilboard and I have modeled my hold-down features which has given me an incredible confidence around being able to lay out and execute my plates while still holding the material down well.

<center>
  {{< mosaic "1x1" "20210731_111644.jpg" "20210731_120355.jpg" >}}
</center>

<br/>

{{< imagecol "cuttabs.png" "Resize" "325x" >}}
  Another big improvement to my process was learning that I can use a 2D Contour with `Rest Machining` enabled and the machining boundary set to `Silhouette` to cut the tabs. Be careful not to use `Bounding Box`. For me, it almost did the right thing but would miss 1 or two tabs. A keen eye will notice a face on the front of the drawers that I damaged after removing it from the router table due to me not noticing these sneaky tabs.
{{< /imagecol >}}

{{< imagecol "20210810_104333.jpg" "Resize" "325x" >}}
  Thanks to a bit of pressure from [Jason](https://accidental.engineering/) I adjusted my bin size to 50x50x50mm and judging by how many nearly empty 1x1 bins I have already, I think he was very right.

  I've also created some tool specific variants but I plan on making some dedicated posts for those later.
{{< /imagecol >}}

# Assembly

<center>
  {{< image "20210731_212111.jpg" "Resize" "700x" />}}
</center>

I did not give enough of a fitness tolerance to the inside of the drawers so I ended up having to do an extra relief operation on all the drawer sides. That led to it's own mistake and I had a bit of an unsightly gap that I decided to wood fill and chisel to try to hide.

<center>
  {{< mosaic "1x1x1" "20210817_112846.jpg" "20210817_112836.jpg" "20210817_112821.jpg" >}}
</center>

I had big plans to use brad nails and no clamps during glueing but it never seems to work out.

<center>
  {{< mosaic "1x1" "20210811_084514.jpg" "20210815_084913.jpg" >}}
</center>

<center>
  {{< image "thumb.jpg" "Resize" "700x" />}}
</center>

<center>
  {{< image "20210815_131130.jpg" "Resize" "700x" />}}
</center>

[Ryan](https://www.linkedin.com/in/kramerryan/) reminded me to include some extra gap for the slides and that was really smart because these drawer slides really need to "float" on their spring tabs for a smooth operation. I added 1/16" for each but I think with router precision I would have been better off with 1/32".

<center>
  {{< mosaic "1x2" "20210815_174814.jpg" "20210819_113831.jpg" "20210821_082923.jpg" >}}
</center>

{{< imagecol "20210824_211924.jpg" "Resize" "325x" >}}
  I finished this project with an oil based ARM-R-SEAL Satin from General Finishes. Just a single coat because I liked the raw plywood look.
{{< /imagecol >}}

<center>
  {{< mosaic "2x1" "20210825_003411.jpg" "20210824_162052.jpg" "20210824_211949.jpg" >}}
</center>

<center>
  {{< image "20210825_152009.jpg" "Resize" "700x" />}}
</center>

<center>
  {{< image "20210825_003424.jpg" "Resize" "700x" />}}
</center>
