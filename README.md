Wallbase.ss

=================

This is a simple bash script that automatically downloads wallpapers from the excellent website http://wallbase.cc and sets them as your desktop background. 

Wallbase.cc supports many different kinds of filters and search inputs and hence is an excellent source for getting your fix of wallpapers.

This script will automatically fetch the wallpapers from the aformentioned website at regular intervals.

It has the following dependencies:

	xdpyinfo -- To obtain the current resolution of the monitor.

	wget -- To perform the actuall HTTP requests.

	hsetroot -- yet another wallpaper application


The above dependencies are easily available in the package managers of your favorite distribution.


The script supports some command line options such as:

	-h OR --help		Show this help text.
	-v OR --verbose		Be verbose
	-i OR --interval	Interval in seconds, default 3600
	-t OR --toplist		Fetch wallpapers from toplist instead of random
	-d OR --dir		Input directory containing images, default '~/Pictures/Pulled/'

Sample use case:

Fetch a new wallpaper every half hour

./pullWP.sh -i 1800
