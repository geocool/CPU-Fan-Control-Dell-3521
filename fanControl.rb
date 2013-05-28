#!/usr/bin/ruby
=begin

..:: SummerMode ::..
In Summer Temperature are higher than usual (Especialy In Greece where I live).
For this reason fan High Mode Starts And Stops At Higher Temp Values
*Set SummerMode True Or False At $summerMode Global

..:: Super Freeze Mode ::..
Supper Freeze Mode is a mode that will be on when temperature is high.
Fan speed will be high until reaches the mid_temp or until reaches a lower temp
than high && a certain time passes
TODO Time Interval Until Freeze Mode Is Off
----

-Fan Speeds-
NO_FAN_TEMP is the max Temperature For NULL Fan(No fan)
HIGH_FAN_TEMP is the min Temperature For High Fan Speed
LOW_FAN_TEMP is a mid Temperature used for stopping High Temperature
---

FanControl Documentation
---------------------------------------------------------------
initialize: 	 Checks For i8k Module.
isInit?: 	 Returns If Object Initialized Properly
setFan(mode): 	 Set Fan Speed To NULL-LOW-HIGH
getFanStatus: 	 Returns Fan Status NULL-LOW-HIGH
getFanStatusStr: Returns Fan Status In String
getTemp: 	 Returns Temperature As Integer
---------------------------------------------------------------



"------- Available Switches -------"
" -ch :  Const High Mode"
" -cl :  Const Low  Mode"
" -co :  Const Off  Mode"
" -no :  No Output"
" -ns :  No Safe Sound"
" -sm :  Summer Mode On"
"----------------------------------"
=end

#Constants
NO_FAN   = 0
LOW_FAN  = 1
HIGH_FAN = 2

NO_FAN_TEMP = 49
LOW_FAN_TEMP = 53
HIGH_FAN_TEMP = 57

SUM_NO_FAN_TEMP = 52
SUM_LOW_FAN_TEMP = 56
SUM_HIGH_FAN_TEMP = 60

#Global Variables
$superFreezeMode = false
$summerMode = false
$updateInterval = 4
$exit = false
$constControl = false
$safeSound = true
$espeak = false
$colorOut = false

class FanControl

  # Checks For i8k Module Load And i8kctl exec
  # sets isInit? to True On Success Or False On Fail
  def initialize()
    #Check IF i8k Is loaded
    res = IO.popen("lsmod | grep i8k")
    if(!res.read.include?("i8k"))
      @isInit = false
      puts "i8k Module Is Not Loaded"
      puts "Please Load It Using modprobe -v i8k"
      puts "Then run sed -i.bak 's/ENABLED=0/ENABLED=1/' /etc/default/{i8kmon,i8kbuttons}"
      return
    end
    
    #check if i8kctl exists TODO
    
    
    @isInit = true
  end
  
  #Sets Fan Mode (NO,LOW,HIGH)
  def setFan(mode)

    if !@isInit
      return
    end
    
    case mode.to_i
      when NO_FAN
	IO.popen("i8kctl fan - 0")
	#puts "Fan Set To Null At Temp: #{getTemp}"
      when LOW_FAN
	IO.popen("i8kctl fan - 1")
	#puts "Fan Set To Low At Temp: #{getTemp}"
      when HIGH_FAN
	IO.popen("i8kctl fan - 2")
	#puts "Fan Set To High At Temp: #{getTemp}"
    end
  
  end

  # Returns Fan Status
  def getFanStatus
    
    if !@isInit
      return -1
    end
    
    res = IO.popen("i8kctl fan")
    fanArray = res.read.split(" ")
    return fanArray[1].to_i
  end
  
  # Returns Fan Status As String
  def getFanStatusStr
    
    if !@isInit
      return ""
    end
    
    case getFanStatus
    when NO_FAN
      return "NULL"
    when LOW_FAN
      return "LOW"
    when HIGH_FAN
      return "HIGH"
    end
  end

  # Returns CPU Temperature
  def getTemp
    
    if !@isInit
      return -1
    end
    
    res = IO.popen("i8kctl temp")
    return res.read.to_i
  end
  
  #Returns If Object Initialized(Load Module etc)
  def isInit?
    return @isInit
  end
