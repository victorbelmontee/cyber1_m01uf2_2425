#!/bin/bash
NUM_FILES_CHECK=`echo $1` | grep -E "^-?[0-9]+$"

if [ "$NUM_FILES_CHECK" == "" ]
then
	echo "ERROR 22: Numero de archivos incorrecto (no es un numero)"
	exit 22
fi




echo "Es un número: $1"
