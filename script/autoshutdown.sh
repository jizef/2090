#!/bin/sh
# version: 0.2
# date: 
# description: 判断电池损耗并在适当的剩余电量时关闭主机

# 事实证明acpid 判断的电池损耗没有太大参考意义，想得到更精确的数值仍然需多次校准

acpi -b | awk -F'[,:%]' '{print $2, $3}' | {
read -r status capacity

full=$(acpi -V|sed -n '2p'|cut -d ' ' -f 13|tr -d '%')

	if [ "$status" = Discharging -a "$capacity" -lt $((110-full)) ]; then
		logger "正常关闭"
		poweroff
	fi
}

