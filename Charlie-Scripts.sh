#! /bin/bash

#版本
sh_v="1.0"
#字體顏色
zc_hui='\e[37m' ##gl_hui
zc_red='\033[31m' ##gl_hong
zc_lv='\033[32m' ##gl_lv
zc_yellow='\033[33m' ##gl_huang
zc_green='\033[0m' ##gl_ba
zc_purple='\033[35m' ##gl_zi
zc_lightblue='\033[96m' ##zc_lightblue

#主菜單
charlie_sh() {
clear
echo -e "Charlie個人系統腳本--用於Debian/Ubuntu系統"
echo -e "版本為: v$sh_v"
echo -e "輸入${zc_yellow}c${zc_lightblue}可以快速開啟脚本-${zc_green}"
echo -e "${zc_lightblue}------------------------${zc_green}"
echo -e "${zc_lightblue}1.   ${zc_green}系统內容查詢"
echo -e "${zc_lightblue}2.   ${zc_green}系统更新"
echo -e "${zc_lightblue}3.   ${zc_green}系统清理"
echo -e "${zc_lightblue}4.  ${zc_green}系统工具 >> "
echo -e "${zc_lightblue}000.  ${zc_green}脚本更新"
echo -e "${zc_lightblue}------------------------${zc_green}"
echo -e "${zc_lightblue}0.   ${zc_green}退出脚本"
echo -e "${zc_lightblue}------------------------${zc_green}"
read -e -p "请输入你的选择: " choice

case $choice in
  1) linux_ps ;;
  2) clear ; send_stats "系统更新" ; linux_update ;;
  3) clear ; send_stats "系统清理" ; linux_clean ;;
  4) system_tools ;;
  000) charlie_update ;;
  0) clear ; exit ;;
  *) echo "无效的输入!" ;;
esac
	break_end
done
}

#系统更新
linux_update(){
    apt update && apt upgrade -y
}

#系统內容查詢
linux_ps() {

	clear
	send_stats "系统內容查詢"

	ip_address

	local cpu_info=$(lscpu | awk -F': +' '/Model name:/ {print $2; exit}')

	local cpu_usage_percent=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf "%.0f\n", (($2+$4-u1) * 100 / (t-t1))}' \
		<(grep 'cpu ' /proc/stat) <(sleep 1; grep 'cpu ' /proc/stat))

	local cpu_cores=$(nproc)

	local cpu_freq=$(cat /proc/cpuinfo | grep "MHz" | head -n 1 | awk '{printf "%.1f GHz\n", $4/1000}')

	local mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2f MB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

	local disk_info=$(df -h | awk '$NF=="/"{printf "%s/%s (%s)", $3, $2, $5}')

	local ipinfo=$(curl -s ipinfo.io)
	local country=$(echo "$ipinfo" | grep 'country' | awk -F': ' '{print $2}' | tr -d '",')
	local city=$(echo "$ipinfo" | grep 'city' | awk -F': ' '{print $2}' | tr -d '",')
	local isp_info=$(echo "$ipinfo" | grep 'org' | awk -F': ' '{print $2}' | tr -d '",')

	local load=$(uptime | awk '{print $(NF-2), $(NF-1), $NF}')
	local dns_addresses=$(awk '/^nameserver/{printf "%s ", $2} END {print ""}' /etc/resolv.conf)


	local cpu_arch=$(uname -m)

	local hostname=$(uname -n)

	local kernel_version=$(uname -r)

	local congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
	local queue_algorithm=$(sysctl -n net.core.default_qdisc)

	local os_info=$(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '"')

	output_status

	local current_time=$(date "+%Y-%m-%d %I:%M %p")


	local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dMB/%dMB (%d%%)", used, total, percentage}')

	local runtime=$(cat /proc/uptime | awk -F. '{run_days=int($1 / 86400);run_hours=int(($1 % 86400) / 3600);run_minutes=int(($1 % 3600) / 60); if (run_days > 0) printf("%d天 ", run_days); if (run_hours > 0) printf("%d时 ", run_hours); printf("%d分\n", run_minutes)}')

	local timezone=$(current_timezone)


	echo ""
	echo -e "系统內容查詢結果"
	echo -e "${cz_lightblue}-------------"
	echo -e "${cz_lightblue}主機名:       ${cz_green}$hostname"
	echo -e "${cz_lightblue}系統版本:     ${cz_green}$os_info"
	echo -e "${cz_lightblue}Linux版本:    ${cz_green}$kernel_version"
	echo -e "${cz_lightblue}-------------"
	echo -e "${cz_lightblue}CPU架構:      ${cz_green}$cpu_arch"
	echo -e "${cz_lightblue}CPU型號:      ${cz_green}$cpu_info"
	echo -e "${cz_lightblue}CPU核心數:    ${cz_green}$cpu_cores"
	echo -e "${cz_lightblue}CPU頻率:      ${cz_green}$cpu_freq"
	echo -e "${cz_lightblue}-------------"
	echo -e "${cz_lightblue}CPU用量:      ${cz_green}$cpu_usage_percent%"
	echo -e "${cz_lightblue}系统負載:     ${cz_green}$load"
	echo -e "${cz_lightblue}物理mem:     ${cz_green}$mem_info"
	echo -e "${cz_lightblue}虛擬mem:     ${cz_green}$swap_info"
	echo -e "${cz_lightblue}硬盘用量:     ${cz_green}$disk_info"
	echo -e "${cz_lightblue}-------------"
	echo -e "${cz_lightblue}$output"
	echo -e "${cz_lightblue}-------------"
	echo -e "${cz_lightblue}網路算法:     ${cz_green}$congestion_algorithm $queue_algorithm"
	echo -e "${cz_lightblue}-------------"
	echo -e "${cz_lightblue}網路供應商:       ${cz_green}$isp_info"
	if [ -n "$ipv4_address" ]; then
		echo -e "${cz_lightblue}IPv4 address:     ${cz_green}$ipv4_address"
	fi

	if [ -n "$ipv6_address" ]; then
		echo -e "${cz_lightblue}IPv6 address:     ${cz_green}$ipv6_address"
	fi
	echo -e "${cz_lightblue}DNS addresses:      ${cz_green}$dns_addresses"
	echo -e "${cz_lightblue}時區位置:     ${cz_green}$country $city"
	echo -e "${cz_lightblue}系統時間:     ${cz_green}$timezone $current_time"
	echo -e "${cz_lightblue}-------------"
	echo -e "${cz_lightblue}運行時間:     ${cz_green}$runtime"

}

