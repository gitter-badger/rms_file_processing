splittedPath="./files/outs/splitted/"
spllittedFileOut="$splittedPath$fileOutName"
# echo "$spllittedFileOut";
for wmafile in $splittedPath*.wma;
do
    echo "splitted File is: "$wmafile;
    # echo $'\n'$wmafile >> "fingerprints";
    ./fpcalc $wmafile > "temp";

    while read -r line
    do
        eval "$line";
    done < "./temp"
    # eval ./fpcalc $wmafile;
    echo "Duration - "$DURATION", Fingerprint - "$FINGERPRINT  >> "fingerprints";
    rm "temp" $wmafile

done