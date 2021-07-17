+++
date = "2021-07-14T20:02:50-06:00"
title = "Pendant of Life"
description = "My first multicolor print!"
categories = "Making"
tags = ["3D Printing", "Multicolor", "Legends of the Hidden Temple", "Fusion 360"]
+++

I noticed [ComradeQuiche's](https://www.thingiverse.com/thing:509669) [Pendant of Life](https://legends.fandom.com/wiki/Pendants_of_Life) while looking for something to do with this really nice brass prusament and figured it would be a great print to experiment with virtual extruders for a multicolor print.

## Preparing a monocolor mesh for color in Fusion 360

[vwacholez](https://www.thingiverse.com/thing:4719744) added some holes for 2x4 magnets so I used his as a base.

I loaded the stl into Fusion360 to cut out a section underneath the raised sections to be our black background.

{{< imagecol "mesh.png" "Resize" "325x" >}}
  - Insert your mesh (stl)
  - Right click your project in the project tree and `Do not capture Design History`
  - Open `Mesh` tools in the `Design` workspace
  - `MODIFY` -> `Convert Mesh`
  - Right click your project in the project tree and `Capture Design History`
  - Edit model as needed
{{< /imagecol >}}

<center>
  {{< image "edits.png" "Resize" "700x" />}}
</center>

[[Download f3d]](pendant.f3d)

## Virtual Extruders in Prusa Slicer (2.3.1)

{{< imagecol "prusa.png" "Resize" "325x" >}}
  - Create a copy of your user preset
  - In the `Printer Settings` tab
      - under `General`, increase `Extruders` to the number of colors required
      - under `Custom G-code`, set `Tool change G-code` to `M600`
  - In the `Print Settings` tab, under `Multiple Extruders` disable the `Wipe tower`
{{< /imagecol >}}

<center>
  {{< image "gcode.png" "Resize" "700x" />}}
</center>

[[Download 3mf]](pendant.3mf)

## Results

<center>
  {{< mosaic "1x2" "20210714_110159.jpg" "20210714_145351.jpg" "20210714_113843.jpg" >}}
</center>

<center>
  {{< image "20210714_120509.jpg" "Resize" "700x" />}}
</center>

I tried out ironing for the first time. It's very effective when it works. I have been having an issue with my printer jamming during prints with lots of retracts but apparently that problem is also irritated by the extemely slow extrusion of the ironing feature.

<center>
  {{< mosaic "1x2" "20210714_160152.jpg" "20210714_160239.jpg" "20210714_160248.jpg" >}}
</center>




