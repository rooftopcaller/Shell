#!/bin/ksh
echo "#############get update dbfile############# "
db_input_file="dbinput.txt"
filter="^#|^$"
#将空行和注释行过滤掉，判断脚本的有效行数
input_valid_record=`cat ${db_input_file}|grep -vE "${filter}"|wc -l`

#如果有效的输入记录条数为零，则不再进行后续的操作
if [  ${input_valid_record} -eq 0 ];then     	
     echo   输入文件${db_input_file}中，有效的输入记录条数为零，脚本不能进行后续的操作
     exit 300
else
	cat ${db_input_file}|grep -vE "${filter}">${db_input_file}.tmp.filter
	#过滤以后的文件名称回复为输入文件名称
	cp ${db_input_file}.tmp.filter ${db_input_file}   
	 #清除临时文件
     rm  ${db_input_file}.tmp.*
     
fi

cd ./dbupdate
rm -rf *

#for line in `cat ${db_input_file}`
cat ../${db_input_file} | while read line
do
#line="initdb.sh \"ntdemo|so1|INSX_TMNTD_TO_EXTER\" ct"
#echo ${line}   $line    "$line"
	exetype=`echo ${line}|awk  '{print $1}'`
	model=`echo ${line}|awk  '{print $2}'|awk   -F"\"" '{print $2}'|awk  -F"|" '{print $2}'` 
	if [ "${model}" = "so1" ];then
		model="so"
	fi

	if [  "${exetype}" = "initdb.sh"  ];then
	  	svn co --no-auth-cache --username wangxiang --password ailk123  http://10.11.20.110/svn/DOC-CRM-INTERNATIONAL/release/06.Project/International%20Project/Nepal%20NT/03.Design/01%20%e5%9f%ba%e7%a1%80%e6%95%b0%e6%8d%ae/${model} ./${model}
	elif  [  "${exetype}" = "exesql.sh"  ];then
 		sqlfile=`echo ${line}|awk  '{print $3}'|awk   -F"\"" '{print $2}'|awk  -F"|" '{print $1}'` 
 		if [ ! -d "./${model}/sql" ];then
 	    		 svn co --no-auth-cache --depth=empty  --username wangxiang --password ailk123  http://10.11.20.110/svn/DOC-CRM-INTERNATIONAL/release/06.Project/International%20Project/Nepal%20NT/03.Design/01%20%e5%9f%ba%e7%a1%80%e6%95%b0%e6%8d%ae/${model}_nttest/sql ./${model}/sql
		fi
		cd ./${model}/sql 
		svn up --no-auth-cache --username zouxy --password ailk123 ${sqlfile}
		cd ../..
		
	fi

done

#zip file
currentTime=`date +"%Y-%m-%d %T"`
zip -r "dbupdatefile_${currentTime}.zip"  * 
