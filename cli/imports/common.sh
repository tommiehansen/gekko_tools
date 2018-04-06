#!/bin/bash

# colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# upload to transer.sh
# use: transer "$file"
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
