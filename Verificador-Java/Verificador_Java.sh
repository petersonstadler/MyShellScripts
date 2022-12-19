#!/bin/bash

echo $(date) - Iniciando Verificador... #>> verificador_log.txt

MAXMINUTE=30
count=$MAXMINUTE
echo $(date) - pegando PIDJAVA... #>> verificador_log.txt
PIDJAVA=$(top -b -n1 | grep java | tr -s " " | cut -d " " -f2)
echo $(date) - PIDJAVA: $PIDJAVA #>> verificador_log.txt


case $PIDJAVA in
    ''|*[!0-9]*) CONTINUAR=false;;
        *) CONTINUAR=true;;
esac

if [ $CONTINUAR == false ]; then
	echo $CONTINUAR
	echo $(date)" - Não foi possível capturar o ID!"
fi

while($CONTINUAR)
do
   sleep 60
   if [ $count -lt 1 ]; then
	echo $(date) - "Desligando..." #>> verificador_log.txt
	sudo shutdown -h now
	break
   fi
   CPUMINE=$(top -b -n1 -p $PIDJAVA | grep java | tr -s " " | cut -d " " -f10 | cut -d "," -f1)
   case $CPUMINE in
       ''|*[!0-9]*) break;;
        *) export break;;
   esac
   if [ $CPUMINE -lt 35 ]; then
	count=$(expr $count - 1)
   else
	if [ $count -lt $MAXMINUTE ]; then
		count=$(expr $count + 1)
	fi
   fi
   echo $(date) - PIDJAVA: $PIDJAVA \| process: $CPUMINE \| minutos: $count #>> verificador_log.txt
done