#系統清理
linux_clean(){
    echo -e "${zc_yellow}正在進行系統清理...${zc_green}"
	if command -v dnf &>/dev/null; then
		dnf autoremove -y
		dnf clean all
		dnf makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v yum &>/dev/null; then
		yum autoremove -y
		yum clean all
		yum makecache
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apt &>/dev/null; then
		fix_dpkg
		apt autoremove --purge -y
		apt clean -y
		apt autoclean -y
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v apk &>/dev/null; then
		echo "清理cache中..."
		apk cache clean
		echo "刪除Log中..."
		rm -rf /var/log/*
		echo "删除APK cache中..."
		rm -rf /var/cache/apk/*
		echo "刪除tmp檔案中..."
		rm -rf /tmp/*

	elif command -v pacman &>/dev/null; then
		pacman -Rns $(pacman -Qdtq) --noconfirm
		pacman -Scc --noconfirm
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v zypper &>/dev/null; then
		zypper clean --all
		zypper refresh
		journalctl --rotate
		journalctl --vacuum-time=1s
		journalctl --vacuum-size=500M

	elif command -v opkg &>/dev/null; then
		echo "删除Log中..."
		rm -rf /var/log/*
		echo "删除tmp檔案中..."
		rm -rf /tmp/*

	else
		echo "未知的包管理器!"
		return
	fi
	return

}

#系統工具
system_tools() {

	while true; do
	  clear
	  # send_stats "系统工具"
	  echo -e ">> 系统工具"
	  echo -e "${zc_lightblue}------------------------"
	  echo -e "${zc_lightblue}1.   ${zc_green}設定腳本快速啟動鍵"
	  echo -e "${zc_lightblue}2.   ${zc_green}開放所有的Ports                     ${zc_lightblue}3.   ${zc_green}更改ssh-port"
	  echo -e "${zc_lightblue}4.   ${zc_green}更改DNS-address                     ${zc_lightblue}5.   ${zc_green}重載Linux系統"
	  echo -e "${zc_lightblue}6.  ${zc_green}切換優先類型 IPv4/IPv6"
	  echo -e "${zc_lightblue}------------------------"
	  echo -e "${zc_lightblue}7.  ${zc_green}查看ports使用狀態                   ${zc_lightblue}8.  ${zc_green}更改virtual-mem大小"
	  echo -e "${zc_lightblue}9.  ${zc_green}時區調整                       ${zc_lightblue}10.  ${zc_green}設定BBR加速"
	  echo -e "${zc_lightblue}11.  ${zc_green}Firewall 高級管理                   ${zc_lightblue}12.  ${zc_green}更改主機名"
	  echo -e "${zc_lightblue}13.  ${zc_green}切換系統更新來源                     ${zc_lightblue}14.  ${zc_green}定時 Scripts-Task管理"
	  echo -e "${zc_lightblue}------------------------"
	  echo -e "${zc_lightblue}15.  ${zc_green}Server-host解析                       ${zc_lightblue}16.  ${zc_green}Fail2banSSH防禦程式"
	  echo -e "${zc_lightblue}17.  ${zc_green}限流後自動關機(still other people's script)                       ${zc_lightblue}18.  ${zc_green}ROOT私鑰登入"
	  echo -e "${zc_lightblue}19.  ${zc_green}Telegram-bot系統監控和預警(still other people's script)"
	  echo -e "${zc_lightblue}20.  ${zc_green}紅帽系統Linux内核升级                ${zc_lightblue}21.  ${zc_green}預設Linux系统内核参数改善"
	  echo -e "${zc_lightblue}22.  ${zc_green}病毒掃描工具                      ${zc_lightblue}23.  ${zc_green}文件管理"
	  echo -e "${zc_lightblue}------------------------"
	  echo -e "${zc_lightblue}24.  ${zc_green}由裡到外系統改善"
	  echo -e "${zc_lightblue}------------------------"
	  echo -e "${zc_lightblue}25.  ${zc_green}Reboot                         ${zc_lightblue}26. ${zc_green}Privacy&&Security"
	  echo -e "${zc_lightblue}------------------------"
	  echo -e "${zc_lightblue}99. ${zc_green}刪除此Scripts"
	  echo -e "${zc_lightblue}------------------------"
	  echo -e "${zc_lightblue}0.   ${zc_green}回到Menu"
	  echo -e "${zc_lightblue}------------------------${zc_green}"
	  read -e -p "請輸入: " sub_choice

	  case $sub_choice in
		  1)
			  while true; do
				  clear
				  read -e -p "請輸入想要設定的快捷鍵(0 取消設定): " quickshorts
				  if [ "$quickshorts" == "0" ]; then
					   break_end
					   system_tools
				  fi

				  sed -i '/alias .*='\''k'\''$/d' ~/.bashrc

				  echo "alias $quickshorts='k'" >> ~/.bashrc
				  sleep 1
				  source ~/.bashrc

				  echo "快捷键已設定"
				  send_stats "Scripts快捷键已設定"
				  break_end
				  system_tools
			  done
			  ;;


		  2)
			  root_use
			  send_stats "開放所有Ports"
			  iptables_open
			  remove iptables-persistent ufw firewalld iptables-services > /dev/null 2>&1
			  echo "Ports已全部開放"

			  ;;
		  3)
			root_use
			send_stats "更改SSH-Port"

			while true; do
				clear
				sed -i 's/#Port/Port/' /etc/ssh/sshd_config

				# 讀取目前的 SSH Port
				local current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

				# 顯示目前的 SSH Port
				echo -e "目前的 SSH Port是:  ${gl_huang}$current_port ${zc_green}"

				echo "------------------------"
				echo "Port必須是1到65535之間的數字。(按0退出)"

				# 提示用戶输入新的 SSH port
				read -e -p "請輸入新的 SSH port: " new_port

				# 分析Port是否有在範圍内
				if [[ $new_port =~ ^[0-9]+$ ]]; then  # 检查是否為數字
					if [[ $new_port -ge 1 && $new_port -le 65535 ]]; then
						send_stats "SSH-port已更改"
						new_ssh_port
					elif [[ $new_port -eq 0 ]]; then
						send_stats "退出SSH-port更改"
						break
					else
						echo "port無效, 請輸入1到65535之間的數字. "
						send_stats "输入无效SSH端口"
						break_end
					fi
				else
					echo "無效, 請輸入數字. "
					send_stats "輸入無效SSH-port."
					break_end
				fi
			done


			  ;;


		  4)
			set_dns_ui
			  ;;

		  5)

			dd_xitong
			  ;;

		  6)
			root_use
			send_stats "切換優先類型 IPv4/IPv6"
			while true; do
				clear
				echo "切換優先類型 IPv4/IPv6"
				echo "------------------------"
				local ipv6_disabled=$(sysctl -n net.ipv6.conf.all.disable_ipv6)

				if [ "$ipv6_disabled" -eq 1 ]; then
					echo -e "目前網路優先類型設定: ${gl_huang}IPv4${zc_green} 優先"
				else
					echo -e "目前網路優先類型設定: ${gl_huang}IPv6${zc_green} 優先"
				fi
				echo ""
				echo "------------------------"
				echo "1. IPv4 優先          2. IPv6 優先          3. IPv6 修復工具          0. 退出"
				echo "------------------------"
				read -e -p "選擇優先的網路類型: " choice

				case $choice in
					1)
						sysctl -w net.ipv6.conf.all.disable_ipv6=1 > /dev/null 2>&1
						echo "已更改為 IPv4 優先"
						send_stats "已更改為 IPv4 優先"
						;;
					2)
						sysctl -w net.ipv6.conf.all.disable_ipv6=0 > /dev/null 2>&1
						echo "已更改為 IPv6 優先"
						send_stats "已更改為 IPv6 優先"
						;;

					3)
						clear
						bash <(curl -L -s jhb.ovh/jb/v6.sh)
						send_stats "IPv6修復"
						;;

					*)
						break
						;;

				esac
			done
			;;

		  7)
			clear
			ss -tulnape
			;;

		  8)
			root_use
			send_stats "更改virtual-mem大小"
			while true; do
				clear
				echo "更改virtual-mem大小"
				local swap_used=$(free -m | awk 'NR==3{print $3}')
				local swap_total=$(free -m | awk 'NR==3{print $2}')
				local swap_info=$(free -m | awk 'NR==3{used=$3; total=$2; if (total == 0) {percentage=0} else {percentage=used*100/total}; printf "%dMB/%dMB (%d%%)", used, total, percentage}')

				echo -e "目前的Virtual-mem是: ${gl_huang}$swap_info${zc_green}"
				echo "------------------------"
				echo "1. 1024MB         2. 2048MB         3. 看自己想要多大：）         0. 退出"
				echo "------------------------"
				read -e -p "請輸入: " choice

				case "$choice" in
				  1)
					send_stats "已設定1G Virtual-mem"
					add_swap 1024

					;;
				  2)
					send_stats "已設定2G Virtual-mem"
					add_swap 2048

					;;
				  3)
					read -e -p "請輸入virtual-mem大小: " new_swap
					add_swap "$new_swap"
					send_stats "已設定為你想要的virtual-mem大小"
					;;

				  *)
					break
					;;
				esac
			done
			;;


		  9)
			root_use
			send_stats "時區調整"
			while true; do
				clear
				echo "目前系統時區"

				# 取得目前系統時區
				local timezone=$(current_timezone)

				# 取得目前系統時間
				local current_time=$(date +"%Y-%m-%d %H:%M:%S")

				# 顯示目前系統時區與時間
				echo "目前系統時區：$timezone"
				echo "目前系統時間：$current_time"

				echo ""
				echo "時區調整"
				echo "------------------------"
				echo "亞洲"
				echo "1.  中國上海時間             2.  香港時間"
				echo "3.  日本東京時間             4.  韓國首爾時間"
				echo "5.  新加坡時間               6.  印度加爾各答時間"
				echo "7.  阿聯酋杜拜時間           8.  澳洲雪梨時間"
				echo "9.  泰國曼谷時間"
				echo "------------------------"
				echo "歐洲"
				echo "11. 英國倫敦時間             12. 法國巴黎時間"
				echo "13. 德國柏林時間             14. 俄羅斯莫斯科時間"
				echo "15. 荷蘭阿姆斯特丹時間       16. 西班牙馬德里時間"
				echo "------------------------"
				echo "美洲"
				echo "21. 美國西部時間             22. 美國東部時間"
				echo "23. 加拿大时间               24. 墨西哥時間"
				echo "25. 巴西時間                 26. 阿根廷時間"
				echo "------------------------"
				echo "0. 返回上一頁"
				echo "------------------------"
				read -e -p "請輸入: " sub_choice


				case $sub_choice in
					1) set_timedate Asia/Shanghai ;;
					2) set_timedate Asia/Hong_Kong ;;
					3) set_timedate Asia/Tokyo ;;
					4) set_timedate Asia/Seoul ;;
					5) set_timedate Asia/Singapore ;;
					6) set_timedate Asia/Kolkata ;;
					7) set_timedate Asia/Dubai ;;
					8) set_timedate Australia/Sydney ;;
					9) set_timedate Asia/Bangkok ;;
					11) set_timedate Europe/London ;;
					12) set_timedate Europe/Paris ;;
					13) set_timedate Europe/Berlin ;;
					14) set_timedate Europe/Moscow ;;
					15) set_timedate Europe/Amsterdam ;;
					16) set_timedate Europe/Madrid ;;
					21) set_timedate America/Los_Angeles ;;
					22) set_timedate America/New_York ;;
					23) set_timedate America/Vancouver ;;
					24) set_timedate America/Mexico_City ;;
					25) set_timedate America/Sao_Paulo ;;
					26) set_timedate America/Argentina/Buenos_Aires ;;
					*) break ;; # 跳出循环，退出菜单
				esac
			done
			  ;;

		  10)

			bbrv3
			  ;;

		  11)
		  	root_use
		 	 while true; do
			if dpkg -l | grep -q iptables-persistent; then
				  clear
				  echo "Firewall 高級管理"
				  send_stats "Firewall 高級管理"
				  echo "------------------------"
				  iptables -L INPUT

				  echo ""
				  echo "Firewall"
				  echo "------------------------"
				  echo "1.  開放指定Port                 2.  關閉指定Port"
				  echo "3.  開放所有Port                 4.  關閉所有Port"
				  echo "------------------------"
				  echo "5.  IP白名單                  	 6.  IP黑名單"
				  echo "7.  清除指定IP"
				  echo "------------------------"
				  echo "11. 允許PING                  	 12. 禁止PING"
				  echo "------------------------"
				  echo "99. 消除Firewall規則"
				  echo "------------------------"
				  echo "0. 回到上一頁"
				  echo "------------------------"
				  read -e -p "請輸入: " sub_choice

				  case $sub_choice in
					  1)
						   read -e -p "請輸入欲開放的Port: " o_port
						   sed -i "/COMMIT/i -A INPUT -p tcp --dport $o_port -j ACCEPT" /etc/iptables/rules.v4
						   sed -i "/COMMIT/i -A INPUT -p udp --dport $o_port -j ACCEPT" /etc/iptables/rules.v4
						   iptables-restore < /etc/iptables/rules.v4
						   send_stats "已打開指定的Port"

						  ;;
					  2)
						  read -e -p "請輸入欲關閉的Port: " c_port
						  sed -i "/--dport $c_port/d" /etc/iptables/rules.v4
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "已關閉指定的Port"
						  ;;

					  3)
						  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

						  cat > /etc/iptables/rules.v4 <<< '*filter
								:INPUT ACCEPT [0:0]
								:FORWARD ACCEPT [0:0]
								:OUTPUT ACCEPT [0:0]
								-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
								-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
								-A INPUT -i lo -j ACCEPT
								-A FORWARD -i lo -j ACCEPT
								-A INPUT -p tcp --dport '"$current_port"' -j ACCEPT
								COMMIT'
						  #cat > /etc/iptables/rules.v4 << EOF
							#*filter
							#:INPUT ACCEPT [0:0]	
							#:FORWARD ACCEPT [0:0]
							#:OUTPUT ACCEPT [0:0]
							#-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
							#-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
							#-A INPUT -i lo -j ACCEPT
							#-A FORWARD -i lo -j ACCEPT
							#-A INPUT -p tcp --dport $current_port -j ACCEPT
							#COMMITEOF
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "已開放所有Port"
						  ;;
					  4)
						  current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

						  cat > /etc/iptables/rules.v4<<< '*filter
									:INPUT DROP [0:0]
									FORWARD DROP [0:0]
									:OUTPUT ACCEPT [0:0]
									-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
									-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
									-A INPUT -i lo -j ACCEPT
									-A FORWARD -i lo -j ACCEPT
									-A INPUT -p tcp --dport $current_port -j ACCEPT
									COMMIT'
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "已關閉所有Port"
						  ;;

					  5)
						  read -e -p "請輸入欲放行的IP: " o_ip
						  sed -i "/COMMIT/i -A INPUT -s $o_ip -j ACCEPT" /etc/iptables/rules.v4
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "IP白名單"
						  ;;

					  6)
						  read -e -p "請輸入欲封鎖的IP: " c_ip
						  sed -i "/COMMIT/i -A INPUT -s $c_ip -j DROP" /etc/iptables/rules.v4
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "IP黑名單"
						  ;;

					  7)
						  read -e -p "請輸入欲清除的IP: " d_ip
						  sed -i "/-A INPUT -s $d_ip/d" /etc/iptables/rules.v4
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "已清除指定的IP"
						  ;;

					  11)
						  sed -i '$i -A INPUT -p icmp --icmp-type echo-request -j ACCEPT' /etc/iptables/rules.v4
						  sed -i '$i -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT' /etc/iptables/rules.v4
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "已允許ping"
						  ;;

					  12)
						  sed -i "/icmp/d" /etc/iptables/rules.v4
						  iptables-restore < /etc/iptables/rules.v4
						  send_stats "已禁用ping"
						  ;;

					  99)
						  remove iptables-persistent
						  rm /etc/iptables/rules.v4
						  send_stats "已消除Firawall 規則"
						  break

						  ;;

					  *)
						  break  # 退出循環
						  ;;

				  esac
			else

				clear
				echo "將為您安裝FireWall, 僅支援 Debian/Ubuntu"
				echo "------------------------------------------------"
				read -e -p "R u sure about this? (Y/N) : " choice

				case "$choice" in
				  [Yy])
					if [ -r /etc/os-release ]; then
						. /etc/os-release
						if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
							echo "此系統並不支援!!!, 再說明一次僅支援 Debian和Ubuntu 系统!!"
							break_end
							system_tools
						fi
					else
						echo "無法確認系統類型"
						break
					fi

					clear
					iptables_open
					remove iptables-persistent ufw
					rm /etc/iptables/rules.v4

					apt update -y && apt install -y iptables-persistent

					local current_port=$(grep -E '^ *Port [0-9]+' /etc/ssh/sshd_config | awk '{print $2}')

					cat > /etc/iptables/rules.v4 <<<'*filter
							:INPUT DROP [0:0]
							:FORWARD DROP [0:0]
							:OUTPUT ACCEPT [0:0]
							-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
							-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
							-A INPUT -i lo -j ACCEPT
							-A FORWARD -i lo -j ACCEPT
							-A INPUT -p tcp --dport $current_port -j ACCEPT
							COMMIT'

					iptables-restore < /etc/iptables/rules.v4
					systemctl enable netfilter-persistent
					echo "FireWall 已安裝完成"
					break_end
					;;
				  *)
					echo "已取消"
					break
					;;
				esac
			fi
		    done ;;

		  12)
		    root_use
		    send_stats "更改主機名"

		        while true; do
	    		  clear
		    	  local current_hostname=$(uname -n)
		    	  echo -e "目前主機名: ${gl_huang}$current_hostname${zc_green}"
		    	  echo "------------------------"
		    	  read -e -p "請輸入新的主機名 (輸入0返回) : " new_hostname
		    	  if [ -n "$new_hostname" ] && [ "$new_hostname" != "0" ]; then
				    if [ -f /etc/alpine-release ]; then
					  # Alpine
					  echo "$new_hostname" > /etc/hostname
					  hostname "$new_hostname"
				    else
					  # 其他系統，如 Debian, Ubuntu, CentOS 等
					  hostnamectl set-hostname "$new_hostname"
					  sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
					  systemctl restart systemd-hostnamed
				  fi

				    if grep -q "127.0.0.1" /etc/hosts; then
					  sed -i "s/127.0.0.1 .*/127.0.0.1       $new_hostname localhost localhost.localdomain/g" /etc/hosts
				    else
					  echo "127.0.0.1       $new_hostname localhost localhost.localdomain" >> /etc/hosts
				  fi

				    if grep -q "^::1" /etc/hosts; then
					  sed -i "s/^::1 .*/::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback/g" /etc/hosts
				    else
					  echo "::1             $new_hostname localhost localhost.localdomain ipv6-localhost ipv6-loopback" >> /etc/hosts
				  fi

				  echo "主機名已更改為: $new_hostname"
				  send_stats "主機名已更改"
				  sleep 1
			    else
				  echo "已返回，未更改主機名。"
				  break
			  fi
		  	done
			  ;;

		  13)
		  	root_use
		  	send_stats "切換系統更新來源"
		  	clear
				  bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad
				  ;;	
		  14)
		  	send_stats "定時 Scripts-Task管理"
			  	while true; do
				  clear
				  check_crontab_installed
				  clear
				  echo "定時Tasks 管理"
				  crontab -l
				  echo ""
				  echo "操作選項"
				  echo "------------------------"
				  echo "1. 添加On-time Task              2. 刪除On-time Task              3. 編輯On-time Task"
				  echo "------------------------"
				  echo "0. 返回上一層"
				  echo "------------------------"
				  read -e -p "請輸入: " sub_choice

					case $sub_choice in
					  1)
						  read -e -p "請輸入新Task Order: " newquest
						  echo "------------------------"
						  echo "1. 每月Task                 2. 每週Task"
						  echo "3. 每天Task                 4. 每小時Task"
						  echo "------------------------"
						  read -e -p "請輸入: " Ontime

							  case $Ontime in
								  1)
									  read -e -p "選擇每月何時執行？ (1-30): " day
									  (crontab -l ; echo "0 0 $day * * $newquest") | crontab - > /dev/null 2>&1
									  ;;
								  2)
									  read -e -p "選擇星期幾執行？ (0-6, 0代表星期日): " weekday
									  (crontab -l ; echo "0 0 * * $weekday $newquest") | crontab - > /dev/null 2>&1
									  ;;
								  3)
									  read -e -p "選擇每天幾點執行? (小時, 0-23): " hour
									  (crontab -l ; echo "0 $hour * * * $newquest") | crontab - > /dev/null 2>&1
									  ;;
								  4)
									  read -e -p "選擇每小時第幾分鐘執行?(分鐘, 0-60): " minute
									  (crontab -l ; echo "$minute * * * * $newquest") | crontab - > /dev/null 2>&1
									  ;;
								  *)
									  break  # 跳出
									  ;;
						  	esac
						 	 send_stats "已添加定時Task"
						 	 ;;
					  2)
						  read -e -p "請輸入欲刪除的Task 關鍵詞: " KeyWord
						  crontab -l | grep -v "$KeyWord" | crontab -
						  send_stats "已刪除On-time Task <3"
						  ;;
					  3)
						  crontab -e
						  send_stats "已編輯On-time Task "
						  ;;
					  *)
						  break  # 跳出輪迴
						  ;;
				  esac
			  done

			  ;;

		  15)
			  	root_use
			  	send_stats "Server-host解析"
			  	while true; do
				  clear
				  echo "Server-host解析列表"
				  echo "如果你在這裡添加解析Matching, 就不需要再使用動態解析了"
				  cat /etc/hosts
				  echo ""
				  echo "操作選項"
				  echo "------------------------"
				  echo "1. 添加新的解析              2. 刪除解析Address"
				  echo "------------------------"
				  echo "0. 返回上一層"
				  echo "------------------------"
				  read -e -p "請輸入: " host_dns

				  case $host_dns in
					  1)
						  read -e -p "請輸入新的解析Rec 格式 (110.25.5.33 charlieshop.uk) : " addhost
						  echo "$addhost" >> /etc/hosts
						  send_stats "Local-host 解析已新增"

						  ;;
					  2)
						  read -e -p "請輸入欲刪除的解析內容關鍵詞: " delhost
						  sed -i "/$delhost/d" /etc/hosts
						  send_stats "已刪除Local-host 解析"
						  ;;
					  *)
						  break  # 跳出輪迴
						  ;;
				  esac
			  	done
			  	;;

		  16)
		  	root_use
		  	send_stats "Fail2banSSH防禦程式"
		  	while true; do
			if docker inspect fail2ban &>/dev/null ; then
					clear
					echo "SSH防禦程式已啟動"
					echo "------------------------"
					echo "1. 查看SSH攔截紀錄"
					echo "2. Log實時監控"
					echo "------------------------"
					echo "9. 解除安裝Fail2ban SSH防禦程式"
					echo "------------------------"
					echo "0. 退出"
					echo "------------------------"
					read -e -p "請輸入: " sub_choice
					case $sub_choice in

						1)
							echo "------------------------"
							f2b_sshd
							echo "------------------------"
							break_end
							;;
						2)
							tail -f /path/to/fail2ban/config/log/fail2ban/fail2ban.log
							break
							;;
						9)
							docker rm -f fail2ban
							rm -rf /path/to/fail2ban
							echo "Fail2BanSSH防禦程式已解除安裝"
							break
							;;
						*)
							echo "已取消"
							break
							;;
					esac

			elif [ -x "$(command -v fail2ban-client)" ] ; then
				clear
				echo "解除安裝舊版Fail2ban"
				read -e -p "R u sure ? (Y/N): " choice
				case "$choice" in
				  [Yy])
						remove fail2ban
						rm -rf /etc/fail2ban
						echo "舊款 Fail2BanSSH防禦程式已解除安裝"
						break_end
						;;
					*)
						echo "已取消"
						break
						;;
					esac

			else

			  clear
			  echo "Fail2Ban是一種SSH防止暴力破解工具"
			  echo "網站介紹: ${gh_proxy}https://github.com/fail2ban/fail2ban"
			  echo "------------------------------------------------"
			  echo "工作原理: 判斷Illegal IP惡意訪問SSH-Port, 自動進行IP封鎖"
			  echo "------------------------------------------------"
			  read -e -p "R u sure? (Y/N): " choice

			  case "$choice" in
				[Yy])
				  clear
				  install_docker
				  f2b_install_sshd

				  cd ~
				  f2b_status
				  echo "Fail2BanSSH防禦程式已開啟"
				  send_stats "SSH防禦 已安裝完成"
				  break_end
				  ;;
				*)
				  echo "已取消"
				  break
				  ;;
			  esac
			fi
			done
			  ;;


		  17)
			root_use
			send_stats "限流後自動關機"
			while true; do
				clear
				echo "限流後自動關機功能"
				echo "------------------------------------------------"
				echo "依當前流量使用狀況, Reboot後用量會計算自動歸零! "
				output_status
				echo "$output"

				# 檢查是否存在 Limiting_Shut_down.sh 檔案
				if [ -f ~/Limiting_Shut_down.sh ]; then
					# 獲得 threshold_gb 的值
					local rx_threshold_gb=$(grep -oP 'rx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
					local tx_threshold_gb=$(grep -oP 'tx_threshold_gb=\K\d+' ~/Limiting_Shut_down.sh)
					echo -e "${gl_lv}目前設定的進站限流值為: ${gl_huang}${rx_threshold_gb}${gl_lv}GB${zc_green}"
					echo -e "${gl_lv}目前設定的出站限流值為: ${gl_huang}${tx_threshold_gb}${gl_lv}GB${zc_green}"
				else
					echo -e "${gl_hui}目前未開啟限流關機功能${zc_green}"
				fi

				echo
				echo "------------------------------------------------"
				echo "系統會每分鐘檢測流量是否達到設定值, 到達後會自動關閉Server! "
				read -e -p "1. 開啟限流關機功能    2. 關閉限流關機功能    0. 退出  : " Limiting

				case "$Limiting" in
				  1)
					# 輸入新的Virtual-mem大小
					echo "如果實際服務器就100G用量, 可以設定95G並提前關機, 以免出現用量誤差或過量. "
					read -e -p "請輸入進站用量值 (單位是GB): " rx_threshold_gb
					read -e -p "請輸入出戰用量值 (單位是GB): " tx_threshold_gb
					read -e -p "請輸入用量重置日期(預設是每月一號進行重置): " cz_day
					local cz_day=${cz_day:-1}

					cd ~
					curl -Ss -o ~/Limiting_Shut_down.sh ${gh_proxy}https://raw.githubusercontent.com/kejilion/sh/main/Limiting_Shut_down1.sh
					chmod +x ~/Limiting_Shut_down.sh
					sed -i "s/110/$rx_threshold_gb/g" ~/Limiting_Shut_down.sh
					sed -i "s/120/$tx_threshold_gb/g" ~/Limiting_Shut_down.sh
					check_crontab_installed
					crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
					(crontab -l ; echo "* * * * * ~/Limiting_Shut_down.sh") | crontab - > /dev/null 2>&1
					crontab -l | grep -v 'reboot' | crontab -
					(crontab -l ; echo "0 1 $cz_day * * reboot") | crontab - > /dev/null 2>&1
					echo "限流關機設定已完成"
					send_stats "限流關機已設定"
					;;
				  2)
					check_crontab_installed
					crontab -l | grep -v '~/Limiting_Shut_down.sh' | crontab -
					crontab -l | grep -v 'reboot' | crontab -
					rm ~/Limiting_Shut_down.sh
					echo "已關閉限流關機功能"
					;;
				  *)
					break
					;;
				esac
			done
			  ;;


		  18)
			  root_use
			  send_stats "ROOT私鑰登入"
			  echo "ROOT私鑰登入模式"
			  echo "------------------------------------------------"
			  echo "將會生成公私鑰, 以利更安全的方式登入"
			  read -e -p "R u sure? (Y/N): " choice

			  case "$choice" in
				[Yy])
				  clear
				  send_stats "私鑰登入使用"
				  add_sshkey
				  ;;
				[Nn])
				  echo "已取消"
				  ;;
				*)
				  echo "無效輸入, 請輸入 Y 或 N"
				  ;;
			  esac

			  ;;

		  19)
			  root_use
			  send_stats "Telegram-bot系統監控和預警"
			  echo "Telegram-bot系統監控和預警"
			  echo "------------------------------------------------"
			  echo "需要配置TG-Bot的API和接收預警的用戶ID, 即可實現vps的CPU、mem、disk、網路用量、SSH登錄的實時監控預警"
			  echo "到達用量值後會像user發佈預警消息"
			  echo -e "${gl_hui}-關於網路用量值, 重啟伺服器後會重新計算!-${zc_green}"
			  read -e -p "R u sure? (Y/N): " choice

			  case "$choice" in
				[Yy])
				  send_stats "Telegram預警啟用"
				  cd ~
				  install nano tmux bc jq
				  check_crontab_installed
				  if [ -f ~/TG-check-notify.sh ]; then
					  chmod +x ~/TG-check-notify.sh
					  nano ~/TG-check-notify.sh
				  else
					  curl -sS -O ${gh_proxy}https://raw.githubusercontent.com/kejilion/sh/main/TG-check-notify.sh
					  chmod +x ~/TG-check-notify.sh
					  nano ~/TG-check-notify.sh
				  fi
				  tmux kill-session -t TG-check-notify > /dev/null 2>&1
				  tmux new -d -s TG-check-notify "~/TG-check-notify.sh"
				  crontab -l | grep -v '~/TG-check-notify.sh' | crontab - > /dev/null 2>&1
				  (crontab -l ; echo "@reboot tmux new -d -s TG-check-notify '~/TG-check-notify.sh'") | crontab - > /dev/null 2>&1

				  curl -sS -O ${gh_proxy}https://raw.githubusercontent.com/kejilion/sh/main/TG-SSH-check-notify.sh > /dev/null 2>&1
				  sed -i "3i$(grep '^TELEGRAM_BOT_TOKEN=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh > /dev/null 2>&1
				  sed -i "4i$(grep '^CHAT_ID=' ~/TG-check-notify.sh)" TG-SSH-check-notify.sh
				  chmod +x ~/TG-SSH-check-notify.sh

				  # 添加到 ~/.profile 文件中
				  if ! grep -q 'bash ~/TG-SSH-check-notify.sh' ~/.profile > /dev/null 2>&1; then
					  echo 'bash ~/TG-SSH-check-notify.sh' >> ~/.profile
					  if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
						 echo 'source ~/.profile' >> ~/.bashrc
					  fi
				  fi

				  source ~/.profile

				  clear
				  echo "Telegram-Bot預警系統已啟動"
				  echo -e "${gl_hui}可以將Root目錄中的TG-check-notify.sh預警文件放到其他機器上直接使用!${zc_green}"
				  ;;
				[Nn])
				  echo "已取消"
				  ;;
				*)
				  echo "無效輸入, 請正確輸入 Y 或 N。"
				  ;;
			  esac
			  ;;

		  20)
			  elrepo
			  ;;
		  21)
			  Kernel_optimize
			  ;;

		  22)
			  clamav
			  ;;

		  23)
			  linux_file
			  ;;


		  24)

			  root_use
			  send_stats "由裡到外系統改善"
			  echo "由裡到外系統改善"
			  echo "------------------------------------------------"
			  echo "將對以下內容進行操作及改善"
			  echo "1. 系統更新到Latest"
			  echo "2. 清除系統垃圾文件"
			  echo -e "3. 更改virtual-mem大小${gl_huang}1G${zc_green}"
			  echo -e -p "4. 請自行設定SSH-Port: " New_ssh_port
			  echo -e "5. 開放所有端口"
			  echo -e "6. 開啟${gl_huang}BBR${zc_green}加速"
			  echo -e "7. 設定系統時區至${gl_huang}東京${zc_green}"
			  echo -e "8. 自動優化DNS-Address${gl_huang}海外: 1.1.1.1 8.8.8.8${zc_green}"
			  echo -e "9. 安裝基礎必要工具${gl_huang}docker wget sudo tar unzip socat btop nano vim${zc_green}"
			  echo -e "10. Linux系統核心改善參數切換到${gl_huang}均衡模式${zc_green}"
			  echo "------------------------------------------------"
			  read -e -p "確定要一鍵改善嗎？(Y/N): " choice

			  case "$choice" in
				[Yy])
				  clear
				  send_stats "由裡到外系統改善啟動"
				  echo "------------------------------------------------"
				  linux_update
				  echo -e "[${gl_lv}${zc_green}] 1/10. 系統已更新"

				  echo "------------------------------------------------"
				  linux_clean
				  echo -e "[${gl_lv}OK${zc_green}] 2/10. 已清理系統垃圾文件"

				  echo "------------------------------------------------"
				  add_swap 1024
				  echo -e "[${gl_lv}OK${zc_green}] 3/10. 已更改virtual-mem大小為${gl_huang}1G${zc_green}"

				  echo "------------------------------------------------"
				  local new_port=$New_ssh_port
				  new_ssh_port
				  echo -e "[${gl_lv}OK${zc_green}] 4/10. 已設定 SSH-Port 為${gl_huang}$New_ssh_port${zc_green}"
				  echo "------------------------------------------------"
				  echo -e "[${gl_lv}OK${zc_green}] 5/10. 已開放所有Ports"

				  echo "------------------------------------------------"
				  bbr_on
				  echo -e "[${gl_lv}OK${zc_green}] 6/10. 已開啟${gl_huang}BBR${zc_green}加速"

				  echo "------------------------------------------------"
				  set_timedate Asia/Tokyo
				  echo -e "[${gl_lv}OK${zc_green}] 7/10. 已設定系統時區至${gl_huang}東京${zc_green}"

				  echo "------------------------------------------------"
					 local dns1_ipv4="1.1.1.1"
					 local dns2_ipv4="8.8.8.8"
					 local dns1_ipv6="2606:4700:4700::1111"
					 local dns2_ipv6="2001:4860:4860::8888"
				  set_dns
				  echo -e "[${gl_lv}OK${zc_green}] 8/10. 已自動更換DNS-Address${gl_huang}${zc_green}"

				  echo "------------------------------------------------"
				  install_docker
				  install wget sudo tar unzip socat btop nano vim
				  echo -e "[${gl_lv}OK${zc_green}] 9/10. 已安裝基礎工具${gl_huang}docker wget sudo tar unzip socat btop${zc_green}"
				  echo "------------------------------------------------"

				  echo "------------------------------------------------"
				  optimize_balanced
				  echo -e "[${gl_lv}OK${zc_green}] 10/10. 已改善Linux系统核心参数"
				  echo -e "${gl_lv}由裡到外系統改善已完成${zc_green}"

				  ;;
				[Nn])
				  echo "已取消"
				  ;;
				*)
				  echo "無效輸入, 請重新輸入 Y 或 N。"
				  ;;
			  esac

			  ;;

		  25)
			  clear
			  send_stats "Reboot Time!!"
			  server_reboot
			  ;;
		  26)

			root_use
				while true; do
				  clear
				  if grep -q '^ENABLE_STATS="true"' /usr/local/bin/k > /dev/null 2>&1; then
			  	local status_message="${gl_lv}正在收取Data${zc_green}"
				  elif grep -q '^ENABLE_STATS="false"' /usr/local/bin/k > /dev/null 2>&1; then
			  	local status_message="${gl_hui}已關閉Data收取${zc_green}"
				  else
			  	local status_message="無法確定的狀態"
				  fi

				  echo "隱私與安全"
				  echo "Scripts將會收取用戶使用的功能數據, 優化腳本體驗, 已製作更好用的功能. "
				  echo "將收集Scripts版本, 使用的時間, 系統版本, CPU架構, 機器所屬國家和使用的功能名稱. "
				  echo "可向 Charlie@charlieshop.uk 發出郵件並拿取此Script並自由更改. "
				  echo "------------------------------------------------"
				  echo -e "目前狀態: $status_message"
				  echo "--------------------"
				  echo "1. 允許收集"
				  echo "2. 禁止收集"
				  echo "--------------------"
				  echo "0. 返回上一層"
				  echo "--------------------"
				  read -e -p "請輸入您的選擇: " sub_choice
					  case $sub_choice in
						  1)
					 		 cd ~
							  sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' /usr/local/bin/k
							  sed -i 's/^ENABLE_STATS="false"/ENABLE_STATS="true"/' ~/Charlie-scripts.sh
							  echo "已開始收集"
					 		 send_stats "Privacy & Security 已允許我收集：）"
					 		 ;;
						  2)
							  cd ~
							  sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' /usr/local/bin/k
							  sed -i 's/^ENABLE_STATS="true"/ENABLE_STATS="false"/' ~/Charlie-scripts.sh
							  echo "已禁止收集"
							  send_stats "Privacy & Security 已停止收集：（ "
							  ;;
						  *)
							  break
							  ;;
				 		 esac
					done
				  ;;

		  99)
			  clear
			  send_stats "解除安裝Charlie-Scripts"
			  echo "解除安裝Charlie-Scripts"
			  echo "------------------------------------------------"
			  echo "將徹底解除安裝Charlie-Scripts, 不影響其他功能. "
			  read -e -p "R u sure? (Y/N): " choice

			  case "$choice" in
				[Yy])
				  clear
				  rm -f /usr/local/bin/k
				  rm ~/Charlie-Scripts.sh
				  echo "Scripts已解除安裝, Good Luck! まだいつか会おう! "
				  break_end
				  clear
				  exit
				  ;;
				[Nn])
				  echo "已取消, 感謝您對我的信任! <3"
				  ;;
				*)
				  echo "這時還會輸入錯誤, 其實不想把我刪掉吧~~ "
				  ;;
			  esac
			  ;;

		  0)
			  Charlie

			  ;;
		  *)
			  echo "請好好輸入!(Only in Num)"
			  ;;
	  esac
	  break_end

	done



}
