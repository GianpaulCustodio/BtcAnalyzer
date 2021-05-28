#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function helpPanel(){
	echo -e "\n${redColour}[.] Realizado por: ${endColour} ${greenColour}HackeMate${endColour}"
	for i in {0..80}; do echo -ne "${purpleColour}-"; done; echo -ne "${endColour}\n";
	echo -e "\t${yellowColour}[-e] ${endColour} ${grayColour}\tElefante${endColour}"
	echo -e "\t${yellowColour}[-h] ${endColour} ${grayColour}\tMenú de ayuda${endColour}"
}

function elefante(){
	echo "Holaa"
}


counter=0;
while getopts "e:h" arg; do
	case $arg in
		e)elefante;let counter+=1;;
		h)helpPanel;;
	esac
done

if [ $counter -eq 0 ]; then
	helpPanel
else
	if [ $elefante == "elefante"]; then
		elefante
	fi
fi
