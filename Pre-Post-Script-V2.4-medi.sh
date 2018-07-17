#!/bin/bash
#Version 2.4
#Usage : PRE-Post Script for Unix
#Author : Saravanan Arumugam
#Email : Saravanan.Arumugam@astrazeneca.com

#Usage Form
case "$1" in
'PRE')
 LOG=PRE
         ;;
'POST')
 LOG=POST
         ;;
*)
        echo "Usage: $0 { PRE | POST }"
        exit 1 
        ;;
esac
##
##Variables Declare
mkdir -p /var/tmp/precheck
OUTPUTFILE="/var/tmp/precheck/check-${LOG}-$HOSTNAME-$(date +%Y-%m-%d).txt"
IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
MULTI="/sbin/multipath"
CLUST="/usr/sbin/clustat"
IIP="157.96.165.123"
TMPMNT="/tmp/test"
SOURCEMNT="/var/ftp/pub/CHECK/PRECHECK"

#ROOT CHECK
clear
ID=`id | sed 's/uid=\([0-9]*\)(.*/\1/'`
if [ "$ID" != "0" ] ; then
        echo "You must be root to execute the script $0."
        exit 1
fi

#HOST INFORMATION
linuxhost() {
echo ""
echo "HOST INFORMATION"
echo "----------------"
echo ""
uname -a
echo ""
cat /etc/*-release
echo ""
echo ""
echo "KERNEL VERSION"
echo "---------------"
uname -r
echo ""
echo "UPTIME & USER INFO"
echo "------------------"
echo ""
/usr/bin/uptime
echo ""
who
echo ""
echo "NTP STATUS"
echo "----------"
ntpq -pn
}

#Disk Information
linuxdisk() {
echo ""
echo "Filesystem Information"
echo "----------------------"
echo ""
fdisk -l 2>/dev/null
echo ""
echo "FILE SYSTEMS: df -hP"
echo "---------------------"
echo ""
df -hP | column -t  
echo ""
echo "FILE SYSTEM COUNT"
echo "-----------------"
df -hP | sort | wc -l
echo ""
echo "FILESYSTEM SORT: df -hP | sort"
echo "------------------------------"
df -hP | sort | column -t 
echo ""
echo "FSTAB DETAILS:"
echo "--------------"
echo ""
cat /etc/fstab | column -t 
echo ""
echo "MTAB OUTPUT"
echo "-----------"
cat /etc/mtab | column -t
echo ""
echo ""
echo "MOUNT DETAILS:"
echo "--------------"
echo ""
mount 
echo ""
echo "IOSTAT DETAILS:"
echo "---------------"
echo ""
iostat
echo ""
echo "PV LIST DETAILS:"
echo "------------------"
echo ""
pvs
echo ""
echo "Volume Group LIST"
echo "----------------------"
echo ""
vgs
echo ""
echo "Logical Volume List"
echo "-------------"
echo ""
lvs
echo ""
}

##Cluster and Multipath Info
linuxcluster() {
echo ""
if [ -f "$MULTI" ]
then
	echo "MULTIPATH Configuration"
	echo "-----------------------"
	$MULTI -ll 2>/dev/null
	echo ""
else
	echo "MULTIPATH Not Found"
	echo "-------------------"
	echo ""
fi
echo ""
if [ -f "$CLUST" ]
then
	echo "CLUSTER Information"
	echo "-------------------"
	$CLUST  2>/dev/null
	echo ""
	echo "CLUSTER Detail Report"
	echo "---------------------"
	$CLUST -l 2>/dev/null
	echo ""
	echo "CMAN Tool Services"
	echo "------------------"
	cman_tool services 2>/dev/null
	echo ""
	echo "CMAN Status"
	echo "-----------"
	cman_tool status
	echo ""
	echo "Cluster Configuration file"
	echo "-------------------------------------"
	cat /etc/cluster/cluster.conf 2>/dev/null
	echo ""
else
	echo "Redhat Cluster Not Configured"
	echo "-----------------------------"
	echo ""
fi
}

#HArdware Information
linuxhardware() {
echo ""
echo "Hardware Information"
echo "---------------------"
echo ""
dmidecode --type 0,13
echo "NUMBER OF CPU's:"
echo "----------------"
echo ""
cat /proc/cpuinfo | egrep "processor|model name"
echo ""
echo "MEMORY INFORMATION:"
echo "-------------------"
echo ""
cat /proc/meminfo
echo ""
echo ""
free -m 
echo ""
}

#NETWORK INFORMATION
linuxnetwork() {
echo ""
echo "IFCONFIG INFO"
echo "-------------"
echo ""
ifconfig -a
echo ""
echo "NIC FDX/HDX - SPEED"
echo "-------------------"
echo ""
ETH=`/sbin/ifconfig -a | grep Link | grep HWaddr |awk  '{print $1}'`
for EN in $ETH
do
ethtool $EN
done
echo ""
echo "ROUTES DETAILS:"
echo "--------------"
echo ""
netstat -rn
echo ""
echo "NETSTAT -IN"
echo "------------"
echo ""
netstat -in
echo ""
echo "cat /etc/hosts "
echo "----------------"
cat /etc/hosts |sed -e '/^#/d'
echo ""
echo "cat /etc/resolv.conf"
echo "--------------------"
cat /etc/resolv.conf | sed -e '/^#/d'
echo ""
}

linuxservice()
{
echo ""
echo "Chkconfig list"
echo "---------------"
echo ""
/sbin/chkconfig --list
echo ""
echo "RHEL 6 Services"
echo "---------------"
systemctl list-unit-files --type=service 
echo ""
echo "SHOWMOUNT FOR LOCALHOST"
echo "-----------------------"
echo ""
showmount -e localhost
echo ""
echo "MOUNTED IN CLIENT SIDE"
echo "----------------------"
netstat -apn | grep  $IP:2049
echo ""
cp -rvf /etc/exports{,-${LOG}-`date +%F`.bak}
}

linuxrpm() {
rpm -qa | sort -u > "/var/tmp/precheck/RPM-${LOG}-$HOSTNAME-$(date +%Y-%m-%d).txt"
echo ""
}

linuxerror() {
echo "Error Logs"
echo "-----------"
echo ""
grep -i FATAL /var/log/messages | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
grep -i ERROR /var/log/messages | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
echo ""
echo "Dmesg Logs"
echo "----------"
echo ""
dmesg | grep -i fail | sed -e "s/[0-9]/0/g" | sort | uniq
dmesg | grep -i error | sed -e "s/[0-9]/0/g" | sort | uniq
}

linuxstuff() {
echo ""
echo "CRONTAB LIST"
echo "------------"
crontab -l
echo ""
echo ""
echo "SYSCTL"
echo "-------"
sysctl -a 
echo ""
echo ""
echo "SYSCTL TCP"
echo "----------"
sysctl -a | grep -i TCP
echo ""
echo ""
echo "ULIMIT SETINGS"
echo "---------------"
ulimit -a
echo ""
echo ""
echo "IPTABLES INFORMATION"
echo "--------------------"
iptables -L
echo ""
echo "VAS TOOL STATUS"
echo "---------------"
sh +x /opt/quest/libexec/vas/scripts/vas_status.sh
echo "LOGIN DEFS"
echo "-----------"
cat /etc/login.defs 
echo ""
echo ""
echo "NSSWITCH OUTPUT"
echo "---------------"
cat /etc/nsswitch.conf
echo ""
echo ""
echo "SECQURITY LIMITS CONF"
echo "---------------------"
cat /etc/security/limits.conf
echo ""
echo ""
}

linuxmount() {
mkdir $TMPMNT
mount $IIP:$SOURCEMNT $TMPMNT
if [[ 0 -eq $? ]] ; then
	echo "Copied PRE/POST Check Report to 10.19.229.141:/PRECHECK Folder"
	echo "----------------------------------------------------------"
	mkdir -p $TMPMNT/$HOSTNAME
	cp -f $OUTPUTFILE /var/tmp/precheck/RPM-${LOG}-$HOSTNAME-$(date +%Y-%m-%d).txt  $TMPMNT/$HOSTNAME
	if [[ 0 -eq $? ]] ; then
		umount $TMPMNT
		else
		echo "+++++++++++++++++++++++++++++"
        echo "COPY error on $TMPMNT"
        echo "+++++++++++++++++++++++++++++"
        fi
else
	echo "PRE/POST Check script not copied"
	echo "--------------------------------"
fi

}

linuxback() {
echo "BACKUP FILES"
echo "------------"
cp -rvf /etc/fstab /etc/fstab-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/resolv.conf /etc/resolv.conf-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/login.defs /etc/login.defs-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/sysconfig/network /etc/sysconfig/network-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/sysconfig/network-scripts /etc/sysconfig/network-scripts-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/pam.d/ /etc/pam.d-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/profile /etc/profile-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/hosts /etc/hosts-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/sysctl.conf /etc/sysctl.conf-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg-${LOG}-$(date +%Y-%m-%d)
cp -rvf /etc/cluster/cluster.conf /etc/cluster/cluster.conf-${LOG}-$(date +%Y-%m-%d)
}

#AIX
aixhost() {
echo ""
echo "HOST INFORMATION"
echo "----------------"
echo ""
uname -a
echo ""
oslevel -r
echo ""
echo ""
echo "UPTIME & USER INFO"
echo "------------------"
echo ""
/usr/bin/uptime
who
echo ""
}

#Disk Information
aixdisk() {
echo ""
echo "Filesystem Information"
echo "----------------------"
echo ""
lsdev -Cc disk 2>/dev/null
echo ""
echo "FILE SYSTEMS: "
echo "------------"
echo ""
df -k 2>1
echo ""
echo "FSTAB DETAILS:"
echo "--------------"
echo ""
cat /etc/filesystems
echo ""
echo "MOUNT DETAILS:"
echo "--------------"
echo ""
mount
echo ""
echo "IOSTAT DETAILS:"
echo "---------------"
echo ""
iostat
echo ""
echo "LIST Disk DETAILS:"
echo "------------------"
echo ""
for HOST in $(lsvg); do lsvg -l $HOST ; done
echo ""
echo "LIST ALL ACTIVE VG's"
echo "---------------------"
echo ""
for HOST in $(lsvg -o); do lsvg -l $HOST ; done
echo ""
echo "" ; echo ""
lscfg -vpl hdisk*
echo ""
}

#HArdware Information
aixhardware() {
echo ""
echo "Hardware Information"
echo "---------------------"
echo ""
echo "NUMBER OF CPU's:"
echo "----------------"
echo ""
prtconf |grep -i processor
echo ""
echo "MEMORY INFORMATION:"
echo "-------------------"
echo ""
prtconf -m
echo ""
echo ""
prtconf |grep -i memory
echo ""
lsattr -El sys0 -a realmem
echo ""
bootinfo -r
echo "HARDWARE INFORMATION:"
echo "----------------------"
echo ""
lscfg -v
echo ""
}

#NETWORK INFORMATION
aixnetwork() {
echo ""
echo "NETWORK INFORMATIONS"
echo "--------------------"
echo ""
echo ""
ifconfig -a
echo ""
echo ""
lsdev -Cc 
echo ""
echo "-------------------------"
echo ""
echo "ROUTES DETAILS:"
echo "--------------"
echo ""
netstat -rn
echo ""
echo "NETSTAT -S"
echo "------------"
echo ""
netstat -s
echo ""
echo "cat /etc/hosts "
echo "----------------"
cat /etc/hosts |sed -e '/^#/d'
echo ""
echo "cat /etc/resolv.conf"
echo "--------------------"
cat /etc/resolv.conf |grep -v search | sed -e '/^#/d'
echo " "
}



#Service List
aixservice()
{
echo ""
echo "SERVICE list"
echo "-------------"
echo ""
lssrc -a
echo "INSTALLED PACKAGES"
echo "------------------"
instfix -ia
echo ""
echo "Console Error Logs"
echo "------------------"
alog -o -t console
echo "NIM Error Logs"
echo "--------------"
alog -o -t nim
echo ""
echo "BOOT LOGS"
echo "---------"
alog -o -t boot
echo ""
grep -i FATAL /var/adm/ras | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
grep -i ERROR /var/adm/ras | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
echo ""
echo "Dmesg Logs"
echo "----------"
echo ""
errpt -a
}


#HP-UX
hpuxhost() {
echo ""
echo "HOST INFORMATION"
echo "----------------"
echo ""
uname -a
echo ""
cat /stand/kernrel
echo ""
echo ""
echo "UPTIME & USER INFO"
echo "------------------"
echo ""
/usr/bin/uptime
echo ""
who
echo ""
}

#Disk Information
hpuxdisk() {
echo ""
echo "Filesystem Information"
echo "----------------------"
echo ""
ioscan -knfC disk 2>/dev/null
echo ""
echo "FILE SYSTEMS: "
echo "------------"
echo ""
df -k 2>1
echo ""
echo "FSTAB DETAILS:"
echo "--------------"
echo ""
cat /etc/fstab
echo ""
echo "MOUNT DETAILS:"
echo "--------------"
echo ""
mount
echo ""
echo "IOSTAT DETAILS:"
echo "---------------"
echo ""
iostat
echo ""
echo "VXDG LIST DETAILS:"
echo "------------------"
echo ""
vxdg list
echo ""
echo "VXDISK -O ALLDGS LIST"
echo "----------------------"
echo ""
vxdisk -o alldgs list
echo ""
echo "VXPRINT -QHT"
echo "-------------"
echo ""
vxprint -qht
echo ""
}

#HArdware Information
hpuxhardware() {
echo ""
echo "Hardware Information"
echo "---------------------"
echo ""
echo "NUMBER OF CPU's:"
echo "----------------"
echo ""
print_manifest | grep -i Processor
echo ""
echo "MEMORY INFORMATION:"
echo "-------------------"
echo ""
print_manifest | grep -i memory
echo ""
echo "PRINT_MANIFEST INFORMATION:"
echo "---------------------------"
echo ""
print_manifest
echo ""
}

#NETWORK INFORMATION
hpuxnetwork() {
echo ""
echo "NETWORK INFORMATIONS"
echo "--------------------"
echo ""
echo ""
cat /etc/rc.config.d/netconf | grep -iv "#"
echo ""
echo "-------------------------"
lanscan -v
echo ""
echo "ROUTES DETAILS:"
echo "--------------"
echo ""
netstat -rn
echo ""
echo "NETSTAT -IN"
echo "------------"
echo ""
netstat -in
echo ""
echo "cat /etc/hosts "
echo "----------------"
cat /etc/hosts |sed -e '/^#/d'
echo ""
echo "cat /etc/resolv.conf"
echo "--------------------"
cat /etc/resolv.conf |grep -v search | sed -e '/^#/d'
echo ""
}

#Service List
hpuxservice()
{
echo ""
echo "Package list"
echo "---------------"
echo ""
swlist -l bundle
echo ""
swlist -l product
echo ""
swlist -l patch
echo ""
echo "Error Logs"
echo "-----------"
echo ""
grep -i FATAL /var/adm/syslog/syslog.log | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
grep -i ERROR /var/adm/syslog/syslog.log | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
echo ""
echo "Dmesg Logs"
echo "----------"
echo ""
dmesg | grep -i fail | sed -e "s/[0-9]/0/g" | sort | uniq
dmesg | grep -i error | sed -e "s/[0-9]/0/g" | sort | uniq
}

#Solaris Functions

#HOST INFORMATION
solarishost() {
echo ""
echo "HOST INFORMATION"
echo "----------------"
echo ""
uname -a
echo ""
echo ""
echo "UPTIME & USER INFO"
echo "------------------"
echo ""
/usr/bin/uptime
echo ""
who
echo ""
}

#Disk Information
solarisdisk() {
echo "Device Information"
echo "-------------------"
echo|format 2>/dev/null
echo ""
echo "IOSTAT DETAILS:"
echo "--------------\n"
iostat -Een
echo ""
echo "VXDG LIST DETAILS:"
echo "--------------------\n"
vxdg list
echo ""
echo "VXDISK -O ALLDGS LIST"
echo "----------------------\n"
vxdisk -o alldgs list
echo ""
echo "VXPRINT -QHT"
echo "------------\n"
vxprint -qht
echo ""
echo "FILE SYSTEMS: "
echo "-------------\n"
df -k 2>1
echo ""
echo "VFSTAB DETAILS:"
echo "---------------\n"
cat /etc/vfstab
echo ""
echo "MOUNT DETAILS:"
echo "---------------\n"
mount -p
echo "\n"
VFS=`cat /etc/vfstab | sed -e '/^#/d' | awk '{print $3}' | sed -e '/dev\/fd/d' -e '/-/d' -e '/proc$/d'`
echo "\nNumber of mounts listed in vfstab (minus proc and /dev/fs)"
df -k $VFS | sed -e '/^Filesystem/d' | wc -l
echo "\nNumber of mounts currently mounted (minus proc and /dev/fs)"
df -k | sed -e '/^Filesystem/d' -e '/proc/d' -e '/dev\/fd/d' | wc -l
echo "\n"
echo ""

}
#Solaris hardware
#
solarishardware() {
echo "hardware Information"
echo "--------------------"
echo ""
echo "NUMBER OF CPU's:"
echo "---------------\n"
psrinfo -p
echo ""
psrinfo -p -v
echo ""
echo "PRTDIAG DETAILS:"
echo "-----------------"
/usr/platform/`uname -m`/sbin/prtdiag -v
echo "\n"
if [ `uname -r` = "5.10" ]
then
echo ""
echo "WWN DETAILS:"
echo "------------"
fcinfo hba-port
echo
fmadm faulty
else
echo ""
echo "WWN DETAILS:"
echo "-------------"
for i in `cfgadm |grep fc-fabric|awk '{print $1}'`;
do
dev="`cfgadm -lv $i|grep devices |awk '{print $NF}'`"
wwn="`luxadm -e dump_map $dev` "
echo " $wwn "
done
if [ "$wwn" = "" ]
then
echo "NO WWN's FOUND"
fi
fi
echo ""
echo "EEPROM DETAILS:"
echo "----------------"
eeprom
}

#Network Information
solarisnetwork() {
echo "NETWORK INFORMATION"
echo "-------------------"
echo ""
echo "IFCONFIG INFO"
echo "-------------"
ifconfig -a
echo ""
echo "dladm show-dev"
echo "--------------"
dladm show-dev
echo ""
echo "dladm show-link"
echo "---------------"
dladm show-link
echo ""
echo "Routing Information"
echo "-------------------"
netstat -nr
echo ""
}
###Service
solarisservice()
{
echo "LISTING INETD.CONF"
echo "------------------"
echo ""
cat /etc/inet/inetd.conf | grep -v "#"
echo "LISTING ERRORS [IF/ANY]"
echo "-----------------------"
echo ""
grep -i FATAL /var/adm/messages | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
grep -i ERROR /var/adm/messages | cut -d' ' -f6- | sed -e "s/[0-9]/0/g" | sort | uniq
echo ""
echo "ONLINE Services"
echo "----------------"
svcs -a | grep -i online
echo ""
echo "OFFLINE Services"
echo "-----------------"
svcs -a | grep -i offline
echo ""
echo "DISABLED services"
echo "------------------"
svcs -a | grep -i disabled
echo "Maintanence Services"
echo "--------------------"
svcs -a | grep -i maintenance
echo ""
}


###PLATFORM INFORMATION###
case `uname` in
Linux)
echo "Generating system stats please wait (can take a few minutes on slow systems)"
echo ""
echo "File generated on `date`" > $OUTPUTFILE
echo ""
echo "Host Information . . . . . 10%"
linuxhost >> $OUTPUTFILE
echo "Disk Information . . . . . 20%"
linuxdisk >> $OUTPUTFILE
echo "Hardware Information . . . . . 30%"
linuxhardware >> $OUTPUTFILE
echo "Network Information . . . . . 35%"
linuxnetwork >> $OUTPUTFILE
echo "Cluster Information . . . . . 45%"
linuxcluster >> $OUTPUTFILE
echo "Other Information . . . . . 50%"
linuxstuff >> $OUTPUTFILE
echo "Service Information . . . . . 60%"
linuxservice >> $OUTPUTFILE
echo "RPM Information . . . . . 70%"
linuxrpm >> $OUTPUTFILE
echo "ERROR Information . . . . . 80%"
linuxerror >> $OUTPUTFILE
echo "Backup Information . . . . . 100%"
linuxback >> $OUTPUTFILE
echo ""
linuxmount 
echo "File generated at $OUTPUTFILE on `date`"
exit
;;
SunOS)
echo "Generating system stats please wait (can take a few minutes on slow systems)"
echo ""
echo "File generated on `date`" > $OUTPUTFILE
echo "Host  Information . . . . . 10%"
solarishost >> $OUTPUTFILE
echo "Disk  Information . . . . . 20%"
solarisdisk >> $OUTPUTFILE
echo "Hardware Information . . . . . 30%"
solarishardware >> $OUTPUTFILE
echo "Network  Information . . . . . 50%"
solarisnetwork >> $OUTPUTFILE
echo "Backup  Information . . . . . 75%"
solarisbackup >> $OUTPUTFILE
echo "Service  Information . . . . . 99%"
solarisservice >> $OUTPUTFILE
echo ""
echo "File generated at $OUTPUTFILE on `date`"
exit
;;
HP-UX)
echo "Generating system stats please wait (can take a few minutes on slow systems)"
echo ""
echo "File generated on `date`" > $OUTPUTFILE
echo "Host  Information . . . . . 10%"
hpuxhost >> $OUTPUTFILE
echo "Disk Information . . . . . 20%"
hpuxdisk >> $OUTPUTFILE
echo "Hardware Information . . . . . 30%"
hpuxhardware >> $OUTPUTFILE
echo "Network Information . . . . . 50%"
hpuxnetwork >> $OUTPUTFILE
echo "Backup Information . . . . . 75%"
hpuxbackup >> $OUTPUTFILE
echo "Service Information . . . . . 99%"
hpuxservice >> $OUTPUTFILE
echo ""
echo "File generated at $OUTPUTFILE on `date`"
exit
;;
AIX)
echo "Generating system stats please wait (can take a few minutes on slow systems)"
echo ""
echo "File generated on `date`" > $OUTPUTFILE
echo "Host  Information . . . . . 10%"
aixhost >> $OUTPUTFILE
echo "Disk  Information . . . . . 20%"
aixdisk >> $OUTPUTFILE
echo "Hardware Information . . . . . 30%"
aixhardware >> $OUTPUTFILE
echo "Network  Information . . . . . 50%"
aixnetwork >> $OUTPUTFILE
echo "Backup  Information . . . . . 75%"
aixbackup >> $OUTPUTFILE
echo "Service  Information . . . . . 99%"
aixservice >> $OUTPUTFILE
echo ""
echo "File generated at $OUTPUTFILE on `date`"
exit
;;
*)
exit 1
esac