end

# ------------------------------------------------------------------- #
def constSpeedControl(mode)
  #Create FanControl Object
  control = FanControl.new
  control.setFan(mode)
end

def speedControl
  
  #Create FanControl Object
  control = FanControl.new
  cFanStatus = control.getFanStatus
  cTemp = control.getTemp
  
  #Check If Initialized OK, If Not Exit
  if(!control.isInit?)
    $exit = true
    return
  end
  
   #Set Default Temperatures
  if($summerMode)
    low_temp = SUM_NO_FAN_TEMP # NULL FAN
    mid_temp = SUM_LOW_FAN_TEMP # FREEZE OFF FAN
    hig_temp = SUM_HIGH_FAN_TEMP # HIGH FAN
    #NOTE - LOW FAN = >NO_FAN  && < HIGH_FAN
  else
    low_temp = NO_FAN_TEMP
    mid_temp = LOW_FAN_TEMP
    hig_temp = HIGH_FAN_TEMP
  end
  
  if(!$constControl)
  # Control Fan Speed By Temperature
  if(!$superFreezeMode)
    
    if(cTemp <= low_temp && cFanStatus!= NO_FAN)
      control.setFan(NO_FAN)
      system("espeak 'Fan is Off'") if $espeak
    elsif(cTemp > low_temp && cTemp < hig_temp && cFanStatus!= LOW_FAN)
      control.setFan(LOW_FAN)
      system("espeak 'Fan is Low'") if $espeak
    elsif(cTemp >= hig_temp && cFanStatus!= HIGH_FAN)
      control.setFan(HIGH_FAN)
      system("espeak 'Fan is High'") if $espeak
      $superFreezeMode = true
    end
  else
    if(cTemp <= mid_temp)
      $superFreezeMode = false
    end
  end
  
  # Print Info
  printInfo(cTemp,cFanStatus,low_temp,mid_temp,hig_temp)
  
  end

  # Const Mode Safe
  if($safeSound &&  $constControl && 
    cFanStatus !=HIGH_FAN &&  cTemp >= hig_temp)
    
    print "\a" # Beep Sound
    $updateInterval = 1 # Small Update Interval Cause OF Safe Mode
  end
  
end

