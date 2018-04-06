#!/bin/bash
clear

# ------------------------------
#
# UPLOAD GEKKO HISTORY DATA
# To transfer.sh + get link
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

# import user config
source config.sh

# create output dir
outputDir="lastupload"
mkdir -p $outputDir

# dir
historyDir="$gekkoDir/history"

echo
colorize "COMPRESSING HISTORY DIRECTORY \n---\nDestination folder: <light-yellow>$outputDir</light-yellow>\n"
colorize "<light-green>Please wait, it might take a while...</light-green>\n"

# compress
tar -czf "$outputDir/sync.tar.gz" $historyDir

# msg
colorize "<light-yellow>Compression completed.</light-yellow>\n"

colorize "UPLOADING TO TRANSFER.SH \n---\n"

# upload
transfer "$outputDir/sync.tar.gz"

colorize "\n\n<light-yellow>Completed.</light-yellow>\n"

colorize "Saved lastfile src to: <light-yellow>$outputDir/last.txt</light-yellow>\n"

# remove old compressed file
rm -rf "$outputDir/sync.tar.gz"
