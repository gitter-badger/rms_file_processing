declare -a mainDirs=("DAB" "FM" "internet");

#Used for the calculation of next immidiate minute
#format [min, hour, day]
declare -a dt=(0 0 0);


host="ftp://192.168.1.100";
ago="date -R -d '5 minutes ago'";
# ago="Fri, 02 Nov 2018 14:28:44 +0530"

#echo "$(date -R -d $ago)"
startd=1
endd=59
starth=0
endh=23
startm=0
endm=59
maxEndD=59

echo "Init started";

getNextD () {
	if [ $3 -ge 59  ]
	then
		dt[2]=0;
	else
		dt[2]=$(($3+1));
	fi
}

getNextH () {
	if [ $2 -ge 23 ]
	then
		getNextD $1 $2 $3
		dt[1]=0;
	else
		dt[1]=$(($2+1));
	fi

}

getNextM () {
	dt[0]=$1; dt[1]=$2; dt[2]=$3;
	if [ $1 -ge 59 ]
	then
		getNextH $1 $2 $3
		dt[0]=0;
	else
		dt[0]=$(($1+1));
	fi
}

resetDT () {
	dt[0]=0; dt[1]=0; dt[2]=0;
}

setAgo () {
	echo "ago=\"date -Rd @$(stat -c %Y $1)\"" > ago;
}


echo "old endm = $endm";

filename="./metadata/init"

while read -r line
do
#     name="$line"
#     echo "Name read from file - $name, startd = $startd";
    eval "$line";
#     echo "new startd = $startd";
done < "$filename"

while read -r line
do
    eval "$line";
done < "ago"

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

						getNextM $m $h $d;
						mB=${dt[0]}; hB=${dt[1]}; dB=${dt[2]};
						resetDT
						# mB=$m; hB=$h; dB=$d;
						# if [ $m -eq 59 ] 
						# then
						# 	if [ $h -eq  23 ] 
						# 	then
						# 		if [ $d -eq $maxEndD ] 
						# 		then
						# 			dB = 0;
						# 		fi
						# 		hB = 0;
						# 	fi
						# 	mB = 0;
						# else
						# 	mB = $(($m+1));
						# fi
					
					#echo "$host/$mD/logger$lgs/$d/$h/$m";
					#echo "$host/$mD/logger$lgs/$d/$h/$(($m+1))"
						#echo "/$mD/logger$lgs/$d/$h/$m"; #25.91 seconds for step 1
						# 13.52 seconds for step 2
						fileA="./files/L$lgs-D$d-H$h-M$m.wma"
						fileB="./files/L$lgs-D$dB-H$hB-M$mB.wma"
                        fileOutName="L$lgs-D$d-H$h-MA$m-MB$mB"
						fileOut="./files/outs/$fileOutName.wma"
                        spllittedFileOut="./files/outs/splitted/$fileOutName"

						if [ -e "$fileA" ] && [ -e "$fileB" ]
						then
							continue;
						elif [ -e "$fileA" ] && [ ! -e "$fileB" ]
						then
							setAgo $fileA;
							m=$(($m-1));
							break;
						elif [ ! -e "$fileA" ] && [ -e "$fileB" ]
						then
							setAgo $fileB;
							break;
						fi

						statusA=$(curl "$host/$mD/logger$lgs/$d/$h/$m.wma" -o "$fileA" -z "$(eval $ago)" -R -s -w '%{http_code}')
						
						statusB=$(curl "$host/$mD/logger$lgs/$dB/$hB/$mB.wma" -o "$fileB" -z "$(eval $ago)" -R -s -w '%{http_code}')

						#curl "$host/$mD/logger$lgs/$d/$h/$(($m+1)).wma" -o "$(($m+1)).wma" -z "$(date -R -d '3 minutes ago')" -R
						if [ $statusA = '226' ] && [ $statusB = '226' ]
						then
							# echo $"\nStatusA= $statusA, StatusB= $statusB\n";
							if [ -e "$fileA" ] && [ -e "$fileB" ]
							then
								ffmpeg -f concat -safe 0 -i <(echo "file $PWD/$fileA"; echo "file $PWD/$fileB") -c copy "$fileOut" -y
                                ffmpeg -i "$fileOut" -f segment -segment_time 40 -c copy "$spllittedFileOut"%03d.wma -y
								rm $fileOut;

								# rm "$fileA" "$fileB"
                                ./process.sh

								getNextM $mB $hB $dB;
								newStm=${dt[0]}; newSth=${dt[1]}; newStd=${dt[2]};
								resetDT

								
								echo "startd=$newStd"$'\n'"endd=59"$'\n'\
								"starth=$newSth"$'\n'"endh=23"$'\n'\
								"startm=$newStm"$'\n'"endm=59"$'\n' > init;

								setAgo $fileB;

								# echo $"startm - $startm, endm - $endm \n";
								#echo $"logger - $lgs, min - $m";

								# if [ $m -lt 59 ] && [ $m -gt 0 ]
								# then
								# 	startm=$(($m-1));
								# 	endm=$(($m));
								# fi
								# if [ $m -eq 0 ]
								# then
								# 	if [ $h -gt 0]
								# 	then
								# 		starth=$(($h-1));
								# 	else
								# 		if [ $d -gt 0]
								# 		then
								# 			startd=$(($d-1));
								# 		else
								# 			startd=$maxEndD
								# 		fi
								# 	fi
								# 	startm=59
								# fi
								# starth=23
								# startm=59;
								# fi
								break;
							fi
							
								
						fi

	#ffmpeg -f concat -safe 0 -i <(echo "file $PWD/$filename1"; echo "file $PWD/$filename2") -c copy output.wma
	#rm $filename1 $filename2
					done
				done
			done;
			
		done
	fi
	#echo "$mD"
done
