declare -a mainDirs=("DAB" "FM" "internet");

#Used for the calculation of next immidiate minute
#format [min, hour, day]
declare -a dt=(0 0 0);


host="ftp://192.168.1.100";
ago="date -R -d '5 minutes ago'";
minAgo=$(date -d '5 minutes ago' +%s);

startd=1
endd=59
starth=0
endh=23
startm=0
endm=59
maxEndD=59

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
	while read -r line
	do
		curAgo=$(cut -d "@" -f 2 <<< "$line");
		break;
	done < "ago"
	# if [ -s "ago" ]
	# then
	# if [ curAgo ]
	# 	echo "ago=\"date -Rd @$(stat -c %Y $1)\"" > ago;
	# fi
}


echo "old endm = $endm";

filename="./metadata/init"

while read -r line
do
    eval "$line";
done < "$filename"

while read -r line
do
    eval "$line";
done < "ago"


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

for mD in "${mainDirs[@]}"
do
	if [ "$mD" = "FM" ]
	then
		for lgs in {1..2};
		do
			
			for d in $(eval echo {$startd..$endd});
			do
				
				for h in $(eval echo {$starth..$endh});
				do
					
					for m in $(eval echo {$startm..$endm});
					do

						getNextM $m $h $d;
						mB=${dt[0]}; hB=${dt[1]}; dB=${dt[2]};
						resetDT
						
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


						if [ "$statusA" == '226' ] && [ "$statusB" == '226' ]
						then

							if [ -e "$fileA" ] && [ -e "$fileB" ]
							then
								ffmpeg -f concat -safe 0 -i <(echo "file $PWD/$fileA"; echo "file $PWD/$fileB") -c copy "$fileOut" -y
                                ffmpeg -i "$fileOut" -f segment -segment_time 40 -c copy "$spllittedFileOut"%03d.wma -y
								rm $fileOut;

                                ./process.sh

								getNextM $mB $hB $dB;
								newStm=${dt[0]}; newSth=${dt[1]}; newStd=${dt[2]};
								resetDT

								echo "startd=$newStd"$'\n'"endd=59"$'\n'"starth=$newSth"$'\n'"endh=23"$'\n'"startm=$newStm"$'\n'"endm=59"$'\n' > init;
								
								setAgo $fileB;
								break;
							fi
							
								
						fi
					done
				done
			done;
			
		done
	fi
done
