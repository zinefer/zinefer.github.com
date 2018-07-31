+++
date = "2009-03-05T00:00:00-04:00"
title = "FRC Radio Config 2009"
tags = ["software","First Robotics","C#"]
+++

{{< imgproc "radioconfig_screenb.jpg" Resize "375x" "floatright" />}}
I have been the WPA Key (person?) at four 2009 District Regional Competitions. Giving out WPA keys to teams isn't a very good idea, considering if a team lost theirs, and a malicious person got hold of it, they could connect to the fields wireless system, and perhaps disable a robot by deleting its internal program.

After realizing this we decided not to pass out anymore WPA sheets and have them come to a "WPA Station" where we would configure their radio for them. Needless to say, this was pretty time consuming. Sometime during the third event I started to write a script to configure the radios with just the input of the team number and WPA key. It wasnt very friendly, but worked great.

This had me thinking, why couldn't I return the responsibility back to the team, while keeping a very fast, efficient, and very secure option. So I developed this tool.


# Set-up

To set this up you will first need to have the FTA print the one set to WPA keys as normal, your will then need to create a .keys file containing all team numbers and WPA keys, to do this, right click your desktop and create a new file. Name this file "WPA Keys.keys" open this file in notepad and configure it like this:

```
[Teams]
33=77777777
47=88888888
65=99999999
201=7777777
910=33333333
```

You should still be careful when typing these in, the tool will detect obvious typos but more subtle will still get through. Place the keys file into a flash drive and take it to the "WPA Station" (the computer running the FRC Radio Config software) start the program and type "9093". This will automatically detect and install the new keys file.

You will then need a power adapter for the radio, a pin to for the factory setting reset and an ethernet cable. Plug the ethernet cable into the radio, aswell as the power, hold the reset button with the pin until the light turns orange. Then type the team number and press enter.

ALSO: Remember to reset the radio to factory settings by holding the small reset button between power and the ethernet cable before trying to configure a router.

### Program Details
- Easy to use interface
- Configures a radio in less than 15 seconds
- Automatically downloads updates
- Automatically detects and updates internal keys file
- Automatically sets the stations IP to static
- Command line switches for windowed (-w), (-su) to supress updates and show command (-sc) modes

### Special Commands
- 9090: Exits the program
- 9091: Displays teams who have completed their WPA
- 9092: Displays teams who have not completed their WPA
- 9093: Updates keys file

<br/>

<center>[Download](#abc)</center>