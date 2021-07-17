#!/bin/bash
# 作者：黄海针
tool_name="PerfTools"
version="3.6.8"
update_time="20210604"
update_server="10.8.13.22"
Internal_network="10.8."
update_content="\n1、优化内存测试提示\n2、更新弹框增加延迟\n3、当前网段与升级服务器不一致时，引导联网更新\n4、新增隐藏功能，有缘则现\n5、修复负载功能bug"

upup(){

	update_status="no"
	now_time="$(date +'%m%d%H')"
	if [[ -e $HOME/.tool_update ]]; then
		up_time="$(cat $HOME/.tool_update)"
		if [[ "${now_time}" == "${up_time}" ]]; then
			skip_update="true"
		else
			skip_update="false"
			date +'%m%d%H' > $HOME/.tool_update
			chmod 777 $HOME/.tool_update
		fi
	else
		date +'%m%d%H' > $HOME/.tool_update
		chmod 777 $HOME/.tool_update
		skip_update="false"
	fi
	#myip="`ifconfig |head -2|grep inet|awk '{print $2}'`"
	myip="`hostname -I`"
	[[ "${myip}" =~ "${Internal_network}" ]] && upz=0 || upz=1
	if [ "${upz}" == "0" ];then
		echo ""
		echo "检测工具版本更新,请稍等..."
		p=`ping -c1 ${update_server}`
		if [ "$?" == "0" ];then
			mkdir ${PWD}/.update_test_p
			wget -q ftp://${update_server}/update_p/* -P ${PWD}/.update_test_p
			new=`ls ${PWD}/.update_test_p/`
			if [ "${0##*/}" == "${new}" ]
			then
				rm -rf ${PWD}/.update_test_p
				update_show=""
			else
				rm -rf ${PWD}/.update_test_p
				update_show="`echo -e "\e[33m[有更新] \e[0m"`"
				if [[ "${skip_update}" == "false" ]]; then
					if ! command -v zenity &> /dev/null; then
						sudo apt install -y zenity &> /dev/null
					fi
					if command -v zenity &> /dev/null; then
						sleep 0.5
						if zenity --question --text "✔ ${tool_name}\n✔ 检测到新版本\n\n是否升级到最新版本?\nPs.弹框频率1H" --ok-label "YES" --cancel-label="NO" --width='180' &>/dev/null; then
							update_status="yes"
						else
							update_status="no"
						fi
					fi
				fi
			fi
		else
			update_show=""
		fi
	else
		if [[ "${skip_update}" == "false" ]]; then
			if zenity --question --text "✔ ${tool_name}\n✔ 检测到当前非内网环境：${Internal_network}x.x\n\n为确保为最新版本，是否进行联网更新？\n\nPs.弹框频率1H" --ok-label "YES" --cancel-label="NO" --width='266' &>/dev/null; then
				update_status="yes"
			else
				update_status="no"
			fi
		fi
		update_show="`echo -e "\e[33m[请联网更新] \e[0m"`"
	fi
}

broadcast(){

	if [[ -e $HOME/.perftool_version ]]; then
		old_version="$(cat $HOME/.perftool_version)"
		if [[ "${version}" == "${old_version}" ]]; then
			skip_broadcast="true"
		else
			skip_broadcast="false"
			echo ${version} > $HOME/.perftool_version
			chmod 777 $HOME/.perftool_version
		fi
	else
		echo ${version} > $HOME/.perftool_version
		chmod 777 $HOME/.perftool_version
		skip_broadcast="false"
	fi
	if [[ "${skip_broadcast}" == "false" ]]; then
		if ! command -v zenity &> /dev/null; then
			sudo apt install -y zenity &> /dev/null
		fi
		if command -v zenity &> /dev/null; then
			sleep 0.5
  			zenity --info\
    		--text="✔ ${tool_name}更新\n\
✔ 更新版本：${version}\n\
✔ 更新时间：${update_time}\n\n\
✔ 更新内容：${update_content}" --width='330' &>/dev/null
		fi
	fi
}

setup(){

	if test -d demand
	then
		rm -rf demand
	fi
	if test -d ${PWD}/.update_test_p
	then
		rm -rf ${PWD}/.update_test_p
	fi
	rm -rf wget-log
}

MAINC(){

	# echo ""
	# echo "提示：是否退出工具？"
	# echo "取消操作：输出'N'"
	# echo "确认停止：点击Enter"	
 #    read -p "输入：" end
 #    if [ "${end}" = "n" -o "${end}" = "N" ]; then
 #    	echo ""
 #    	echo "已取消操作！"
 #    else
	    setup
		bye="`whoami`"
		echo ""
		echo ""
		echo -e "bye bye : \033[32m${bye}\033[0m"
	    exit
    # fi
}


CtrlC(){

	echo "+++++++++++++++++++++++++++++++++++++^C"
	echo "提示：当前监控已暂停，是否完全停止监控？"
	echo "取消操作：输出'N'"
	echo "确认停止：点击Enter"	
    read -p "输入：" end
    if [ "${end}" = "n" -o "${end}" = "N" ]; then
    	echo ""
    	echo "已取消操作，监控继续！"
    	echo "^C+++++++++++++++++++++++++++++++++++++^C"
    else
    	read -p "提前测试结束，监控时长【${time}秒】，文件已保存至目录：【${PWD}/PerfData/】，点击Enter关闭工具！" Enter
    	exit
    fi

}

DemandC(){

	if test -d demand
	then
	 	rm -rf demand
	 	exit
	else
		exit
	fi
}

menu1(){
	tput clear	 
	tput cup 1 1
	printf "————————————————————————————————————————————————————————————————"
	
	tput cup 3 25
	tput rev
	printf "  Perf - Tools  "
	tput sgr0
	

	tput cup 4 45
	tput setaf 3
	printf "——.Z"
	tput sgr0
	
	tput cup 6 1
	tput setaf 3
	echo "性能测试"
	tput sgr0
	tput cup 7 1
	printf "%s\t%s\t\t%s" 1、启动录制工具 2、视频文件解帧 3、响应耗时计算
	tput cup 8 1
	printf "%s\t%s" 4、查询进程信息 5、资源占用监控

	tput cup 10 1
	tput setaf 3
	echo "其他测试/辅助项"
	tput sgr0	
	tput cup 11 1
	printf "%s\t%s\t\t%s" 6、应用内存检测 7、内存log分析 8、系统资源负载
	tput cup 12 1
	printf "%s"  9、捕获应用包名

	tput cup 14 1
	tput setaf 3
	echo "辅助功能"
	tput sgr0	
	tput cup 15 1
	printf "%s\t\t%s\t\t%s"  h、帮助信息 c、用户意见墙 z、工具箱
	tput cup 16 1
	printf "%s"  q、在线更新${update_show}
	
	tput cup 17 1
	printf "————————————————————————————————————————————————————————————————"

}


menu2(){
	tput clear	 
	tput cup 1 1
	printf "————————————————————————————————————————————————————————————————"
	
	tput cup 3 15
	tput rev
	printf " 工具箱子菜单 "
	tput sgr0
	

	tput cup 4 35
	tput setaf 3
	printf "——.Z"
	tput sgr0
	
	tput cup 6 1
	tput setaf 3
	echo "工具箱"
	tput sgr0
	
	tput cup 7 1
	printf "%s" 1、生成随机文件
	tput cup 8 1
	printf "%s" 2、scp传输文件
	tput cup 9 1
	printf "%s" 3、系统信息
	tput cup 10 1
	printf "%s" 4、下载UosTools工具

	tput cup 16 1
	printf "%s\t%s"  z、返回PerfTools主菜单	
	tput cup 17 1
	printf "————————————————————————————————————————————————————————————————"

}




main (){
	trap "MAINC" INT
	setup
	broadcast
	upup
	while true
	do
		clear
		menu1
		tput cup 18 1
		if [ "${update_status}" == "no" ]; then
			read -p "输入上方菜单编号:" action
		elif [ "${update_status}" == "yes" ]; then
			action="q"
		fi
		case $action in
			z)
				while true
				do
					clear
					menu2
					tput cup 18 1
					read -p "输入上方菜单编号:" action2
					case $action2 in
						1)
							read -p "输入需生成的文件格式：" format
							read -p "输入文件大小（Kb），直接回车则随机生成：" size
							usrname="`who|grep tty1|awk '{print $1}'`"
							filepath="/home/${usrname}/Desktop/filetest"
							if test -d "${filepath}"
							then
									sleep 0.1
							else
									sudo bash -c "mkdir -p ${filepath}"
									sudo bash -c "chmod 777 ${filepath}"
							fi
							if [ ${format} ]
							then
								if [ ${size} ]
								then
									size=${size}
									num1=1
									for ((i=1;i<=${num1};i++))
									do
										bash -c "dd if=/dev/urandom of=${filepath}/${format}_${size}KB.${format} bs=1KB count=${size}"&>/dev/null
										echo ""
										echo "创建文件成功：${format}_${size}KB.${format}"
									done	
								else
									#size=${RANDOM}
									read -p "输入创建文件数量，直接回车则仅生成1个文件：" num1
									echo ""
									if [ ${num1} ]
									then
										  num1=${num1}
									else
										  num1=1
									fi
									for ((i=1;i<=${num1};i++))
									do
										size=${RANDOM}
										bash -c "dd if=/dev/urandom of=${filepath}/${format}_${size}KB.${format} bs=${size}KB count=1"&>/dev/null
										echo "创建文件成功：${format}_${size}KB.${format}"
									done	
								fi
							echo ""
							read -p "已导出至${filepath}，点击Enter后返回菜单!" Enter
							else
								echo "无效格式，请重新输入，3秒后返回菜单！";sleep 3
							fi
							;;	
						2)
							read -p "输入/拖入需要传输的文件(在工具相同目录下可不带路径):" file
							if [ ${file} ]
							then
								read -p "输入远程机账号:" name
								if [ ${name} ]
								then
									myip=`ifconfig |head -2|grep inet|awk '{print $2}'`
									echo " * 仅支持${myip%.*}.x 内网段传输文件。"
									read -p " * 输入远程机IP最后一位（${myip%.*}.x，直接输入'x'）:" num
									if [ ${num} ]
									then
										scp ${file} ${name}@${myip%.*}.${num}:~/Desktop
										echo ""
										echo "上方若有报错信息，则传输失败，检查输入是否正确！"
										read -p "默认发送文件【${file}】至远程机【${myip%.*}.${num}】桌面，点击Enter返回主菜单！" enter
									else
										echo "输入错误，请重新输出！三秒后返回菜单！";sleep 3
									fi
								else
									echo "输入错误，请重新输出！三秒后返回菜单！";sleep 3
								fi
							else
								echo "输入错误，请重新输出！三秒后返回菜单！";sleep 3
							fi
							;;
						4)
							p=`ping -c1 ${update_server}`
							if [ "$?" == "0" ]
							then
								wget -q ftp://${update_server}/update_u/*
								chmod 777 UosTools*
								read -p "已下载UosTools工具至当前目录【${PWD}】，点击Enter返回！" enter
							else
								read -p "服务器未启用或当前网络环境非内网，请之后重新尝试，点击Enter返回！" enter
							fi
							;;
						3)	
							sudo echo "";sleep 0.5 
							echo "-------------------------------------------------"
							echo "操作系统版本 >>> `sudo cat /proc/version`"
							echo "-------------------------------------------------"
							echo "镜像版本 >>> `sudo cat /etc/product-info`"
							echo "-------------------------------------------------"
							echo "CPU架构 >>> `sudo uname -m`"
							echo "-------------------------------------------------"
							echo "CPU信息 >>> `sudo cat /proc/cpuinfo | grep name | cut -f2 -d: |uniq -c`"
							echo "-------------------------------------------------"
							echo "物理CPU数量 >>> `sudo grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l`"
							echo "-------------------------------------------------"
							echo "CPU核数 >>> `sudo cat /proc/cpuinfo |grep "cores"|uniq`"
							echo "-------------------------------------------------"
							echo "系统内存 >>> `sudo cat /proc/meminfo | grep MemTotal`"
							echo "-------------------------------------------------"
							echo "硬盘大小 >>> `sudo fdisk -l |grep Disk |head -1`"
							echo "-------------------------------------------------"
							echo "显卡信息 >>> `sudo lspci  | grep -i vga`"
							echo ""
							read -p "点击Enter返回！" enter
							;;					
						z)
							break
							;;
						*)
							echo -e "\e[1;41m无此序号，请重新输入！ \e[0m" && sleep 1
							;;
					esac
				done
				;;
			1)
				if [ `which vokoscreen` ]
				then
					sleep 0.1
				else
					echo "首次运行需要初始化,安装录制工具vokoscreen..."
					bash -c "sudo apt install -y vokoscreen"&>/dev/null
				fi
				if [ `which nomacs` ]
				then
					sleep 0.1
				else
					echo "首次运行需要初始化,安装看图工具nomacs..."
					bash -c "sudo apt install -y nomacs"&>/dev/null
				fi
				sleep 0.5
				nohup vokoscreen &
				sleep 0.5
				rm -rf nohup.out
				;;
			2)

	            echo "【1】指定处理 < 本目录：$PWD > 某视频文件"
	            echo "【2】批量处理 < 本目录：$PWD > 所有视频文件"
	            echo "【*】返回首页"
	            read -p "输入执行编号:" num
	            case $num in
			            1)
		                    echo ""
		                    echo " * 注意：视频名称中不能包含空格，否则可能导致分帧失败！"
		        		    read -p "输入视频文件名（xxx.后缀），若其他路径视频则需带路径:" video
		                    if [ "${video}" != '' ]
		                    then
		                    	read -p "直接Enter默认分帧【33张图/秒】，输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
			                    if [ "${fps_num}" != '' ]
			        		    then
				        		    while true
									do
										if [ -n "`echo ${fps_num} | sed 's/[0-9]//g'`" ]
										then
											read -p "分帧数值为0/null/非整数，请重新输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
										else
											if [ "${fps_num}" == "0" ]; then
												read -p "分帧数值为0/null/非整数，请重新输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
											elif [ "${fps_num}" == '' ]; then
												read -p "分帧数值为0/null/非整数，请重新输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
											else
												fps_num="${fps_num}"
												break
											fi
										fi
									done
			        		    else
			        		   		fps_num=33
			        		    fi
		                        result=`ls | grep ${video}`
		                        if [ ${result} ]
		                        then
		                        	  v_dir="${video%.*}_${fps_num}fps"
		                			  mkdir "${v_dir}"&>/dev/null
		                			  mv "${video}" ./"${v_dir}"
		                			  cd ./"${v_dir}"
		                              echo "——————————"
		                              echo "开始对${video}进行分帧..."
									  # 每一秒截33张图
		                			  bash -c "ffmpeg -i ${video} -f image2 -vf fps=fps=${fps_num}/1 -qscale:v 2 "${v_dir}"-%3d.jpeg"&>/dev/null
									  # fps=fps=1/33 ： 每33秒截1张图
		                           if [ "$?" == "0" ]
		                           then
		                              echo "< 分帧完成 >"
		                			  cd ..
		                           else
		                              echo "注意：视频文件【${video}】异常，可能已损坏 / 名称不规范，请重命名后再试，分帧失败！"
		                              touch 'bad_video'
		                              cd ..
		                           fi
		                           	  echo "——————————"
		                			  read -p "处理完毕,原视频与分帧后图片均已移动至【"${v_dir}"】文件夹,使用nomacs查看图片即可，点击Enter返回主菜单！" Enter

		                        else
		                           echo ""
		                           echo "<<< 未扫描到该视频，请重新输入！3秒后返回菜单！>>>";sleep 3
		                        fi
		                    else
		                       echo ""
		                       echo "<<< 输入错误，请重新操作！3秒后返回菜单！>>>";sleep 3
		                    fi
		       			 ;;
			            2)
							echo " * 注意：视频名称中不能包含空格，否则可能导致分帧失败！"
							read -p "直接Enter默认分帧【33张图/秒】，输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
		                    if [ "${fps_num}" != '' ]
		        		    then
			        		    while true
								do
									if [ -n "`echo ${fps_num} | sed 's/[0-9]//g'`" ]
									then
										read -p "分帧数值为0/null/非整数，请重新输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
									else
										if [ "${fps_num}" == "0" ]; then
											read -p "分帧数值为0/null/非整数，请重新输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
										elif [ "${fps_num}" == '' ]; then
											read -p "分帧数值为0/null/非整数，请重新输入数字‘x’并Enter >>> 表示分帧【x张图/每秒】：" fps_num
										else
											fps_num="${fps_num}"
											break
										fi
									fi
								done
		        		    else
		        		   		fps_num=33
		        		    fi
		                    echo ""
		                    echo "<<< 开始扫描视频文件…… >>>"
		                    echo ""
		                    rm -rf name.ini
		                    touch name.ini
		                    numzz=0
		                    while true
		                    do
		                        let numzz+=1
		                    	format1="`ls |grep '.mp4'|sed -n ${numzz}p`"
		                    	if [ "${format1}" != '' ]
		                    	then
		                    		echo "${format1}">>name.ini
		                    	fi
		                    	
		                    
		                    	format2=`ls |grep '.avi'|sed -n ${numzz}p`
		                    	if [ "${format2}" != '' ]
		                    	then
		                    		echo "${format2}">>name.ini
		                    	fi
		                    
		                    
		                    	format3=`ls |grep '.flv'|sed -n ${numzz}p`
		                    	if [ "${format3}" != '' ]
		                    	then
		                    		echo "${format3}">>name.ini
		                    	fi
		                    	
		                    	
		                    	format4=`ls |grep '.mkv'|sed -n ${numzz}p`
		                    	if [ "${format4}" != '' ]
		                    	then
		                    		echo "${format4}">>name.ini
		                    	fi
		                    
		                    
		                    	format5=`ls |grep -E ".mp4|.avi|.flv|.mkv"|sed -n ${numzz}p`
		                    	if [ "${format5}" != '' ]
		                    	then
		                    		sleep 0.5
		                    	else
		                    		echo "【mp4/avi/flv/mkv】格式视频已扫描完毕:"
		                    		break
		                    	fi
		                    
		                    done
		                    
		                    unframe_video1(){
		                    	
		                    	value="`cat name.ini | wc -l`"
		                    	if [ "${value}" == "0" ]
		                    	then
		                    		echo "未搜索到对应视频！"
		                    		rm -rf name.ini
		                    		echo ""
		                    		sleep 0.5
		                    	else
		                            #echo "${value}"
		                    		num=1
		                    		name="`cat name.ini |sed -n ${num}p`"
		                    		while [ "${name}" != '' ]
		                    		do
		                    			name="`cat name.ini |sed -n ${num}p`"
		                    			let num+=1
		                                if [ "${name}" != '' ];then
			                                v_dir="${name%.*}_${fps_num}fps"
			                    		    mkdir "${v_dir}"&>/dev/null
			                                mv "${name}" "${v_dir}"&>/dev/null
			                                if [ "$?" == "0" ]
			                                then      			
			                            			cd "${v_dir}"
			                            			echo "——————————"
			                            			echo "开始对${name}进行分帧..."
			                            			bash -c "ffmpeg -i ${name} -f image2 -vf fps=fps=${fps_num}/1 -qscale:v 2 "${v_dir}"-%3d.jpeg"&>/dev/null
			                                        if [ "$?" == "0" ]
			                                        then
			                                             echo "< 分帧完成 >"
			                            			     cd ..
			                                        else
			                                             echo "注意：视频文件【${name}】已损坏 / 名称不规范，请重命名后再试，分帧失败！"
			                                             touch 'bad_video'
			                                             cd ..
			                                        fi
			                                else
			                                    sleep 0.5
			                                fi
		                            	else
		                                    sleep 0.5
		                                fi
		                    		done
		                    		rm -rf name.ini
		                    		echo "——————————"
		                    		echo "所有视频处理完毕！原视频与分帧后图片均已移动至当前目录下对应文件夹！使用nomacs查看图片即可！"
		                    	fi
		                    
		                    
		                    }
		                    
		                    
		                    unframe_video1
		                    
		                    unframe_video2(){
		                    	
		                    	value="`cat name.ini | wc -l`"
		                    	if [ "${value}" == "0" ]
		                    	then
		                    		echo "未搜索到对应视频！"
		                    		rm -rf name.ini
		                    		echo ""
		                    		sleep 0.5
		                    	else
		                    		num=0
		                    		name="`cat name.ini |sed -n 1p`"
		                    		while [ "${name}" != '' ]
		                    		do
		                    			let num+=1
		                    			name="`cat name.ini |sed -n ${num}p`"
		                                if [ "${name}" != '' ];then
			                                v_dir="${name%.*}_${fps_num}fps"
			                    		    mkdir "${v_dir}"&>/dev/null
			                                mv "${name}" "${v_dir}"&>/dev/null
			                                if [ "$?" == "0" ]
			                                then      			
			                            			cd "${v_dir}"
			                            			echo "——————————"
			                            			echo "开始对${name}进行分帧..."
			                            			bash -c "ffmpeg -i ${name} -f image2 -vf fps=fps=${fps_num}/1 -qscale:v 2 "${v_dir}"-%3d.jpeg"&>/dev/null
			                                        if [ "$?" == "0" ]
			                                        then
			                                             echo "< 分帧完成 >"
			                            			     cd ..
			                                        else
			                                             echo "注意：视频文件【${name}】已损坏 / 名称不规范，请重命名后再试，分帧失败！"
			                                             touch 'bad_video'
			                                             cd ..
			                                        fi
			                                else
			                                    sleep 0.5
			                                fi
		                            	else
		                                    sleep 0.5
		                                fi
		                    		done
		                    		rm -rf name.ini
		                    		echo "——————————"
		                    		echo "所有视频处理完毕！原视频与分帧后图片均已移动至当前目录下对应文件夹！使用nomacs查看图片即可！"
		                    	fi
		                    
		                    
		                    }
		                    echo ""
		                    read -p "若需要对其他格式视频分帧(比如输入：MPEG-4)【若直接点击Enter，则直接返回菜单】:" last
		                    echo ""
		                    rm -rf name.ini
		                    touch name.ini
		                    if [ "${last}" != '' ]
		                    then
		                    	value1=`ls |grep ".${last}"|wc -l`
		                    	if [ "${value1}" == "0" ]
		                    	then
		                    		rm -rf name.ini
		                    		echo "未搜索到【${last}】格式视频，3秒后返回主菜单！";sleep 3
		                    	else
		                    		numz=0
		                    		while true
		                    		do
		                          #echo "+1以前${numz}"
		                    			let numz+=1
		                          #echo "+1以后${numz}"
		                    			formatlast=`ls |grep ".${last}"|sed -n ${numz}p`
		                    			if [ "${formatlast}" != '' ]
		                    			then
		                    				echo ${formatlast}>>name.ini
		                    			else
		                    				echo "【${last}】格式视频已扫描处理完毕:"
		                    				break
		                    			fi
		                    		done
		                            unframe_video2
		                            echo ""
		                            read -p "<<< 点击Enter，返回菜单！ >>>" end
		                    	fi
		                    else
		                    	rm -rf name.ini
		                        echo "<< bye >>";sleep 1
		                        echo "<< bye >>";sleep 1
		                    
		                    fi          				
						;;

					*)
		                echo "<< bye >>";sleep 1
		                echo "<< bye >>";sleep 1
						;;
	            esac
				;;
			3)
				read -p "输入耗时图片数量（数值=尾帧图片编号-首帧图片编号）:" num1
				if [ ${num1} ]
				then
					num2=30.3
					num3=$(echo "scale=4; $num1 * $num2" | bc)
					echo "响应耗时为： << $num3 (毫秒ms) >>" 
					echo ""
					read -p "点击Enter返回主菜单！" Enter
				else
					echo "输入参数错误！3秒返回主菜单！";sleep 3
				fi
				;;
			6)
		        if [ `which valgrind` ]
	    	    then
			         sleep 0.5
		        else
		        	sudo true
			        echo "首次运行需要初始化,正在安装valgrind，请稍等..."
			        if sudo apt install -y valgrind &>/dev/null; then
						echo ""
						echo "该工具针对应用检查内存情况，如：内存泄露、内存读写越界、内存覆盖..."
						echo "打开应用之后简单操作主要路径即可(操作有延迟为正常现象)，日志生成在Uos系统桌面【memcheak.log】"
						echo ""
						read -p "输入要检测的应用（比如音乐：deepin-music）：" appname
						t=$(date +"%H%M%S")
						logname="${appname}_memcheak_${t}"
						valgrind --tool=memcheck --leak-check=full  --show-reachable=yes  --trace-children=yes --log-file="${logname}.log"   /usr/bin/${appname}
					else
						echo -e "\n初始化失败,valgrind未被成功安装，可能是源/网络/依赖安装失败等问题，3秒/Enter后退出！"
						read -t 3
					fi
		        fi
				;;	
			7)
	            echo "注意：日志文件需和工具放在相同目录下"
	            read -p "输入需要分析的memcheak.log日志：全名/文件名中时间戳（数字）：" log
	            logname="`ls|grep ${log}`"
	            echo "-------------"
	            if [ ${logname} ]
	            then
	                echo "开始分析日志文件：${logname}"
	                echo ""
	                if [ "`cat ${logname}|grep LEAK\ SUMMARY`" ]
	                then
	                    echo "内存泄露：存在"
	                    echo "`cat ${logname}|grep -A 5 LEAK\ SUMMARY`"
	                    echo "-------------"
	                else
	                    echo "内存泄露：不存在"
	                    echo "-------------"
	                fi
	                if [ "`cat ${logname}|grep Conditional\ jump\ or\ move\ depends\ on\ uninitialisedvalue`" ]
	                then
	                    echo "使用了未初始化的变量：存在"
	                    echo "`cat ${logname}|grep -A 5 Conditional\ jump\ or\ move\ depends\ on\ uninitialisedvalue`"
	                    echo "-------------"
	                else
	                    echo "使用了未初始化的变量：不存在"
	                    echo "-------------"
	                fi
	                if [ "`cat ${logname}|grep Invalid\ read/write`" ]
	                then
	                    echo "内存读写越界：存在"
	                    echo "`cat ${logname}|grep -E -A 5 "Invalid\ read|Invalid\ write"`"
	                    echo "-------------"
	                else
	                    echo "内存读写越界：不存在"
	                    echo "-------------"
	                fi
	                if [ "`cat ${logname}|grep Source\ and\ destination\ overlap`" ]
	                then
	                    echo "内存覆盖：存在"
	                    echo "`cat ${logname}|grep -A 5 Source\ and\ destination\ overlap`"
	                    echo "-------------"
	                else
	                    echo "内存覆盖：不存在"
	                    echo "-------------"
	                fi
	                echo ""
	                read -p "点击Enter返回菜单" Enter
	            else
	                echo "未找到该日志文件，请重新输入，3秒后返回菜单";sleep 3
	            fi
	            ;;
			4)
				echo "注意："
				echo "单进程应用-正常情况：查询结果应只有1个进程，比如音乐、影院等。"
				echo "单进程应用-异常情况：若有多个进程则说明环境不干净，如：打开了包含【关键字】的测试结果的文档、文件夹等，测试时请仅运行工具与被测应用"
				echo "多进程应用-相同关键字：查询结果为2个进程，比如smplayer在播放视频时会产生子进程，COMMAND中均包含‘smplayer’，那么输入关键字‘smplayer’则可同时监控两个进程"
				echo ""
				read -p ">>输入需要查询的应用>>关键字段：" name
				y1=`ps aux --sort=pid| grep ${name} | grep -v grep`
				echo "USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND"
				echo "$y1"
				echo ""
				read -p "若无信息，请启动程序再重新操作，点击回车返回主菜单！" enter
				;;
			5)
				echo "【1】同时监控CPU+MEM"
				echo "【2】仅监控CPU"
				echo "【3】仅监控MEM"
				read -p "输出编号：" menu_num
				if test ! -d PerfData
				then
					mkdir PerfData
				fi
				echo "注意："
				echo "测试准备：开始测试前，应该在工具首页执行【编号8】，输入'关键字'查询被测应用环境是否干净、多进程监控的关键字选择"
				echo "异常情况：对deepin-music进行测试时，打开了包含【deepin-music】字段的测试结果的文档、文件夹等，会导致数据错误"
				echo "处理方式：进行测试时仅打开被测应用与工具即可，除此之外若还有其他干扰进程，可过滤其关键字（会提示输入）"
				echo "Ps.目前测试场景未超过2个进程，所以仅支持2个进程测试"
				echo ""
				case $menu_num in
					1)
						read -p ">>输入需要监控的应用进程>>关键字：" name1
						#read -p ">>输入需要监控的应用进程>>关键字2（若无则直接回车）：" name3
						read -p ">>输入需要过滤掉的进程>>关键字段（若无则直接回车）：" name2
						read -p ">>监控时长（分钟）,不输入默认为5分钟结束监控：" end_time
						t=$(date +"%m%d%H%M%S")
						if [ ${name1} ]
						then
							if [ ${name2} ]
							then
								name2=${name2}
							else
								name2="grep"
							fi
							if [ ${end_time} ]
							then
								while true
								do
									if [ -n "`echo ${end_time} | sed 's/[0-9]//g'`" ]
									then
										echo "监控时长非整数，请重新输入！"
										read -p ">>监控时长（分钟）：" end_time
									else
										break
									fi
								done
								end_time=`echo "${end_time}*60"|bc`
							else
								end_time=300
							fi
							time=0
							mkdir -p ./PerfData/cpu_mem_${name1}_${t}
							t2=$(date +"%y-%m-%d %H:%M:%S")
							echo "${t2}开始监控${name1}，监控时长${end_time}秒，每隔5秒收集一次%cpu" >> ./PerfData/cpu_mem_${name1}_${t}/cpu_${name1}_${t}.xls
							echo "${t2}开始监控${name1}，监控时长${end_time}秒，每隔5秒收集一次物理占用内存" >> ./PerfData/cpu_mem_${name1}_${t}/mem_${name1}_${t}.xls
							echo ""
							echo ">>开始监控时间:${t2}，每隔5秒收集一次%cpu+物理占用内存，监控时长${end_time}秒,需提前停止收集时点击 ctrl+c !"
							echo ">>打印结果在工具同级目录【/PerfData/cpu_mem_${name1}_${t}】"
							echo "————————————————————"
							while true
							do
								trap "CtrlC" INT
								com1=`ps aux --sort=pid| grep ${name1} | grep -v grep | grep -v ${name2} |awk {'print $2'} | sed -n 1p`
								com2=`ps aux --sort=pid| grep ${name1} | grep -v grep | grep -v ${name2} |awk {'print $2'} | sed -n 2p`
								pid1="-p ${com1}"
								pid2="-p ${com2}"
								if [ ${com1} ]
								then
									if [ ${com2} ]
									then
										all=`top -b -n 2 ${pid1} ${pid2}|tail -2|awk {'print $6,$9'}`
										read mem1 cpu1 mem2 cpu2 <<< `echo $all|awk {'print $1,$2,$3,$4'}`
										if [ ${mem1} ]
										then
											if [ "${mem1}" == "RES" ]
											then
												if [ ${mem2} ]
												then
													sum_mem=`echo "scale=2;$mem2/1024"|bc`
													sum_cpu=$cpu2
													echo "${name1}进程数量为[1]>>>进程[${com1}]>>>占用CPU：${sum_cpu}%"
													echo "${name1}进程数量为[1]>>>进程[${com1}]>>>占用物理内存：${sum_mem}Mb"
													echo "————————————————————"
													sleep 2
												else
													echo "${name1}进程未启动"
													echo "————————————————————"
													sum_cpu=0.0
													sum_mem=0.00
													sleep 5
												fi
											else
												sum_mem=`echo "scale=2;($mem1+$mem2)/1024"|bc`
												sum_cpu=`echo "scale=2;sum=$cpu1+$cpu2+0.0;if (length(sum)==scale(sum)) print 0;print sum"|bc`
												echo "${name1}进程数量为[2]>>>进程[${com1}]+进程[${com2}]>>>占用CPU：${sum_cpu}%"
												echo "${name1}进程数量为[2]>>>进程[${com1}]+进程[${com2}]>>>占用物理内存：${sum_mem}Mb"
												echo "————————————————————"
												sleep 2
											fi
										else
											echo "${name1}进程未启动"
											echo "————————————————————"
											sum_cpu=0.0
											sum_mem=0.00
											sleep 5
										fi
									else
										read sum_mem sum_cpu <<< `top -b -n 2 ${pid1}|tail -1|awk {'print $6,$9'}`
										if [ "${sum_cpu}" == "%CPU" ]
										then
											echo "${name1}进程未启动"
											echo "————————————————————"
											sum_cpu=0.0
											sum_mem=0.00
											sleep 5
										else
											sum_mem=`echo "scale=2;$sum_mem/1024"|bc`
											echo "${name1}进程数量为[1]>>>进程[${com1}]>>>占用CPU：${sum_cpu}%"
											echo "${name1}进程数量为[1]>>>进程[${com1}]>>>占用物理内存：${sum_mem}Mb"
											echo "————————————————————"
											sleep 2
										fi
									fi
								else
									echo "${name1}进程未启动"
									echo "————————————————————"
									sum_cpu=0.0
									sum_mem=0.00
									sleep 5
								fi	
								echo "${sum_cpu}%">> ./PerfData/cpu_mem_${name1}_${t}/cpu_${name1}_${t}.xls
								echo "${sum_mem}">> ./PerfData/cpu_mem_${name1}_${t}/mem_${name1}_${t}.xls
								let time+=5
								if [ ${end_time} -eq ${time} ]; then
									break
								fi
							done
							read -p "测试结束，监控时长【${end_time}秒】，文件已保存至目录：【PerfData/cpu_mem_${name1}_${t}】，点击Enter返回！" Enter
						else
							echo ""	
							echo "未输入关键字,3秒返回主菜单" && sleep 3	
						fi
						;;
					2)
						echo "<< 该功能为老功能暂未移除，可使用【编号1】新功能进行监控 >>"
						read -p ">>输入需要监控的应用进程>>关键字：" name1
						read -p ">>输入需要过滤掉的进程>>关键字段（若无则直接回车）：" name2
						read -p ">>监控时长（分钟）,不输入默认为5分钟：" end_time
						t=$(date +"%m%d%H%M%S")
						if [ ${name1} ]
						then
							if [ ${name2} ]
							then
								name2=${name2}
							else
								name2="grep"
							fi
							if [ ${end_time} ]
							then
								while true
								do
									if [ -n "`echo ${end_time} | sed 's/[0-9]//g'`" ]
									then
										echo "监控时长非整数，请重新输入！"
										read -p ">>监控时长（分钟）：" end_time
									else
										break
									fi
								done
								end_time=`echo "${end_time}*60"|bc`
							else
								end_time=300
							fi
							time=0
							mkdir -p ./PerfData/cpu_${name1}_${t}
							echo "$(date +"%y-%m-%d %H:%M:%S")开始监控${name1}，监控时长${end_time}秒，每隔5秒收集一次%cpu" >> ./PerfData/cpu_${name1}_${t}/cpu_${name1}_${t}.xls
							echo ""
							echo ">>开始监控时间:$(date +"%y-%m-%d %H:%M:%S"),监控时长${end_time}秒，每隔5秒收集一次%cpu,需要停止收集时点击 ctrl+c !"
							echo ">>打印结果在工具同级目录【/PerfData/cpu_${name1}_${t}】"
							echo "————————————————————"
							while true
							do
								trap "CtrlC" INT
								com1=`ps aux --sort=pid| grep ${name1} | grep -v grep | grep -v ${name2} |awk {'print $2'} | sed -n 1p`
								com2=`ps aux --sort=pid| grep ${name1} | grep -v grep | grep -v ${name2} |awk {'print $2'} | sed -n 2p`
								pid1="-p ${com1}"
								pid2="-p ${com2}"
								if [ ${com1} ]
								then
									if [ ${com2} ]
									then
										cpu=`top -b -n 2 ${pid1} ${pid2}|tail -2|awk {'print $9'}| awk '{sum+=$1}END{print sum}'`
										echo "${name1}进程数量为[2]>>>进程[${com1}]+进程[${com2}]>>>占用CPU：${cpu}%"
										echo "————————————————————"
									else
										cpu=`top -b -n 2 ${pid1}|tail -2|awk {'print $9'}| awk '{sum+=$1}END{print sum}'`
										echo "${name1}进程数量为[1]>>>进程[${com1}]>>>占用CPU：${cpu}%"
										echo "————————————————————"
									fi
									sleep 2
								else
									echo "${name1}进程未启动"
									echo "————————————————————"
									cpu=0.0
									sleep 5
								fi	
								echo "${cpu}%">> ./PerfData/cpu_${name1}_${t}/cpu_${name1}_${t}.xls
								let time+=5
								if [ ${end_time} -eq ${time} ]; then
									break
								fi
							done
							read -p "测试结束，监控时长【${end_time}秒】，文件已保存至目录：【PerfData】，点击Enter返回！" Enter
						else
							echo ""	
							echo "未输入关键字,3秒返回主菜单" && sleep 3	
						fi
						;;

					3)
						echo "<< 该功能为老功能暂未移除，可使用【编号1】新功能进行监控 >>"
						read -p ">>输入需要监控的应用进程>>COMMAND关键字段：" name1
						read -p ">>输入需要过滤掉的进程>>COMMAND关键字段（若无则直接回车）：" name2
						read -p ">>监控时长（分钟）,不输入默认为5分钟：" end_time
						t=$(date +"%m%d%H%M%S")
						if [ ${name1} ]
						then
							if [ ${end_time} ]
							then
								while true
								do
									if [ -n "`echo ${end_time} | sed 's/[0-9]//g'`" ]
									then
										echo "监控时长非整数，请重新输入！"
										read -p ">>监控时长（分钟）：" end_time
									else
										break
									fi
								done
								end_time=`echo "${end_time}*60"|bc`
							else
								end_time=300
							fi
							time=0
							if [ ${name2} ]
							then
								name2=${name2}
							else
								name2="grep"
							fi
							mkdir  -p ./PerfData/mem_${name1}_${t}
							echo "$(date +"%y-%m-%d %H:%M:%S")开始监控${name1}，监控时长${end_time}秒，每隔5秒收集一次物理占用内存(Mb)" >> ./PerfData/mem_${name1}_${t}/mem_${name1}_${t}.xls
							echo ""
							echo ">>开始监控时间:$(date +"%y-%m-%d %H:%M:%S") , 监控时长${end_time}秒，每隔5秒收集一次物理占用内存(Mb),需要停止收集时点击 ctrl+c !"
							echo ">>打印结果在工具同级目录【PerfData/mem_${name1}_${t}】"
							echo "————————————————————"
							while true
							do
								trap "CtrlC" INT
								com1=`ps aux --sort=pid| grep ${name1} | grep -v grep | grep -v ${name2} |awk {'print $2'} | sed -n 1p`
								com2=`ps aux --sort=pid| grep ${name1} | grep -v grep | grep -v ${name2} |awk {'print $2'} | sed -n 2p`		
								if [ ${com1} ]
								then
									if [ ${com2} ]
									then
										mem1=`cat  /proc/${com1}/status|grep VmRSS|awk {'print $2'}`
										mem2=`cat  /proc/${com2}/status|grep VmRSS|awk {'print $2'}`
										sum_mem=`echo "scale=2;($mem1+$mem2)/1024"|bc`
										echo "${name1}进程数量为[2]>>>进程[${com1}]+进程[${com2}]>>>占用物理内存：${sum_mem}Mb"
										echo "————————————————————"
									else
										mem1=`cat  /proc/${com1}/status|grep VmRSS|awk {'print $2'}`
										sum_mem=`echo "scale=2;$mem1/1024"|bc`
										echo "${name1}进程数量为[1]>>>进程[${com1}]>>>占用物理内存：${sum_mem}Mb"
										echo "————————————————————"
									fi
								else
									echo "${name1}进程未启动"
									echo "————————————————————"
									sum_mem=0
								fi	
								#mem=$[$mem1+$mem2]
								echo "${sum_mem}"|bc >> ./PerfData/mem_${name1}_${t}/mem_${name1}_${t}.xls
								let time+=5
								sleep 5
								if [ ${end_time} -eq ${time} ]; then
									break
								fi
							done
							read -p "测试结束，监控时长【${end_time}秒】，文件已保存至目录：【PerfData】，点击Enter返回！" Enter
						else
							echo ""	
							echo "未输入关键字,3秒返回主菜单" && sleep 3
						fi	
						;;
					*)
						echo "无效输出，2秒后返回！";sleep 2
						;;
				esac
				;;
			zz)
				echo "仓库配置地址如下："
			    echo "#default"
			    echo "deb [by-hash=force] https://professional-packages.chinauos.com/desktop-professional eagle main contrib non-free"
				echo "#sp2"
				echo "deb [trusted=yes] http://10.0.32.52:5002/public-repos/eagle-sp2/release-candidate/Q0Qt5aSa5aqS5L2T5LiO5paH566hNTU1/ unstable main"
				echo "#sp1"
				echo "deb [trusted=yes] http://10.0.32.52:5002/public-repos/eagle/release-candidate/5oiQ6YO95aSa5aqS5L2T5LiO5paH566hLeWvueWGhTM3NA/ unstable main"
				echo "#dev"
				echo "deb http://pools.uniontech.com/ppa/dde-eagle eagle main contrib non-free"
				echo "deb http://pools.uniontech.com/uos eagle main contrib non-free"
				echo "#"
				echo "deb http://pools.uniontech.com/uos eagle main contrib non-free"
				echo ""
	            echo "若当前目录下有sources.list文件，则将内容则直接更新至/etc/apt/sources.list"
	            echo "若当前目录下无sources.list文件，则打开/etc/apt/sources.list（可复制粘贴上方内容，请检查是否为最新源）"
	            read -p "------点击Enter继续！------" Enter
                sudo vim /etc/apt/sources.list && \
                sudo rm -rf /var/lib/apt/lists/lock || \
                echo "执行失败，请检查是否进入开发者模式" && echo "3秒返回主菜单";sleep 3

				;;	
			q)
				#upup
				update_status="no"
				#myip="`ifconfig |head -2|grep inet|awk '{print $2}'`"
				myip="`hostname -I`"
				[[ "${myip}" =~ "${Internal_network}" ]] && upz=0 || upz=1
				if [ "${upz}" == "0" ];then
					echo -e "\033[46;30;8m ******************************************************************* \033[0m"
					echo "【1】内网更新"
					echo "【2】联网更新"
					echo "【*】放弃更新"
					echo "【x】保留新版并下载稳定历史版本（新版有Bug? 或者不舒服? 请在'C.用户意见墙'反馈, 谢谢!）"
					echo ""
					read -p " * 请输出菜单编号：" action
				else
					echo -e "\033[46;30;8m ******************************************************************* \033[0m"
					echo "【1】内网更新  # 当前网段,不支持该功能! # "
					echo "【2】联网更新"
					echo "【*】放弃更新"
					echo "【x】下载稳定历史版本 # 当前网段,不支持该功能! # "	
					echo ""
					read -p " * 请输出菜单编号：" action
					while [[ true ]]; do
						if [ "${action}" == "1" -o "${action}" == "x" -o "${action}" == "" ];then
							read -p "* 不支持该功能,请重新输入编号:" action
						else
							break
						fi
					done
					
				fi
				case ${action} in
					1)	
				      if [ `which nmap` ]
				     	  then
				          sleep 0.5
					  else
				          echo "功能准备初始化,请稍等..."
				          bash -c "sudo apt install -y nmap"&>/dev/null
					  fi
				      echo ""
				      echo "正在连接服务器，请稍等..."
				      p=`ping -c1 ${update_server}`
				      if [ "$?" == "0" ]
				      then
				        rm -rf ${PWD}/.update_test_p/
				        mkdir -p ${PWD}/.update_test_p
				        echo "<< 连接成功 >>"
				        echo ""
				        echo "正在验证工具版本号，请稍等..."
				        wget -q ftp://${update_server}/update_p/* -P ${PWD}/.update_test_p/
				        new=`ls ${PWD}/.update_test_p`
				        if [ "${0##*/}" == "${new}" ]
				        then
				          rm -rf ${PWD}/.update_test_p
				          echo "<< 已经是最新版 >>，无需更新，3秒后返回菜单！";sleep 3
				        else
				          bash -c "mv ${PWD}/.update_test_p/${new} ${PWD}"&>/dev/null
				          if [ "$?" == "0" ]
				          then
				            rm -rf ${0##*/}
				            rm -rf ${PWD}/.update_test_p
				            chmod 777 ${new}
				            echo "更新完成：${0##*/} >>> ${new}，更新内容可在【h、帮助】中查看！"
				            read -p "请在当前目录重启新版工具！点击Enter关闭工具！" end
				            exit
				          else
				            echo "<< 权限错误 >>，请尝试重新在root下重新运行脚本！3秒后返回菜单！";sleep 3
				          fi
				        fi
				      else
				            echo ""
				            echo "服务器IP发生变化，或服务器未启动，直接点击Enter返回菜单(可人工呼叫作者：黄海针)！"
				            read -p "输入【Y】全网扫描服务器更新工具（需要一杯咖啡的时间！）:" update_end
				            rm -rf ${PWD}/ips.log
				            if [ ${update_end} ]
				            then
				              echo ""
				              echo "开始扫描局域网，自动识别服务器："
				              myip=`ifconfig |head -2|grep inet|awk '{print $2}'`
				              nmap -sP ${myip%.*}.0/24|grep 'Nmap scan report for'|awk '{print $5}' > ${PWD}/ips.log
				              rm -rf ${PWD}/.update_test_p
				              mkdir ${PWD}/.update_test_p
				              ipnum=0
				              while true
				              do
				                let ipnum+=1
				                ftpip="`cat ${PWD}/ips.log|sed -n ${ipnum}p`"
				                wget -q ftp://${ftpip}/update_p/* -P ${PWD}/.update_test_p
				                if [ "$?" == "0" ]
				                then
				                  echo "————————————"
				                  echo "校验：${ftpip}"
				                  echo "校验通过，服务器匹配成功，正在验证工具版本号，请稍等..."
				                      new="`ls ${PWD}/.update_test_p`"
				                      if [ "${0##*/}" == "${new}" ]
				                      then
				                          rm -rf ${PWD}/.update_test_p
				                          rm -rf ${PWD}/ips.log
				                          echo ""
				                          read -p "<< 已经是最新版 >>，无需更新，点击Enter返回菜单！" Enter
				                          break
				                      else
				                          bash -c "mv ${PWD}/.update_test_p/${new} ${PWD}"&>/dev/null
				                          if [ "$?" == "0" ]
				                          then
				                              rm -rf ${0##*/}
				                              rm -rf ${PWD}/.update_test_p
				                              rm -rf ${PWD}/ips.log
				                              chmod 777 ${new}
				                              echo ""
				                              read -p "更新完成：${0##*/} >>> ${new}，请在当前目录重启新版工具！点击Enter关闭工具！" Enter
				                              exit
				                        else
				                        	  echo ""
				                              rm -rf ${PWD}/.update_test_p
				                              rm -rf ${PWD}/ips.log
				                              echo "<< 未知错误 >>，请重新更新！3秒后返回菜单！";sleep 3
				                          fi
				                      fi
				                else
				                  echo "————————————"
				                  echo "校验：${ftpip}"
				                  echo "校验失败，服务器匹配错误，即将进行下一次匹配..."
				                fi
				              done
				            else
				              echo ""
				              echo "<< bye >>";sleep 1
				              echo "<< bye >>";sleep 1
				            fi
				      fi
						;;
					2)
						  sudo echo -e "\n功能准备初始化..."
						  sudo apt update &>/dev/null
					      if sudo apt install -y git &>/dev/null;then
						      echo ""
						      echo "正在连接服务器，请稍等..."
						      rm -rf ${PWD}/update_p/
						      git clone https://e.coding.net/mars-z/update_p/update_p.git &>/dev/null
						      if [ "$?" == "0" ]
						      then
							      echo "<< 连接成功 >>"
							      echo ""
							      echo "正在验证工具版本号，请稍等..."
							      new=`ls ${PWD}/update_p`
							      if [ "${0##*/}" == "${new}" ]
							      then
							          rm -rf ${PWD}/update_p
							          echo "<< 已经是最新版 >>，无需更新，3秒后返回菜单！";sleep 3
						          else
							          bash -c "mv ${PWD}/update_p/${new} ${PWD}"&>/dev/null
							          if [ "$?" == "0" ]
							          then
								            rm -rf ${0##*/}
								            rm -rf ${PWD}/update_p
								            chmod 777 ${new}
								            echo "更新完成：${0##*/} >>> ${new}，更新内容可在【h、帮助】中查看！"
								            read -p "请在当前目录重启新版工具！点击Enter关闭工具！" end
								            exit
							          else
							            	echo "<< 权限错误 >>，请尝试重新在root下重新运行脚本！3秒后返回菜单！"
							            	read -t 3
							          fi
						          fi
						       else
						       		echo "<< 服务器错误 >>，请尝试在其他时间段重新更新！3秒后返回菜单！"
						       		read -t 3
						       fi
						  else
						  		echo
					       		echo "环境初始化失败，请检查是否已进入开发者模式或存在网络问题！3秒后返回菜单！"
					       		read -t 3
					      fi

						;;
					x)
						echo ""
						echo "发现Bug请大家在首页运行【c、用户意见墙】,反馈给作者，3Q~"
						if test -d ${PWD}/old_tools
						then
							rm -rf ${PWD}/old_tools/Perf*
						else
							mkdir ${PWD}/old_tools
						fi
						wget -q ftp://${update_server}/update_p_old/* -P ${PWD}/old_tools
						echo ""
						read -p "已下载历史稳定版至目录【${PWD}/old_tools】，点击Enter返回！"
						;;
					*)
						echo "bye"
						echo "bye"
						sleep 1
						;;
				esac
				;;
			8)
				sudo true
				echo -e "\n# 环境检测中, 请稍等..."
				if ! command -v stress; then
					sudo apt install -y stress &>/dev/null
				fi
				if command -v stress; then
					echo "说明：该功能可针对CPU/MEM资源进行占用,可用于："
					echo "1）系统压力测试  2）模拟应用运行在资源不足环境下进行测试"
					echo ""
					echo "[1] 新手引导模式"
					echo "[2] 高手自定义模式"
					read -p "输入编号：" s_num
					echo ""
					case ${s_num} in
						1)
							echo "* 注意：负载时间为必填项，CPU/内存可同时负载 或 仅负载一项："
							read -p "输入负载时间（秒）：" s_time
							read -p "输入启动CPU负载进程数量（int：数量越大占用越高）：" s_cpu
							read -p "输入启动内存负载大小（GB）:" s_mem
							if [[ -n "`echo ${s_time} | sed 's/[0-9]//g'`" ]] || [[ "${s_time}" == "" ]] || [[ "${s_time}" == "0" ]];then
								time_type="error"
								echo "${time_type}"
							else
								end_time="-t ${s_time}s"
							fi
							if [[ -n "`echo ${s_cpu} | sed 's/[0-9]//g'`" ]];then
								cpu_type="error"
								echo "${cpu_type}"
							else
								if [[ "${s_cpu}" == "" ]] || [[ "${s_cpu}" == "0" ]]; then
									end_cpu=""
								else
									end_cpu="-c ${s_cpu}"
								fi
							fi
							if [[ -n "`echo ${s_mem} | sed 's/[0-9]//g'`" ]];then
						    	mem_type="error"
						    	echo "${mem_type}"
						    else
						    	if [[ "${s_mem}" == "" ]] || [[ "${s_mem}" == "0" ]]; then
						    		end_mem=""
						    	else
						    		end_mem="--vm 1 --vm-bytes ${s_mem}G"
						    	fi
						    fi
						    if [[ "${time_type}" == "error" ]] || [[ "${cpu_type}" == "error" ]] || [[ "${mem_type}" == "error" ]];then
						    	echo ""
						    	echo "* 缺失必填项或未输入正整数，请重新输入！2秒后返回菜单！";sleep 2
						    	else
						    		if [[ "${end_cpu}" == "" ]] && [[ "${end_mem}" == "" ]];then
								    	echo ""
								    	echo "* 输入错误，CPU与内存必须负载一项！2秒后返回菜单！";sleep 2
						    		else
						    			stress ${end_cpu} ${end_mem} ${end_time}
						    		fi 
						    fi
						    echo ""
						    read -p "* 点击Enter返回主菜单！"
							;;
						2)
							echo "格式：stress -参数 ，参数具体作用如下："
							echo ""
							echo "-n 显示已完成的指令情况"
							echo "-t --timeout N 指定运行N秒后停止"
							echo "--backoff N 等待N微妙后开始运行"
							echo "-c 产生n个进程 每个进程都反复不停的计算随机数的平方根"
							echo "-i 产生n个进程 每个进程反复调用sync()，sync()用于将内存上的内容写到硬盘上"
							echo "-m --vm n 产生n个进程,每个进程不断调用内存分配malloc和内存释放free函数"
							echo "--vm-bytes B 指定malloc时内存的字节数 （默认256MB）"
							echo "--vm-hang N 指定在free钱的秒数"
							echo "-d --hadd n 产生n个执行write和unlink函数的进程"
							echo "-hadd-bytes B 指定写的字节数"
							echo "--hadd-noclean 不unlinkecho "
							echo "时间单位可以为秒s，分m，小时h，天d，年y，文件大小单位可以为K，M，G"
							echo ""
							read -p "请输入需要执行的命令：" stress_com
							echo ""
							bash -c "${stress_com}"
						    echo ""
						    read -p "* 点击Enter返回主菜单！"
							;;
						*)
							echo "无效输出，2秒后返回！";sleep 2
							;;
					esac
				else
					echo
					read -r -t 5 -p "# 环境初始化失败，无法安装软件包或仓库无工具:stress！请手动处理，Enter/5秒后返回菜单！" 
				fi
				;;
			9)
				echo ""
				echo -e "使用说明：\n1.启用需要查询的应用，窗口置于可见处\n2.点击Enter启用工具\n3.鼠标变为十字后左键点击需要查询窗口即可"
				echo ""
				read -r -p "* 点击Eenter启用"
				if ！ command -v xprop &>/dev/null; then
					sudo apt install -y xprop &>/dev/null
				fi
				xprop|grep WM_CLASS
				echo ""
				read -r -p "以上为查询应用包名，点击Eenter返回主菜单！"
				;;
			h)	
			clear
			help_1="响应耗时计算公式(毫秒ms)"
			help_1_1="（尾帧图片编号-首帧图片编号）*30.3(每张图片耗时)"
			help_1_2="图片查看工具"
			help_1_2_1_2="启动器选择nomacs"			
			help_2="seafile一代"
			help_2_2="https://docs.deepin.com/"
			help_3="seafile二代"
			help_3_3="https://filewh.uniontech.com/accounts/login/"
			help_4="pms"
			help_4_4="https://pms.uniontech.com/"
			help_5="内网总纲"
			help_5_5="https://i.uniontech.com/"
			help_6="应用包下载（外网）"
			help_6_6="https://shuttle.wh-redirect.deepin.cn/tasks?pkgname=应用名称"
			help_7="仓库源最新地址（所有人可编辑维护）"
			help_7_7="https://docs.qq.com/doc/DUUppQ1VOSlZCUWJu"
			help_8="企业邮箱"
			help_8_8="https://mail.uniontech.com/"
			help_9="wiki"
			help_9_9="https://wikidev.uniontech.com/index.php"
			help_10="内网激活服务器地址"
			help_10_10="kms.uniontech.com:8900:Vlc1cGIyNTBaV05v"
			help_11="代理服务器地址"
			help_11_11="https://it.uniontech.com/proxy/proxy.pac"
			help_12="发布版镜像下载"
			help_12_12="https://cdimage.uniontech.com/"
			help_13="日构建镜像下载"
			help_13_13="http://10.20.12.228"
			help_14="shuttle"
			help_14_14="http://shuttle.union"

			if command -v zenity &>/dev/null; then
				zenity --list \
			  --title="常用信息（双击路径进入编辑态可复制）" \
			  --column="选项" --column="详情" --editable --width='850' --height='510' \
