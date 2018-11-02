declare -a dt=(0 0 0);

getNextD () {
	if [ $3 -eq 59  ]
	then
		dt[2]=0;
	else
		dt[2]=$(($3+1));
	fi
}

getNextH () {
	if [ $2 -eq 23 ]
	then
		getNextD $1 $2 $3
		dt[1]=0;
	else
		dt[1]=$(($2+1));
	fi

}

getNextM () {
	dt[0]=$1; dt[1]=$2; dt[2]=$3;
	if [ $1 -eq 59 ]
	then
		getNextH $1 $2 $3
		dt[0]=0;
	else
		dt[0]=$(($1+1));
	fi
}

getNextM 59 23 59
x=${dt[0]};
y=${dt[1]};
z=${dt[2]};
echo $x $y $z;