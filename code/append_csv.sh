
#!/bin/bash

rm ALL_LIBS.csv

for f in *1920*.csv
do

 tail -n+2 $f
 [ -n "$(tail -c1 $f)" ] && echo ""

done >> ALL_LIBS.csv

                     
