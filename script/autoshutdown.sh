#!/bin/sh
# version: 0.2
# date: 
# description: �жϵ����Ĳ����ʵ���ʣ�����ʱ�ر�����

# ��ʵ֤��acpid �жϵĵ�����û��̫��ο����壬��õ�����ȷ����ֵ��Ȼ����У׼

acpi -b | awk -F'[,:%]' '{print $2, $3}' | {
read -r status capacity

full=$(acpi -V|sed -n '2p'|cut -d ' ' -f 13|tr -d '%')

	if [ "$status" = Discharging -a "$capacity" -lt $((110-full)) ]; then
		logger "�����ر�"
		poweroff
	fi
}

