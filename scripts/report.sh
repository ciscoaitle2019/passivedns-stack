#!/bin/sh

AUTOMODE=$1
WORKFOLDER=$PWD
CURR_TIME=`date +%Y%m%d%H%M`

mkdir -p $WORKFOLDER/report
mkdir -p $WORKFOLDER/tmp
rm -rf $WORKFOLDER/tmp/*

if [ "$AUTOMODE" != "AUTO" ]; then
        echo "Download new suspicious domains list from dshield.org? Y/N"
        read YN
        if [ "$YN" = "y" ] || [ "$YN" = "Y" ] ; then
                wget http://www.dshield.org/feeds/suspiciousdomains_High.txt -O $WORKFOLDER/suspiciousdomains_High.txt
		wget https://www.dshield.org/feeds/suspiciousdomains_Low.txt -O $WORKFOLDER/suspiciousdomains_Low.txt
		wget https://www.dshield.org/feeds/suspiciousdomains_Medium.txt -O $WORKFOLDER/suspiciousdomains_Medium.txt
                wget https://zeustracker.abuse.ch/blocklist.php?download=baddomains -O $WORKFOLDER/zeusdomains.txt

                rm -rf $WORKFOLDER/FULLlistDomains.txt*
                touch $WORKFOLDER/FULLlistDomains.txt.tmp
                touch $WORKFOLDER/FULLlistDomains.txt
                cat $WORKFOLDER/*.txt |grep -v "#" >> $WORKFOLDER/FULLlistDomains.txt.tmp

                cat  $WORKFOLDER/FULLlistDomains.txt.tmp|sort|uniq >  $WORKFOLDER/FULLlistDomains.txt
        fi
fi

for DOMAIN in `cat $WORKFOLDER/FULLlistDomains.txt |grep -v "#"| awk -F, {'print $1'}`
do
        #echo $DOMAIN;
        SQL=""
        SQL=`mysql pdns -N -e "select * from pdns where QUERY='$DOMAIN' AND LAST_SEEN > DATE_SUB(NOW(), INTERVAL 7 day);"`
        if [ "$SQL" != "" ]; then
                echo $SQL | sed 's/ /,/g';
                echo "$DOMAIN"
                #Revised to 7 day log report only
                find /var/log/passivedns/ -type f -mtime -7 -exec zfgrep -h "||$DOMAIN.||" {} \; > $WORKFOLDER/tmp/$DOMAIN.log  
        fi
done
echo "###########" >> $PWD/report/$CURR_TIME
echo "pDNS Report" >> $PWD/report/$CURR_TIME
cat $WORKFOLDER/tmp/* |awk -F"|" {'print $3 , " " , $9'}|sort -n|uniq -c >> $PWD/report/$CURR_TIME

echo " " >> $PWD/report/$CURR_TIME
echo "###########" >> $PWD/report/$CURR_TIME
echo "Processed Data Report" >> $PWD/report/$CURR_TIME
find /var/log/passivedns/ -type f -mtime -7 -exec ls -lath {} \; >> $PWD/report/$CURR_TIME

echo "############"
echo "Please check the report file on $PWD/report/$CURR_TIME"
echo "############"
