#! /bin/bash


#Author: Magdy AboKhedr
#Date: 5/8/2024
#Embedded Linux Course
#Bash Script Project 

log="cmd_logfile"
log_="bash_logfile"
conrol_led() {
local led_name=$1
local state=$2
local led_path="/sys/class/leds/$led_name"

if [ -d "$led_path" ]; then
	echo $state | sudo tee "$led_path/brightness"
else
	echo "LED $led_name not found!"
fi


}


if [ "$EUID" -eq 0 ]; then
	s_flag=1
	echo "Welcome sudo.."
else
	s_flag=0
	echo "Welcome user.."
	
fi

if [ -f "$log" ]; then
		echo "Log File found to save your kernel logs @ $log"
	else
		echo "Log file was not found, creating $log"
		touch $log
		
	fi


if [ -f "$log" ]; then
		echo "Log File found to save your script logs @ $log_"
	else
		echo "Log file was not found, creating $log_"
		touch $log
		
	fi
echo "Type 'help' for list of commands: "
	
while true
do
	
	
	read -p ">> " choice
	echo $choice >> "$log_"
	
	
	case $choice in
	
		help)
			echo "sysinfo (all users) "
			echo ">> shows information about your system (CPU info, RAM usage, DISK usage) <<"
			
			echo ""
			echo "devices (sudo only) "
			echo ">> controls leds of numlock, capslock, scrolllock <<"
			
			echo ""
			echo "network (all users) "
			echo ">> shows information about your system network (IP, DNS, Download/Upload Usage) <<"
			
			echo ""
			echo "reboot (sudo only) "
			echo ">> reboots your system <<"
			
			echo ""
			echo "shutdown (sudo only) "
			echo ">> shutdowns your system <<"
			
			echo ""
			echo "kernellog (sudo only) "
			echo ">> Displays kernel log <<"
			
			echo ""
			echo "exit"
			echo ">> exits bash <<"
			;;
		
		sysinfo)
			echo "CPU Usage Info: : "
			cat /proc/stat
			echo ""
			echo "CPU Frequency: "
			cat /proc/cpuinfo | grep MHz
			echo ""
			echo "RAM Usage Info: "
			total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
			free_mem=$(grep MemFree /proc/meminfo | awk '{print $2}')
			buffers=$(grep Buffers /proc/meminfo | awk '{print $2}')
			cached=$(grep ^Cached /proc/meminfo | awk '{print $2}')
				
			used_mem_kb=$((total_mem - free_mem - buffers - cached))
			used_mem_gb=$(echo "scale=2; $used_mem_kb / 1024 / 1024" | bc)
				
			echo "Used Memory: $used_mem_gb GB"
			echo ""
			
			echo "DISK usage and free space: "
			df -h --output=source,fstype,size,used,avail,pcent,target
			echo ""
			;;
			
		devices)
			if [ $s_flag != 1 ]; then
				echo "Please use sudo for this command "
			else
				
				echo "1.CAPS LOCK"
				echo "2.NUM LOCK"
				echo "3.SCROLL LOCK"
				read -p "Select button to control: " led_choice
				
				case $led_choice in
					1) 
						led_name="input2::capslock"
						;;
					2)
						
						led_name="input2::numlock"
						;;
					3)
						led_name="input2::scrolllock"
						;;
					*)
						echo "Invalid button choice"
						;;
				esac
				
				read -p "Select state of the button selected (0-OFF, 1-ON: )" state
				
				if [[ "$state" != "0" && "$state" != "1" ]]; then
					echo "Invalid state!"
				fi
				conrol_led "$led_name" "$state"
				
			fi
				;;
		network)
			log_file="network_logfile"
			ip_add=$(ip a | grep -w inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1)
			echo "IP Address: "
			echo "$ip_add"
			
			dns_serv=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
			echo "DNS: "
			echo "$dns_serv"
			
			if [ -f "$log_file" ]; then
				echo "Network traffic logging to $log_file"
				vnstat -l -i enp0s3 >> "$log_file"
			else 
				touch "$log_file"
				echo "Network traffic logging to $log_file"
				vnstat -l -i enp0s3 >> "$log_file"
			fi
			
			;;
		reboot)
			if [ $s_flag != 1 ]; then
				echo "Please use sudo for this command"
			else
				read -p "Are you sure you want to reboot? (Y/n)" c
				if [ $c == "Y" ]; then
					sudo reboot
				fi 
			fi
			;;
		
		shutdown)
			if [ $s_flag != 1 ]; then
				echo "Please use sudo for this command"
			else
				read -p "Are you sure you want to reboot? (Y/n)" c
				if [ $c == "Y" ]; then
					sudo shutdown -h now
				fi 
				
			fi
			;;
			
		kernellog)
			if [ $s_flag != 1 ]; then
				echo "Please use sudo for this command "
			else
				cat /var/log/kern.log >> "$log"
			fi
			
			;;
			
		exit)
			echo "Thank you!"
			break
			;;
		*)
			echo "Incorrect Command!"
			;;
		esac
				
	
	
done


