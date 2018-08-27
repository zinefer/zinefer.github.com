+++
date = "2018-08-26T23:51:45-06:00"
title = "Herringbone Gears for Stepper Motor"
description = "Using some OpenScad scripts to prototype for an upcoming project"
categories = "Modeling"
tags = ["OpenScad", "3D Printing"]
+++

I want to try to automate my standing desk so that getting it into the exact position when standing is easier.

<center>
  {{< image "20180827_002001.jpg" "Fill" "700x350 center" />}}
</center>

The NEMA17 steppers I have lying around are a bit hard to identify but I think they're going to give me ~3.5 ft/lb.


<center>
  {{< image "20180827_001751.jpg" "Fill" "700x500 center" />}}
</center>

My desk is a [MultiTable](https://www.multitable.com/product/multitable-manual-mod-table/). I bought a digital torque wrench from Harbor Freight but it is not sensitive enough to give me the amount of force required to raise the desk. I do know that it must be somewhere under 20 ft/lb. I'll just print out some prototypes and see if I can't figure anything else out.

I'm using the [parametric herringbone](https://www.thingiverse.com/thing:6544/files) script for now. Here's the settings from my first attempt:

<code>
// OPTIONS COMMON TO BOTH GEARS:
distance_between_axels = 35;
gear_h = 10;
gear_shaft_h = 7  ;


// GEAR1 (SMALLER GEAR, STEPPER GEAR) OPTIONS:
// It's helpful to choose prime numbers for the gear teeth.
gear1_teeth = 13;
gear1_shaft_d = 5.25;       // diameter of motor shaft
gear1_shaft_r  = gear1_shaft_d/2;
// gear1 shaft assumed to fill entire gear.
// gear1 attaches by means of a captive nut and bolt (or actual setscrew)
gear1_setscrew_offset = 3.5;      // Distance from motor on motor shaft.
gear1_setscrew_d         = 3.5;
gear1_setscrew_r          = gear1_setscrew_d/2;
gear1_captive_nut_d = 6.2;
gear1_captive_nut_r  = gear1_captive_nut_d/2;
gear1_captive_nut_h = 3;


// GEAR2 (LARGER GEAR, DRIVE SHAFT GEAR) OPTIONS:
gear2_teeth = 31;
gear2_shaft_d = 0;
gear2_shaft_r  = gear2_shaft_d/2;
// gear2 has settable outer shaft diameter.
gear2_shaft_outer_d = 18;
gear2_shaft_outer_r  = gear2_shaft_outer_d/2;

// gear2 has a hex bolt set in it, is either a hobbed bolt or has the nifty hobbed gear from MBI on it.
gear2_bolt_hex_d       = 9;
gear2_bolt_hex_r        = gear2_bolt_hex_d/2;
// gear2_bolt_sink: How far down the gear shaft the bolt head sits; measured as distance from drive end of gear.
gear2_bolt_sink          = 0;
// gear2's shaft is a bridge above the hex bolt shaft; this creates 1/3bridge_helper_h sized steps at top of shaft to help bridging.  (so bridge_helper_h/3 should be > layer height to have any effect)
bridge_helper_h=-1;

gear2_rim_margin = 2;
gear2_cut_circles  = 5;
</code>

This should give me a ratio of about 2.38.

<center>
  {{< image "thumb.png" "Resize" "350x" />}}
  {{< image "20180826_203702.jpg" "Fill" "350x248 center" />}}
</center>
