#!/bin/sh
find content/post/ -type f | xargs head -n 5 | grep tags | grep -o -E "\".*\"" | sed 's/,//g' | xargs -n 1 | sort | uniq -c  
