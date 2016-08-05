Mobile Integrated Data Access System for Utilities (MIDAS) - Field Force Data Visualization Demonstration (FFDV) Version 1.0 (2012) Readme

----------------------
Notes:  

The software is intended to be installed from a development environment onto a mobile device running Apple iOS

The software is provided as a source code project and must be compiled and installed onto a compatible device using Apple's XCode Integrated Development Environment

There is no User's Manual for this software
  
----------------------
Platform Requirements:
	
Development Environment:
	Apple computer running Apple OS X 10.7.5-10.8.2
	Apple XCode v4.5
	Deployment on a compatible device requires a valid Apple iOS Developer Program License
	
Mobile Device:
	Apple iPad 2-4 or iPhone 4, 4S and 5 (3G models with GPS receivers are recommended)
	Apple iOS 5.1-6.01

----------------------------
Executing Instructions:

1. The source folder should be copied to a local or network drive
2. The MIDAS.xcodeproj file should be loaded in XCode
3. Under MIDAS->Build Settings->Code Signing a valid developer certificate should be selected for the "Debug" and "Any SDK" settings
4. A provisioned device should be connected to the computer
5. The user selects Product->Run which will compile the software then install and run it on the connected device
