#!/bin/bash
clear

# colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
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
mkdir -p $outputDir

# dir string
DIRS="$gDir/strategies $gDir/config"



# ask user if history should be included or not
read -p "${yel}Include history?${end} [y/n]: " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
    then
        DIRS+=" $gDir/history"
        echo "${cyn}OK -- including history${end}"
fi

echo
printf "Compressing the files/folders ${yel}$DIRS${end} \nDestination folder: ${yel}$outputDir${end}\n"
printf "${grn}Please wait...${end}\n\n"

# compress
tar -czf "$outputDir/sync.tar.gz" $DIRS
echo
printf "${yel}Compression completed.${end}\n\n"


# upload to transer.sh
transfer() {
	if [ $# -eq 0 ];
		then echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md";
		return 1;
	fi

	tmpfile=$( mktemp -t transferXXX );
	if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g');
		curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile;
	else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ;
	fi;
	echo "Your file: ";
	cat $tmpfile;
	file=$(cat $tmpfile);
	cat > $outputDir/last.txt <<< $file
	rm -f $tmpfile;
}

printf "${grn}Uploading to transfer.sh, please wait...${end}\n\n"

transfer "$outputDir/sync.tar.gz"
printf "\n"
printf "${yel}Done.${end}\n\n"

printf "Saved lastfile src to: ${yel}$outputDir/last.txt${end}\n\n"

# remove old compressed file
rm -rf "$outputDir/sync.tar.gz"
