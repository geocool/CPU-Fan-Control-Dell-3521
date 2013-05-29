#!/usr/bin/ruby

#------------------------------------------------------------------------------
#Change Values#
  #A Name To Display While Installing
APP_NAME = "CPU Fan Control For Dell 3521" 
  #File To Be Installed (ex. ARubyFile.rb)
APP_FILE = "fanControl.rb"
  #The Command Name That User Will Run In Terminal (ex RubyExec)
APP_INSTALL_NAME = "fanControl"
#------------------------------------------------------------------------------
#Do Not Change Anything Bellow#
INSTALL_FOL = "/usr/bin/"

#Intro
puts "   ..:: General Installer ::.."
puts "A Ruby Script  By George Sofianos"
puts ""

#Copy Application
puts "Application Name   : #{APP_NAME}"
puts "Application Command: #{APP_INSTALL_NAME}"
puts ""

puts "Installer needs sudo rights to install Application"
system("sudo cp #{APP_FILE} #{INSTALL_FOL}#{APP_INSTALL_NAME}")
puts "Operation Finished"


