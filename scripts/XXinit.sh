declare -a mainDirs=("DAB" "FM" "internet")
host="ftp://192.168.1.100"
ago="date -R -d '1 hour ago'"
#echo "$(date -R -d $ago)"
startd=1
endd=59
starth=0
endh=23
startm=0
endm=59


echo "old endm = $endm";

filename="./metadata/init"
while read -r line
do
    # name="$line"
    # echo "Name read from file - $name, startd = $startd";
    eval "$line";
    # echo "new startd = $startd";
done < "$filename"

# for line in $(<filename);
# do
# 	eval $line;
# 	# name="$line"
#     # echo "Name read from file - $name, startd = $startd";
#     # eval "$line";
#     # echo "new startd = $startd";
# done

echo "new endm = $endm";

if [ ! -z "$1" ]
then
	startd=$1;
	endd=$((startd+1))
fi

if [ ! -z "$2" ]
then
	starth=$2;
	endh=$((starth+1))
fi

if [ ! -z "$3" ]
then
	endd=$3;
fi

if [ ! -z "$4" ]
then
	endh=$4;
fi

# echo $"sd=$startd, endd=$endd, starth=$starth, endh=$endh";

for mD in "${mainDirs[@]}"
do
	if [ "$mD" = "FM" ]
	then
		for lgs in {1..2};
		do
			#echo "$mD/logger$lgs";
			for d in $(eval echo {$startd..$endd});
			do
				#echo "/$mD/logger$lgs/$d/";
				for h in $(eval echo {$starth..$endh});
				do
					#echo "/$mD/logger$lgs/$d/$h";
					for m in $(eval echo {$startm..$endm});
					do
					
					#echo "$host/$mD/logger$lgs/$d/$h/$m";
					#echo "$host/$mD/logger$lgs/$d/$h/$(($m+1))"
						#echo "/$mD/logger$lgs/$d/$h/$m"; #25.91 seconds for step 1
						# 13.52 seconds for step 2
						fileA="./files/L$lgs-D$d-H$h-M$m.wma"
						fileB="./files/L$lgs-D$d-H$h-M$(($m+1)).wma"
						fileOut="./files/outs/L$lgs-D$d-H$h-MA$m-MB$(($m+1)).wma"

						statusA=$(curl "$host/$mD/logger$lgs/$d/$h/$m.wma" -o "$fileA" -z "$(eval $ago)" -R -s -w '%{http_code}')
						
						statusB=$(curl "$host/$mD/logger$lgs/$d/$h/$(($m+1)).wma" -o "$fileB" -z "$(eval $ago)" -R -s -w '%{http_code}')

						#curl "$host/$mD/logger$lgs/$d/$h/$(($m+1)).wma" -o "$(($m+1)).wma" -z "$(date -R -d '3 minutes ago')" -R
						if [ $statusA = '226' ] && [ $statusB = '226' ]
						then
							# echo $"\nStatusA= $statusA, StatusB= $statusB\n";
							if [ -e "$fileA" ] && [ -e "$fileB" ]
							then
								ffmpeg -f concat -safe 0 -i <(echo "file $PWD/$fileA"; echo "file $PWD/$fileB") -c copy "$fileOut"
								rm "$fileA" "$fileB"
								# echo $"startm - $startm, endm - $endm \n";
								#echo $"logger - $lgs, min - $m";
								if [ $m -lt 59 ] && [ $m -gt 0 ]
								then
									startm=$(($m-1));
									endm=$(($m));
								fi
								if [ $m -eq 0 ]
								then
									if [ $h -gt 0]