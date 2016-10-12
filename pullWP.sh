#!/bin/bash
## This script will automatically pull a wallpaper list from Wallbase.cc
## choose a random one, and then apply it.
## Uses feh, an X11 background setter as the backend

#######
##Purity flags, 1=true, 0=false
##########
## SFW -- Safe For Work
## Sketchy -- between
## NSFW -- Not Safe For Work
SFW=1;
SKETCHY=0;
NSFW=0;

##Type of wallpapers, unset/comment to disable serving those types
WALLPAPERS_GENERAL=2;
ANIME_MANGA=1;
HIGH_RES=3;

## Login credentials, optional, comment out if not in use
username="username"
password="password"

## Interval, default, in seconds
interval=3600;

## Home location for wallpapers
WP_HOME="$HOME/Pictures/Pulled/"

## List type, can be "random" or "toplist"
LIST_TYPE="random"

## Your background setter command
## can be anything like feh, nitrogen, hsetroot, xsetbg... et al
image_command="feh --bg-fill"

##--------------------------------------------------------------------------
##DO NOT EDIT ANYTHING BELOW THIS LINE
##############

##Show the Help!
show_help()
{
	echo "USAGE: pullWP.sh [OPTIONS]"
        echo "Options specified on the command line, override the configuration file."
        echo "Possible options are:"
        echo "-h OR --help              Show this help text."
        echo "-v OR --verbose		Be verbose"
	echo "-i OR --interval		Interval in seconds, default 3600"
	echo "-t OR --toplist		Fetch wallpapers from toplist instead of random"
        echo "-d OR --dir		Input directory containing images, default '~/Pictures/Pulled/'"
        #echo "-a OR --appl		fill, tile or stretch, default 'fill'"
}

## '$#' Stands for the total number of arguments.
## '$1' The variable that holds the current option/argument. 
## shift agument is the value that is shifted to the next arguments using the "shift" command.

verbose="-q";

#echo "$#";
while [[ $1 == -* ]];
do
	case "$1" in
		-h|--help) show_help; exit 0;;
		-v|--verbose) verbose=""; shift;;
		-t|--toplist) LIST_TYPE="toplist"; shift;;
		-i|--interval)
		if (($# > 1)); then
			interval=$2;
			shift 2;
		  else
			echo "ERROR: Option -i requires an argument" 1>&2;
			exit 1;
		fi ;;
		-d|--directory)
		if (($# > 1)); then
			WP_HOME=$2;
			shift 2;
		  else
			echo "ERROR: Option -d requires an argument" 1>&2;
			exit 1;
		fi ;;
#		-a|--appl)
#		if (($# > 1)); then
#			wp_type=$2;
#			shift 2;
#		else
#			wp_type=fill;
#			shift 2;
#		fi ;;
		--) shift; break;;
		-*) echo "ERROR: Invalid option: $1" 1>&2; show_help; exit 1;;
	esac
done



## NOTICE: WILL FAIL IF YOU HAVE MORE THAN ONE SCREEN OR IF YOU DONT HAVE X RUNNING.
## Autodetect resolution from xdpyinfo
SCREEN_RES=$(xdpyinfo | awk ' /dimensions/ { print $2 } ');

## calculate screen ratio
SCREEN_RATIO=$(echo "scale=2; $(echo $SCREEN_RES | sed 's/x/\//')" | bc); 


## wallbase.cc random URL to pull list of images from
##WALLBASE_CC="http://wallbase.cc/random/213/eqeq/1600x900/1.77/110/32"
WALLBASE_CC="http://wallbase.cc/$LIST_TYPE/$WALLPAPERS_GENERAL$ANIME_MANGA$HIGH_RES/eqeq/$SCREEN_RES/$SCREEN_RATIO/$SFW$SKETCHY$NSFW/32"
WALLBASE_LOGIN="http://wallbase.cc/user/login"
WALLBASE_LOGOUT="http://wallbase.cc/user/logout"

#echo "Computed URL ---> $WALLBASE_CC";

## Max images to choose RANDOM from
MAX=32;

load_cookies="";

## Make directories if they do not exist, exit if we encounter problems
mkdir -p $WP_HOME || exit 1;

while true;
do
	MY_R=$RANDOM;
	## Bring my random number below $MAX value
	let "MY_R %= $MAX";

	#echo "RANDOM NUMBER --------->>>>>> $MY_R";

	### Get the list, parse list, get nth random name from list.
	WP_PAGE=$(wget $verbose $WALLBASE_CC -O - | awk -F\" ' /id=\"drg_thumb/ { print $2 } ' | head -n $MY_R | tail -n1);

	if [[ $NSFW == 1 && -n $username && -n $password ]];
	then
		## Log in
		wget $verbose -O /dev/null --save-cookies cookies.txt --post-data "usrname=$username&pass=$password" $WALLBASE_LOGIN
		load_cookies="--load-cookies cookies.txt";
	fi
	
	### Open that wallpapers page, look for image source, base64 decode it.
	IMG_LINK=$(wget $verbose $load_cookies $WP_PAGE -O - | awk -F\' ' /\+B/ { print $4 } ' | base64 -d);

	if [[ $NSFW == 1 ]];
	then
		## Log out
		wget $verbose -O /dev/null $load_cookies $WALLBASE_LOGOUT
		rm -f cookies.txt
	fi

	### Finally, get the actual image
	wget $verbose -P $WP_HOME $IMG_LINK;

	### Get the stored image name.
	IMG_NAME=$( echo $IMG_LINK | awk -F\/ ' { print $NF }');

	### Set the image as wallpaper.
	$image_command $WP_HOME/$IMG_NAME;

	## Go to sleep
	sleep $interval;
done
