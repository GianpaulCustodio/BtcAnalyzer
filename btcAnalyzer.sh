#!/bin/bash

# Author: HackeMate 

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!]Saliendo ...\n${endColour}"
	rm ut.t* 2>/dev/null
	tput cnorm; exit 1;
}

function helpPanel(){
	echo -e "\n${redColour}[!] Uso: ./btcAnalyzer  -- Hecho por: HackeMate${endColour}"
	for i in {0..80}; do echo -ne "${redColour}-"; done; echo -ne "${endColour}\n"
	echo -e "\n\n\t${grayColour}[-e] ${endColour}${yellowColour}Modo exploración${endColour}\n"
	echo -e "\t\t${purpleColour}unconfirmed_transactions: ${endColour}\t${yellowColour}Listar Transacciones no confirmadas${endColour}"
	echo -e "\t\t${purpleColour}inspect: ${endColour}\t${yellowColour}\t\tInspeccionar un hash de transacción${endColour}"
	echo -e "\t\t${purpleColour}address: ${endColour}\t${yellowColour}\t\tInspeccionar una transacción de dirección${endColour}\n"
	echo -e "\t${grayColour}[-n] ${endColour} ${yellowColour}Delimitador de líneas ${endColour}${blueColour}(Ejemplo: -n 10)${endColour}"
	echo -e "\n\t${grayColour}[-h] ${endColour} ${yellowColour}Mostrar este panel de ayuda${endColour}\n"
	exit 1
}

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}




function unconfirmed_transactions(){

	number_output=$1

	echo "" > ut.tmp
	while [ "$(cat ut.tmp | wc -l)" == "1" ]; do
		curl -s "$unconfirmed_transactions" | html2text -utf8 > ut.tmp
	done
	hashes=$(cat ut.tmp | grep "Picadillo" -A 1 | grep -v -E "Picadillo|\--|Hora" | head -n $number_output)

	echo "Hash_Cantidad_Bitcoin_Tiempo" > ut.table

	for hash in $hashes; do
		echo "${hash}_$(echo "$ $(cat ut.tmp | grep "$hash" -A 6 | tail -1 | cut -d 'U' -f1)")_$(cat ut.tmp | grep "$hash" -A 4 | tail -1)_$(cat ut.tmp | grep "$hash" -A 2 | tail -1)" >> ut.table
	done
	printTable '_' "$(cat ut.table)" #2 Parametros:  _ ->El delimitador   $(cat ut.table) ->la tabla que necesita para que se genere los cuadros
	rm ut.t* 2>/dev/null
}




#Variables Globales
unconfirmed_transactions="https://www.blockchain.com/es/btc/unconfirmed-transactions"
inspect_transaction_url="https://www.blockchain.com/es/btc/tx/"
inspect_address_url="https://www.blockchain.com/es/btc/address/"

counter=0;
while getopts "e:h:n:" arg; do
	case $arg in
	e)exploration_mode=$OPTARG; let counter+=1;; #OPTARG es la variable que ponemos luego del -e |ejm: ./btcAnalyzer.sh -e loquesea
	h)helpPanel;;
	n)number_output=$OPTARG; let counter+=1;;
	esac
done

if [ $counter -eq 0 ]; then
	helpPanel
else
	if [ $exploration_mode == "unconfirmed_transactions" ]; then
		if [ ! "$number_output" ]; then
			number_output=100
			unconfirmed_transactions $number_output
		else
			unconfirmed_transactions $number_output
		fi
	fi
fi
