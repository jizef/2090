#!/bin/bash
# version: 0.1
# date: 24/11/2018
# description: efistub 引导模式修改内核参数

# !!! 仅供个人使用 !!!

# 改为你当前的用户密码
passwd='luoke'
# 不要改变这个变量
kerpar=$(cat /proc/cmdline | awk '{$1=""; sub(/^[[:blank:]]*/, ""); sub(/Linux\/microcode.img/, "\"Linux/microcode.img\""); print $0}')
# 不要改变这个变量
bootnum=$(efibootmgr | sed -n '1s/BootCurrent: // p')
# awk '{sub(/^.{4}/,""); print $1}'
disk='/dev/sda'
part=1
loader='\Linux\gentoo.efi'
label='2020'
efifile='/sys/firmware/efi/efivars'
status=$(efibootmgr | sed -n '3p')

function change_kerpar(){
	local u=$(echo $kerpar | sed 's/^/"/; s/$/"/')                        
	local newloader=$(echo $loader | sed 's/^/"/; s/$/"/')

	if [[ "$status" != Boot* ]]; then
		echo $passwd | sudo -S efibootmgr -c -L $label -d $disk -p $part -l $newloader -u $u 1> /dev/null
	else
		echo $passwd | sudo -S efibootmgr -b $bootnum -B 1> /dev/null					
		echo $passwd | sudo -S efibootmgr -c -L $label -d $disk -p $part -l $newloader -u $u 1> /dev/null
	fi
}

function confirm(){
	read -p "确认更改? y/N " s
	s=${s:-"n"}
	
	if [ "$s" == "y" -o "$s" == "Y" ]; then
		change_kerpar 
		echo "已更改"	
	elif [ "$s" == "n" -o "$s" == "N" ]; then
		echo "已退出"
		exit 0
	else
		echo "错误的输入!"
		exit 1
	fi
}

# 帮助
if [ ! $1 ]; then
	echo "efistub_tool !"
	echo "参数说明："
	echo "  -a	添加内核引导参数"
	echo "  -u	更改内核引导参数"
	echo "  -r	重置内核引导参数，仅在操作错误后没有重启时有效"
	exit
fi

case $1 in
	"-a")
	read -p "输入参数: " addu

	if [ ! $addu ]; then
		echo "没有任何参数，退出" && exit 0
	else
		kerpar="$kerpar $addu"
		echo "变更后参数: \"$kerpar\""
		confirm
	fi
	echo "重启以应用更改" && exit 0
	;;

	"-u")
	echo "!!! 自行检查所有参数，输入错误请使用 '-r' 重置（这仅在重启之前有效）"
	echo "!!! 严格检查以下两个参数的格式 !!!"
	echo -e "initrd=\"Linux\gentoo.efi\" acpi_osi='Window 2009'"
	echo "新参数: "
	read newu

	if [ ! $newu ]; then
		echo "没有任何参数, 退出" && exit 0
	else
		kerpar=$newu
		confirm
	fi
	echo "重启已应用更改" && exit 0
	exit 0
	;;

	"-r")
	change_kerpar
	echo "已重置" && exit 0
	;;

	*)
	echo "参数不正确!" && exit 1
	;;
esac