"${help_1}"	"${help_1_1}" \
"${help_2}" "${help_2_2}" \
"${help_3}"	"${help_3_3}" \
"${help_4}"	"${help_4_4}" \
"${help_5}" "${help_5_5}" \
"${help_6}" "${help_6_6}" \
"${help_7}" "${help_7_7}" \
"${help_8}" "${help_8_8}" \
"${help_9}" "${help_9_9}" \
"${help_10}" "${help_10_10}" \
"${help_11}" "${help_11_11}" \
"${help_12}" "${help_12_12}" \
"${help_13}" "${help_13_13}" \
"${help_14}" "${help_14_14}" &> /dev/null
			else
				echo ""
				echo "${help_1}"
				echo "${help_1_1}"
				echo "${help_1_2}"
				echo "${help_1_2_1_2}"
				echo ""
				echo "【常用网站】"
				echo "${help_2}: ${help_2_2}"
				echo "${help_3}: ${help_3_3}"
				echo "${help_4}: ${help_4_4}"
				echo "${help_5}: ${help_5_5}"
				echo "${help_6}: ${help_6_6}"
				echo "${help_7}: ${help_7_7}"
				echo "${help_8}: ${help_8_8}"
				echo "${help_9}: ${help_9_9}"
				echo "${help_10}: ${help_10_10}"
				echo "${help_11}: ${help_11_11}"
				echo "${help_12}: ${help_12_12}"
				echo "${help_13}: ${help_13_13}"
				echo "${help_14}: ${help_14_14}"
				echo ""
				read -p "请复制需要内容，点击{Enter键}返回主菜单！"
			fi
				;;
			c)
			trap "DemandC" INT
			if test -d demand
			then
				rm -rf demand
			fi
			if [ `which git` ]
			then
				sleep 0.5
			else
				echo "功能准备初始化..."
				sh -c "sudo apt install -y git"&>/dev/null
			fi
			t=$(date +"%m%d%H%M%S")
			git clone https://18181416168:hhz881116@e.coding.net/mars-z/demand/demand.git&>/dev/null
			clear
			bash ./demand/demand.sh
			echo ""
			echo -e "\033[46;30;8m ******************************************************************* \033[0m"
			echo "【1】提个需求、建议、BUG"
			echo "【*】返回首页"
			read -p " * 请输出菜单编号：" action
			case ${action} in
				1)	
					echo ""
					echo "# 不限于需求、建议、BUG等 "
					read -p "输入你的代号：" username
					read -p "输入你的意见内容：" demand
					while true; do
						if [ ${username} ]; then
							sleep 0.5
						else
							read -p "代号为空，请重新输入你的代号：" username
						fi
						if [ ${demand} ]; then
							sleep 0.5
						else
							read -p "意见为空，请重新输入你的意见内容：" demand
						fi
						if [ ${demand} -a ${username} ]; then
							break
						fi
					done
					echo "echo \"用户： ${username}\"" >> ./demand/demand.sh
					echo "echo \"工具： ${0##*/}\"" >> ./demand/demand.sh
					echo "echo \"日期： $(date +"%m%d")\"" >> ./demand/demand.sh
					echo "echo \"内容： ${demand}\"" >> ./demand/demand.sh
					echo "echo \"作者回复： 待回复\"" >> ./demand/demand.sh
					echo "echo \"\"" >> ./demand/demand.sh
					printf "\n 开始提交..."
					git config --global user.name "user"
					git config --global user.email "user@uniontech.com"
					cd demand
					git add .
					git commit -m "${t}"&>/dev/null
					git push origin master&>/dev/null
					clear
					# /usr/bin/expect<<-EOF
					# set timeout 1
					# spawn git push origin master 
					# expect "*username"
					# send "ut000827\r"
					# expect "*password:"
					# send "hhz+2249123..\r"
					# send "hhz+2249123..\r"
					#interact
					# EOF
					bash demand.sh
					echo ""
					cd - &>/dev/null
					if test -d demand
					then
						rm -rf demand
					fi
					echo -e "\033[46;30;8m ******************************************************************* \033[0m"
					read -p "已提交，点击Enter返回！"
					;;
				2)
					if test -d demand
					then
						rm -rf demand
					fi
					echo ""
					echo "bye"
					echo "bye"
					echo "欢迎大家提需求！";sleep 1
					;;
				*)
					if test -d demand
					then
						rm -rf demand
					fi
					echo ""
					echo "bye"
					echo "bye"
					echo "欢迎大家提需求！";sleep 1
					;;
			esac
			;;
			zzz)
				read -p "输入要执行的命令：" zzz
				${zzz}
				read -p "点击Enter后返回菜单!" Enter
				;;
			5201314)
				echo -e "\n别~ 你是个好人! 我们不合适 !"
				echo -e "\n【Y】拉取工具源码\n【*】任意输入退出\nPs.该功能仅支持内网! 源码不一定是最新版，因更新差异不大，若存在重大更新会更新源码版本! "
				read -p "请输入菜单项：" _y
				case $_y in
					y)
						p=`ping -c1 ${update_server}`
						if [ "$?" == "0" ]
						then
							wget -q ftp://${update_server}/tools_coding/p/*
							echo
							read -p "已下载源码${tool_name}_coding.sh至当前目录[${PWD}]，点击Enter返回！" enter
						else
							read -p "服务器未启用，请联网升级工具或之后重新尝试，点击Enter返回！" enter
						fi
						;;
					*)
						echo -e "\nbye\nbye\n好人~"
						sleep 1
						;;
				esac
				;;
			*)
				echo -e "\e[1;41m无此序号，请重新输入！ \e[0m" && sleep 1
				;;
		esac
	done
}

main