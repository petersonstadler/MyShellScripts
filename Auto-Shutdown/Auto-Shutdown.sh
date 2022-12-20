#!/bin/bash

####################################################
#
#AUTOR: PETERSON SIQUEIRA STADLER
#
#
#ESTE SCRIPT FOI ESCRITO COM O OBJETIVO DE
#MONITORAR A CPU E A MEMÓRIA UTILIZADA PELO
#PROGRAMA COM MAIOR USO DE RECURSO DO SISTEMA
#OU SEJA, A PRIMEIRA LINHA LISTADA NO COMANDO
#TOP. CASO SEJA MENOR QUE [X%] O SISTEMA DESLIGA 
#AUTOMATICAMENTE.
#ENQUANTO UM PROGRAMA USAR MEMÓRIA OU CPU MAIOR 
#QUE [X%] O SISTEMA MANTERÁ 15 MINUTOS PARA DESLIGAR.
#ASSIM QUE O USO DE MEMORIA FOR MENOR QUE [X%] O
#SISTEMA IRA DIMINUIR MINUTO A MINUTO ATÉ 0 E
#ENTÃO IRÁ DESLIGAR.
####################################################

CPU=30
MEM=30
MIN_USE=20 #MINIMO DE USO DE CPU E MEMORIA PARA PERMANECER LIGADO (X%)
MIN_CONT=8 #MINUTOS DE BONUS PARA PERMANCER LIGADO ENQUANTO ESTIVER USANDO O SISTEMA
MAX_CONT=8
CURRENT_USER=$(who | grep peterson | tr -s ' ' | cut -d ' ' -f1)

coletar_processos(){
    export CURRENT_USER=$(who | grep peterson | tr -s ' ' | cut -d ' ' -f1)
    TOP=$(top -b -n1 | sed -n '8p' | tr -s ' ')
    export CPU=$(echo $TOP | cut -d ' ' -f9 | cut -d ',' -f1)
    export MEM=$(echo $TOP | cut -d ' ' -f10 | cut -d ',' -f1)
    echo "CPU: $CPU %" - "Memória: $MEM %" '|' "desligar em: $MIN_CONT minutos | Usuário: $CURRENT_USER"
}

count_change(){
    if [[ $CURRENT_USER != "peterson" ]]; then
        if [ $CPU -lt $MIN_USE ] && [ $MEM -lt $MIN_USE ]; then
            export MIN_CONT=$((MIN_CONT-1))
        else
            if [ $MIN_CONT -lt $MAX_CONT ]; then
                export MIN_CONT=$((MIN_CONT+1))
            fi
        fi
    else
        if [ $MIN_CONT -lt $MAX_CONT ]; then
            export MIN_CONT=$((MIN_CONT+1))
        fi
    fi
}

verifica_shutdown(){
    if [ $MIN_CONT -lt 1 ]
    then
        echo "Desligando sistema..."
        sudo shutdown -h now
    fi
}

while true
do
    coletar_processos
    count_change
    verifica_shutdown
    sleep 60
done