#!/bin/bash
clear

# ------------------------------
#
# Download sync files @ lastupload/last.txt
# ...and replace files in Gekko
#
# -------------------------------

# imports
source imports/common.sh
source imports/colorizer.sh

# check config.sh
if [ ! -f config.sh ]; then
    colorize "<light-red>ERROR</light-red> config.sh could not be found, copy config.sample.sh and modify to suit your needs!\n"
    return
fi

# check if last.txt file exist
if [ ! -f lastupload/last.txt ]; then
    colorize "<light-red>ERROR</light-red> last.txt could not be found under lastupload so there's nothing to download.\n"
    return
fi

# import user config
source config.sh

outputDir="lastupload"
file=$(cat $outputDir/last.txt)
saveFile="$outputDir/sync.tar.gz";

# get $filename function
get() {
	if [ $# -eq 0 ];
		then echo -e "No arguments specified.";
		return 1;
	fi
	echo
	echo
	curl "$1" >> $saveFile;
}

# get the file
colorize "Downloading <light-yellow>$file</light-yellow>, please stand by...."
get $file

printf "\n\n"

# untar
colorize "Unpacking <light-yellow>$saveFile</light-yellow>...\n"
tar -xvzf $saveFile
echo

# sync new > old (and replace)
colorize "Replacing old with new @ <light-yellow>$gekkoDir/history</light-yellow>\n"
rsync -ah gekko/* $gekkoDir
echo

# remove crap
rm -rf gekko
rm -rf "$outputDir/sync.tar.gz"

colorize "<light-green>Completed.</light-green>\n"
