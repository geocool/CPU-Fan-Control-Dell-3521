CPU Fan Control Dell 3521
=========================

A Ruby Script For Moderating CPU Fan On Dell Inspiron 3521   
   
###**Requirements** 

1) You must have installed ruby   
Ubuntu: sudo apt-get install ruby   
2) You must have loaded the i8k module   
Ubuntu: sudo modprobe -v i8k   
3) You must also install i8kctl   
Ubuntu: sudo apt-get install i8kctl   
4) After Installing i8kctl you must run this line:   
sudo sed -i.bak 's/ENABLED=0/ENABLED=1/' /etc/default/{i8kmon,i8kbuttons}   
   
###**Installation**
   
I have included an executable ruby script to install the fanControl script.   
It just copies the ruby script into the /usr/bin folder under the name of fanControl.   
Run Script As: ./Install.rb   

###**Run**
After install run script by writing in terminal fanControl. This will run in normal mode. If you have a compatible 'ASCII colors' terminal you can use the switch -owc to have a colored output.
You can also use -ch,-cl,-co with -no to instantly change fan state without monitoring. Use -h to view available switches   
   

###**Modes**
**..:: Normal Mode ::..**   
This is the normal mode that script runs when you execute it.   
You can see the temperatures of this mode in the output.   

**..:: Const  Mode ::..**   
This mode can be enable by const switches.   
Fan will be always in the status that you choose.   
Switch: -ch or -cl or -co   

**..:: SummerMode ::..**   
In Summer temperature are higher than usual (Especialy In Greece Where I live).   
For this reason fan speed will increase decrease at higher temperature values   
Switch: -sm   

###**Notes**   
**Note 1**   
This script may be used in other Dell Computers that use i8k module, but be careful.
Dell 3521 has only one fan (right fan) so in the script I don't moderate the left fan.
If you try this script in other Dell computer be carefull and do some tests.
After restarting your computer fan speed control will be back to the OS.   
   
**Note 2**   
This script runs in a loop. If for any reason crashes or you stopped it, your fan speed will remain at the last state. If this state is NULL (Closed Fan) you may damage your system. For this reason I included a feature that when temperature goes over 65c you will hear a sound. BUT be careful !!   

