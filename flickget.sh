#!/bin/bash
#$1 - url
#$2 - dir_name
#$3 - app_path
#$4 - username
#$5 - password

cd "$3"
cd ..
mkdir "$2"
cd "$2"

#lets create the cookie file by logging in (if they provide user & pass)
if [ $5 ]
then
    curl -F "email=$4" -F "password=$5" -F "remember_me=1" -c cookies.curl -l  http://www.flickr.com/signin/flickr/
    echo "Logged in Flickr as $4"
fi



#  $1 is supposed to be the adress of the flickr set
curl -s -b cookies.curl -o "page0.html" $1
if [ -e "page0.html" ]
then
    
    num_pages=`cat page0.html | grep page= | wc | awk ' { print $1 } '`

    aux=`echo "$num_pages+1" | bc`
    echo "Start download $2, that has $aux pages."

    #c style loop, amazing!
    for ((a=0; a <= num_pages ; a++))
    do

    curl -s -b cookies.curl -o "page$a.html" $1
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
		    
		    if [ $5 ] # we have login info
		    then
			#echo "we have login info!"
			curl -s -b cookies.curl -o "subpage$count.html" $ii
			zoomPage1=`cat "subpage$count.html" | grep zoomUrl | awk ' { print $3 } ' | cut -c 2-30`
			zoomPage2=`cat "subpage$count.html" | grep zoomUrl | awk ' { print $3 } ' | cut -c 31-59`
			zoomPage=`echo "http://www.flickr.com $zoomPage1 size=o& $zoomPage2" | tr -d " " | tr -d ";" | tr -d "\'"`
			#echo "zoompage>>$zoomPage<<"
			curl -b cookies.curl -s -o "zoom.html" "$zoomPage"
			finalurl=`cat zoom.html | grep static.flickr.com | grep -v buddyicons |  head -1 | awk ' { print $12 } ' | cut -c 7-62 | tr -d "\""`
			#echo "finalurl>> $finalurl"
			
			curl -b cookies.curl -s -O $finalurl
			
		    else # no login info
			#echo "we DONT have login info!"
			curl -s -o "subpage$count.html" $ii
			finalurl=`cat "subpage$count.html" | grep photoImgDiv | awk ' { print $8 } ' | cut -c 6-57 | tr -d "?"`
			#echo "finalurl>> $finalurl"
			curl -s -O $finalurl
		    fi
		    page=`echo "$a+1" | bc`
		    echo "$2>> downloaded image $count from page $page"
	    done


    done
    rm *.html
    rm cookies.curl
else
	echo  "ERROR getting $2! You either typed a wrong URL or this user's FlickrSet is not public! :("
fi