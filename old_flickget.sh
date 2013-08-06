#!/bin/bash

mkdir $2
cd $2

#  $1 is supposed to be the adress of the flickr set
curl -s -o "page0.html" $1
num_pages=`cat page0.html | grep page= | wc | awk ' { print $1 } '`
echo "Start download $2, that has $num_pages pages."

#c style loop, amazing!
for ((a=0; a <= num_pages ; a++))
do

curl -s -o "page$a.html" $1
num_pages=`cat page$a.html | grep page= | wc | awk ' { print $1 } '`

	count=0;
	url_l=`cat page$a.html | grep thumb_link | awk ' { print $2 } ' | wc | awk ' { print $3 } '`
	url_l2=`cat page$a.html | grep thumb_link | awk ' { print $2 } ' | wc | awk ' { print $2 } '`
	#echo "u: $url_l u2:$url_l2" 
	url_l=`echo "($url_l/$url_l2)-2" | bc`
	#echo "result: $url_l" 
	for i in `cat page$a.html | grep thumb_link | awk ' { print $2 } ' | cut -c 7-$url_l`
	do
		#echo "$i"
		count=`echo "$count+1" | bc`
		ii=`echo http://www.flickr.com$i`
		#echo "$ii - $count"
		curl -s -o "subpage$count.html" $ii
		
		#disabled bc u need to b signed in to download big photos
		#zoomPage1=`cat "subpage$count.html" | grep zoomUrl | awk ' { print $3 } ' | cut -c 2-30`
		#zoomPage2=`cat "subpage$count.html" | grep zoomUrl | awk ' { print $3 } ' | cut -c 31-59`
		#zoomPage=`echo "http://www.flickr.com $zoomPage1 size=o& $zoomPage2" | tr -d " "`
		#echo "zoompage>>$zoomPage<<"
		#curl -o "zoom.html" "$zoomPage"
		#finalurl=`cat zoom.html | grep static.flickr.com | head -1 | awk ' { print $3 } ' | cut -c 5-71`
		#echo "finalurl>> $finalurl"
		
		finalurl=`cat "subpage$count.html" | grep photoImgDiv | awk ' { print $8 } ' | cut -c 6-57 | tr -d "?"`
		#echo "finalurl>> $finalurl"

		curl -s -O $finalurl
		page=`echo "$a+1" | bc`
		echo "name:$2 page:$page img:$count"
	done


done
rm *.html