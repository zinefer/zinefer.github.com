+++
date = "2019-06-05T16:51:41-06:00"
title = "Independently Scaling slots of Slotted Assemblies in Fusion 360"
description = "I needed to scale a dinosaur to epic proportions"
categories = "Modeling"
tags = ["Fusion 360", "Routing", "Laser Cutting", "Dinosaurs", "Parametric"]
+++

Before importing the design into Fusion I wanted to have the slots closed off but I still needed the slots included in the vector. I found a pretty easy process for this in illustrator:

- Use the select tool to select the slot and copy it to the clipboard
- Use the pen tool to selete each point of the slot, effectively closing off the slot
- Clean up the closed path if the shape looks weird
- Paste the old slot data back in-place for reference in Fusion

<center>
  {{< image "illustrator_match_paths.png" "Resize" "225x" />}}
  {{< image "illustrator_close_paths.png" "Resize" "225x" />}}
  {{< image "centered_path_smoothing.png" "Resize" "225x" />}}
</center>

Now import those paths via SVG into Fusion and mark all the slot information as construction.

<center>
  {{< image "fusion_construction_slots.png" "Resize" "700x" />}}
</center>

Create a `original_slot_size` parameter and use this to create a construction line to define the center of our slots.

<center>
  {{< image "fusion_locate_slots.png" "Resize" "700x" />}}
</center>

Create a unitless `scale` parameter and use it to do a Modify->Scale on the import sketch.

<center>
  {{< image "fusion_scale_main_sketch.png" "Resize" "700x" />}}
</center>


Create a `slot_size` parameter and a new sketch. Here we will create contours for our sized slots.

<center>
  {{< image "fusion_sketch_slots.png" "Resize" "700x" />}}
</center>

Extrude the contours to `slot_size` and cut the slots and any other cutouts through all.

# Features that relate to the size of the slot

You may find yourself with features that aren't satisfyingly solved by simply linearly bridging the gap between the slots. For example, the bottom most arc on this part:

<center>
  {{< image "slot_related_features_problem.png" "Resize" "700x" />}}
</center>

Solving issues like these will require a bit of creativity in fusion. For me, the basic process is:

- Project the base geometry into the new sketch
- Mark issue lines as construction
- Use constraints to recreate the line such that it fits the construction well enough in your desired range of slot sizes

Most importantly though, everything needs to reference geometry inside the first sketch to maintain accurate scaling.

<center>
  {{< image "slot_related_features_solution.png" "Resize" "700x" />}}
</center>

I like to use straight construction lines across the arc, create a perpendicular marker from the construction to the arc and then use Fit Splines to match the curve. You may find it useful to set the control lines for the fit spline to be parallel to the construction line. If you have fillets in areas like this you should use a feature and not try to do it in the sketch. You can use `scale` parameter here to make sure it's always the same size.

One problem you may find when you adjust the Fit Spline control lines, is that after a scale the curves are wonky. One solution I've found for this is to create a point inside the scaled sketch and link your control arm to that. Beware, this is very tricky, so try not to have to touch the control arms.