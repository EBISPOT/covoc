#!/bin/bash

set -e

file=$1

echo $file

while IFS='|' read sheet url
do 
	wget "$url" -O ../templates/"$sheet"_do_no_edit.tsv
done <$file