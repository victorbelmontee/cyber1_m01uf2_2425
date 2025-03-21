#!/bin/bash


if [ $# -ne 1 ]
then
	echo "Error: El comando requiere al menos un parámetro"

	echo "Ejemplo de uso:"
	echo -e "\t$0 127.0.0.1"
	
	exit 100
fi

PORT=7777
IP_SERVER=$1
IP_CLIENT=`ip a | grep -i inet | grep -i global | awk '{print $2}' | cut -d "/" -f 1 | head -n 1`

WORKING_DIR="client/"


echo "LSTP Client (Lechuga Speaker Transfer Protocol)"

echo "1. SEND HEADER (Client: $IP_CLIENT, Server: $IP_SERVER)"

echo "LSTP_1 $IP_CLIENT" | nc $IP_SERVER $PORT

echo "2. LISTEN OK_HEADER"

DATA=`nc -l $PORT`

echo "6. CHECK OK_HEADER"

if [ $DATA != "OK_HEADER" ]
then
	echo "ERROR 1: Header enviado incorrectamente" 

	exit 1

fi

#cat client/lechuga1.lechu | text2wave -o client/lechuga1.wav

#yes | ffmpeg -i client/lechuga1.wav client/lechuga1.ogg

echo "7.1 SEND NUM_FILES"

NUM_FILES=`ls client/*.lechu | wc -l`

echo "NUM_FILES $NUM_FILES" | nc $IP_SERVER $PORT

DATA=`nc -l $PORT`

echo "7.2 CHECK OK_NUM_FILES"

if [ "$DATA" != "OK_NUM_FILES" ]
then

	echo "ERROR 21: NUM_FILES Enviado incorrectamente"
	exit 21

fi

echo "7.3 SEND_FILES"


for FILE_NAME in `ls client/*.lechu`
do


echo "7.X SEND FILE_NAME"

echo "FILE_NAME lechuga.ogg" | nc $IP_SERVER $PORT

echo "8. LISTEN"

DATA=`nc -l $PORT`

if [ "$DATA" != "OK_FILE_NAME" ]
then

	echo "ERROR 2: FILE_NAME enviado incorrectamente"

	exit 2

fi

echo "12. SEND FILE DATA"

cat lechuga.ogg | nc $IP_SERVER $PORT

echo "13. LISTEN OK/KO_FILE_DATA"

DATA=`nc -l $PORT`

if [ "$DATA" != "OK_FILE_DATA" ]
then

	echo "ERROR 3: Error al enviar los datos"
	exit 3

fi


echo "16. SEND FILE_DATA_MD5"

MD5=`cat lechuga.ogg | md5sum | cut -d " " -f 1`

echo "FILE_DATA_MD5 $MD5" | nc $IP_SERVER $PORT

echo "19. LISTEN OK_FILE_DATA_MD5"

DATA=`nc -l $PORT`

if [ $DATA != "OK_FILE_DATA_MD5"  ]
then
	echo "ERROR 4: Error al enviar el hash md5"
	exit 4

fi

done
