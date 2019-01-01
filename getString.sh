#!/bin/bash
date0=$(date '+%Y-%m-%d %H:%M:%S')
#echo $date0
date1=`date -d "$date0" +%s`        #modify to time stamp
#echo $date1
date2=`expr $date1 - 120`
#echo $date2
date=`date -d @$date2 '+%Y%m%d%H%M%S'`
#echo $date
newdate=`date -d @$date2 '+%Y-%m-%d %H:%M:%S'`
#echo $newdate

key=$1
if [ "$key" == "" ] ; then
	echo -e "\nKeyword can not be null!"
	echo -e "You should use it as \"cmd keyword ftp_ip user passwd\". \n"
	exit 0
fi

keyword=$key
dir=.
test ! -d $dir && echo -e "The $dir is not exit.\n\n" && exit 0
echo -e "\n--------------------------------------------------------------------------"
echo -e "--------- The CDR files you find after $newdate are: ----------"
echo -e "--------------------------------------------------------------------------\n"

file_count=0
all_files=""
cdr_files=""

#the filelist format is like:  dir: 
										#file
										#dirname
file_list=`ls -R $dir 2> /dev/null | grep -v '^$'`   											 			
#echo -e "$file_list \n"
for file_name in $file_list
do
	temp=`echo $file_name | sed 's/:.*$//g'`     														#remove ":" after dir name
	if [ "$file_name" != "$temp" ] ; then																	#if file_name!=temp then temp is dir,if file_name==temp then temp is text file or dir
		cur_dir=$temp																								#if temp is dir, then set current dir as temp, read and process next file
	else
		file_type=`file $cur_dir/$file_name | grep "text"`  											#if temp is file,then get the file type with absolute path
		if [ "$file_type" != "" ] ; then
			#echo -e "$cur_dir/$file_name \n"     								 	  					#if the file is a text file
			temp=`grep $keyword $cur_dir/$file_name 2> /dev/null` 		 					#check whether the keyword is inclued in the text file 
			if [ "$temp" != "" ] ; then
				suffix=${file_name%%_*}
				if [ "$suffix" == "SYS" ] ; then
					rm -rf $cur_dir/$file_name
				fi
				all_files="$all_files $cur_dir/$file_name"
				let file_count++
			fi
		fi
	fi
done

echo -e "Total find $file_count CDR files: $all_files\n"
file_count=1

for singlefile in $all_files               																		   #read the file including the keyword and check every single line for keyword
do
	HMS=$(date '+%H%M%S')
	prefix=${singlefile%_*}
	newfile=""$prefix"_"$HMS".unl"
	echo -e "----------------------------- Process File $file_count -----------------------------"
	echo -e "$singlefile\n"

	content=`grep $keyword $singlefile | sed 's/ //g'` 											 #get every line within keyword in one file and temperly set it to content, and remove " " ,so line64 will work
	echo -e "new content:\n$content\n\n"
	count=1																  										#set the initial line 	in the content to 1
	
	for string in $content
	do
		echo "$string" > string.txt
		echo -e "getString:\n$string\n"
		oper_date=$(awk -F"|" '{print $2}' string.txt)   																		#get the operator time of every record
		oper_date=`echo $oper_date |awk 'gsub(/../,"& ")  {print $1$2"-"$3"-"$4" "$5":"$6":"$7 }'`      #use command 'awk' to convert to time stamp
		#oper_date=`echo $oper_date |sed 's/\(....\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3 \4:\5:\6/'         			#or you can use sed command
		oper_date=`date -d "$oper_date" +%s` 
		if [ "$oper_date" -ge "$date2" ] ; then																					#compare the time 
			echo -e "$singlefile -----> $newfile:"
			echo "$string" >> $newfile
			echo -e "$string\n"
			if [ $count == 1 ] ; then																										#when the first process is done, set cdr_files  as newfile  
				cdr_files="$cdr_files $newfile"
			fi
			let count++
		fi
	done
	let file_count++
done

echo -e "\n----------------------------- New CDR Files: -----------------------------"
echo -e "$cdr_files\n"

###FTP###
remote_ip=$2
user=$3
passwd=$4
echo "open $remote_ip
			user $user $passwd
			bin
			prompt off" > putfile
#all_files=`echo $all_files 2> /dev/null | grep -v '^$'`

for file_name in $cdr_files
do
	base_name=$(basename $file_name)
	echo -e "put $file_name ./$base_name" >> putfile
done
ftp -i -n < putfile

rm -rf string.txt $cdr_files putfile
