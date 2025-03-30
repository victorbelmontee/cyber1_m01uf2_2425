#!/bin/bash

PORT=7777
IP_CLIENT="localhost"

echo "LSTP Server(Lechuga Speaker Transfer Protocol)"

echo "0. LISTEN"

DATA=`nc -l $PORT`

echo "3. CHECK HEADER"

HEADER=`echo "$DATA" | cut -d " " -f 1`


if [ "$HEADER" != "LSTP_1" ]
then
	echo "ERROR 1: Header mal formado $DATA"
	
	echo "KO_HEADER" | nc $IP_CLIENT $PORT

	exit 1
fi


IP_CLIENT=`echo $DATA | cut -d " " -f 2`

echo "4. SEND OK_HEADER"

echo "OK_HEADER" | nc $IP_CLIENT $PORT

echo "5. LISTEN FILE_NAME"

DATA=`nc -l $PORT`

echo "9. CHECK FILE_NAME"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "ERROR 2: FILE_NAME mal formado $DATA"

	echo "KO_FILE_NAME" | nc $IP_CLIENT $PORT

	exit 2
fi

FILE_NAME=`echo $DATA | cut -d " " -f 2`

echo "10. SEND OK_FILE_NAME"

echo "OK_FILE_NAME" | nc $IP_CLIENT $PORT

echo "11. LISTEN FILE DATA"

nc -l $PORT > server/$FILE_NAME

echo "14. SEND KO/OK_FILE_DATA"

DATA=`cat server/$FILE_NAME | wc -c`

if [ $DATA -eq 0 ]
then
	echo "ERROR 3: Datos mal formados (vacíos)"
	echo "KO_FILE_DATA" | nc $IP_CLIENT $PORT

	exit 3
fi

echo "OK_FILE_DATA" | nc $IP_CLIENT $PORT

echo "15. LISTEN FILE_MD5"

DATA=`nc -l $PORT`

PREFIX=`echo $DATA | cut -d " " -f 1`
echo "17. CHECK FILE_DATA_MD5"
if [ "$PREFIX" != "FILE_DATA_MD5" ]
then
	
	echo "ERROR 4: FILE_DATA_MD5 mal formado: $DATA"
	echo "KO_FILE_DATA_MD5"

	exit 4

fi

echo "18. SEND KO/OK_FILE_DATA_MD5"
MD5_CLIENT=`echo $DATA | cut -d " " -f 2`
MD5_SERVER=`cat server/lechuga.ogg | md5sum | cut -d " " -f 1`

if [ "$MD5_CLIENT" != "$MD5_SERVER" ]
then

	echo "ERROR 5: MD5_HASH incorrecto: $MD5_CLIENT"
	echo "KO_FILE_DATA_MD5"


elif [ "$MD5_CLIENT" = "$MD5_SERVER" ]
then
	
	echo "OK_FILE_DATA_MD5" | nc $IP_CLIENT $PORT

fi


echo "Fin"
exit 0

