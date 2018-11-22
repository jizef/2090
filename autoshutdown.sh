#!/bin/sh
# �жϵ����Ĳ����ʵ���ʣ�����ʱ�ر�����
# Version��0.2
acpi -b | awk -F'[,:%]' '{print $2, $3}' | {

read -r status capacity

full=$(acpi -V|sed -n '2p'|cut -d ' ' -f 13|tr -d '%')

	if [ "$status" = Discharging -a "$capacity" -lt $((110-full)) ]; then
		logger "�����ر�"
		poweroff
	fi
}

