#!/bin/bash
clear

### Download sync files @ ./sync/last.txt and replace files in Gekko with these new files ###

# primary Gekko dir -- must be a valid path to your Gekko obviously (!)
# below will assume that you got e.g. /www/gekko_tools and /www/gekko, else change this.
gDir='../gekko'

outputDir="sync"

# get latest file from github
git pull

# colors
grn=$'\e[1;32m'
yel=$'\e[1;33m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

file=$(cat $outputDir/last.txt)
saveFile='sync.tar.gz';

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
printf "Downloading file ${yel}$file${end}, please stand by...";
get $file

printf "\n\n"

# untar
printf "Unpacking ${yel}$saveFile${end}...\n\n"
tar -xvzf $saveFile
echo

# sync new > old (and replace)
printf "Replacing old with new @ ${yel}gekko/ > $gDir ${end}\n\n"
rsync -ah gekko/* $gDir
echo

# remove crap
rm -rf gekko
rm -rf sync.tar.gz


printf "${grn}Completed.${end}\n\n"