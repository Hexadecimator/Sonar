# Sonar - WoW TBC Classic Addon for Gathering Professions
WoW TBC Classic Addon for cycling through (available) minimap tracking types for gathering professions

Important: You must put the .toc, .lua, and .xml files together in your addons folder, in a folder named "SONAR". The addons folder is commonly found at the following path: \World of Warcraft\_classic_\Interface\AddOns\SONAR

Upon Addon initialization, all available tracking types (for professions - things like track flightmaster or track mailbox do not count for this addon) for the current character are detected and added to an array. This array is then looped through continuously and every GCD the next tracker in the list is selected; this almost gives the feel to the player like their minimap is a radar: pinging-out and detecting all available gatherable items in the vicinity.

Note that this addon will only work If the currently logged-in character has at MINIMUM 2 profession minimap trackers to toggle through. If the current character has 1 or less toggle-able minimap gathering professions, the Sonar addon will turn itself off.

Currently Sonar does not have a GUI. This will be the next step once the back-end is nailed down. 

You must interact with it through command line:
 - "/snr help" to print list of commands
 - "/snr s" to Start Sonar
 - "/snr e" to End Sonar
 - "/snr tracktype" to list detected tracking methods
