# Sonar - WoW TBC Classic Addon for Gathering Professions
WoW TBC Classic Addon for cycling through (available) minimap tracking types for gathering professions

Upon Addon initialization, all available tracking types (for professions - things like track flightmaster or track mailbox do not count for this addon) for the current character are detected and added to an array. This array is then looped through continuously and every GCD the next tracker in the list is selected; this almost gives the feel to the player like their minimap is a radar: pinging-out and detecting all available gatherable items in the vicinity.

Note that this addon will only work If the currently logged-in character has at MINIMUM 2 profession minimap trackers to toggle through. If the current character has 1 or less toggle-able minimap gathering professions, the Sonar addon with turn itself off.

Currently Sonar does not have a GUI. This will be the next step once the back-end is nailed down. 

You must interact with it through command line:
 - "/snr help" to print list of commands
 - "/snr S" to Start Sonar
 - "/snr E" to End Sonar
 - "/snr TRACKTYPE" to list detected tracking methods
 
!!!!!!! 
HEXADECIMATOR TODO: 
1. Add a macro that toggles "/snr S" or "/snr E" according to whether the addon is currently running or not. Place the code for this macro here in this readme (this will act as a bandaid fix until the GUI is in place).
!!!!!!!
