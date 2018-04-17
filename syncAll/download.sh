#!/bin/bash
clear

### Download sync files @ ./sync/last.txt and replace files in Gekko with these new files ###

# colors
grn=$'\e[1;32m'
yel=$'\e[1;33m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# check config.sh
if [ ! -f config.sh ]; then
    printf "${red}ERROR${end} config.sh could not be found, copy config.sample.sh and modify to suit your needs!\n"
    return
fi

# import user config ($gDir)
source config.sh

outputDir="sync"

# get latest file from github
git pull



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