#Terminal Output , CurrentTemp,CurrentFanStatus
def printInfo(cTemp,cFanStatus,low_temp,mid_temp,hig_temp)
  # Print To Terminal Info
    system("clear")
  puts "\033[36m\033[1m" if $colorOut
  puts "  ..:: CPU Fan Control ::.."
  puts "A Ruby Script By George Sofianos"
  puts "  For Dell Inspiron 3521 Only"
  puts "\033[0m"  if $colorOut
  puts "" #NEWLINE
  
  # Colored Information Output
  if($colorOut)
  puts "--------- \033[33m\033[1mInformation\033[0m -----------"
  puts "---------------------------------"
  puts "\033[1mCurrent Mode:\033[0m         Summer Mode" if $summerMode && !$constControl
  puts "\033[1mCurrent Mode:\033[0m         Normal Mode" if !$summerMode && !$constControl
  puts "\033[1mCurrent Mode:\033[0m         Const  Mode" if $constControl
  puts "\033[1mSuper Freeze Mode:\033[0m    \033[31mON\033[0m " if $superFreezeMode
  puts "\033[1mSuper Freeze Mode:\033[0m    OFF " if !$superFreezeMode
  puts "\033[1mFan State:\033[0m            NULL" if cFanStatus == NO_FAN
  puts "\033[1mFan State:\033[0m            \033[33mLOW\033[0m" if cFanStatus == LOW_FAN
  puts "\033[1mFan State:\033[0m            \033[31mHIGH\033[0m" if cFanStatus == HIGH_FAN
  puts "\033[1mCurrent Temperature:\033[0m  \033[31m" + cTemp.to_s  + " C\033[0m" if cTemp >= hig_temp
  puts "\033[1mCurrent Temperature:\033[0m  " + cTemp.to_s  + " C" if cTemp < hig_temp
  puts "\033[1mUpdate Interval:\033[0m      " + $updateInterval.to_s + " seconds"
  puts "---------------------------------"
  puts "---------------------------------"  
  #Temperature Table
  puts "" #NEWLINE
  puts "------- \033[33m\033[1mTemperature Table\033[0m -------"
  puts "---------------------------------"
  puts "\033[1mNULL State :\033[0m **c - #{low_temp}c"
  puts "\033[1mLOW  State :\033[0m #{low_temp}c - #{hig_temp}c"
  puts "\033[1mHIGH State :\033[0m #{hig_temp}c - **c"
  puts "\033[1mFreeze Off :\033[0m #{mid_temp}c"
  puts "---------------------------------"
  puts "---------------------------------"
    #Non Color Information Output
  else
    puts "--------- Information -----------"
  puts "---------------------------------"
  puts "Current Mode:         Summer Mode" if $summerMode && !$constControl
  puts "Current Mode:         Normal Mode" if !$summerMode && !$constControl
  puts "Current Mode:         Const  Mode" if $constControl
  puts "Super Freeze Mode:    ON " if $superFreezeMode
  puts "Super Freeze Mode:    OFF " if !$superFreezeMode
  puts "Fan State:            NULL" if cFanStatus == NO_FAN
  puts "Fan State:            LOW" if cFanStatus == LOW_FAN
  puts "Fan State:            HIGH" if cFanStatus == HIGH_FAN
  puts "Current Temperature:  " + cTemp.to_s  + " C"
  puts "Update Interval:      " + $updateInterval.to_s + " seconds"
  puts "---------------------------------"
  puts "---------------------------------"
  #Temperature Table
  puts "" #NEWLINE
  puts "------- Temperature Table -------"
  puts "---------------------------------"
  puts "NULL State : **c - #{low_temp}c"
  puts "LOW  State : #{low_temp}c - #{hig_temp}c"
  puts "HIGH State : #{hig_temp}c - **c"
  puts "Freeze Off : #{mid_temp}c"
  puts "---------------------------------"
  puts "---------------------------------"
  end


    
end

# Here Script Starts
def main
  ARGF.argv.each{
    |arg|
    if(arg.include?("-ch")) # high
      constSpeedControl(HIGH_FAN)
      $constControl = true
    elsif(arg.include?("-cl")) # low
      constSpeedControl(LOW_FAN)
      $constControl = true
    elsif(arg.include?("-co")) # Off
      constSpeedControl(NO_FAN)
      $constControl = true
    end
  
    if(arg.include?("-no")) # No Output (exit After Action)
      $exit = true
    end
  
    if(arg.include?("-ns")) # No Safe Sound
      $safeSound = false
    end
  
    if(arg.include?("-sm")) # Summer Mode
      $summerMode = true
    end
  
    if(arg.include?("-es")) # Summer Mode
      $espeak = true
    end
  
    if(arg.include?("-owc")) # Summer Mode
      $colorOut = true
    end
  
    # Show Available Switches
    if(arg.include?("-h"))
    system("clear")
    puts "  ..:: CPU Fan Control ::.."
    puts "A Ruby Script By George Sofianos"
    puts "  For Dell Inspiron 3521 Only"
    puts "" #NEWLINE
    puts "------- Available Switches -------"
    puts " -ch :  Const High Mode - High Fan Speed"
    puts " -cl :  Const Low  Mode - Low  Fan Speed"
    puts " -co :  Const Off  Mode - Off  Fan"
    puts " -no :  No Output       - Use It With Const Modes For Fast Fan Control"
    puts " -ns :  No Safe Sound   - Close Safe High Temp Sound On Const Mode"
    puts " -sm :  Summer Mode On  - High Speen Fan In Higher Temperatures"
    puts " -es :  Espeak On       - Let epseak notify about changes"
    puts " -owc:  Out With Color  - Add Colors To The Output"
    puts "----------------------------------"
    puts "" #NEWLINE
  
    $exit = true
    end
  }

  

  loop{
  # Moderate Fan Speed , Prints Output
  if(!$exit)
    speedControl
  end
  #Break Loop If FanControl Not Initialized Successfully
  if($exit)
    break
  end

  # Sleep Used For Lower CPU Usage
  sleep($updateInterval)
  }
end

#Call Main
main