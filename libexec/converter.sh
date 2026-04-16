#/bin/sh
echo "$1" | iconv -f utf-8 -t utf-16le - | xxd -p | 
  awk '{
      gsub(/.{1,2}/,"&h, ")   # add delimiter after every 2 chars
  }1' | sed -e 's/^/db /' | sed -e 's/, $//'
