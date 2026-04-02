#!/bin/bash

# Colours
GREEN="\e[0;32m"
RED="\e[0;31m"
BLUE="\e[0;34m"
YELLOW="\e[0;33m"
PURPLE="\e[0;35m"
CYAN="\e[0;36m"
GREY="\e[0;37m"

GREENBOLD="\e[0;32m\e[1m"
REDBOLD="\e[0;31m\e[1m"
BLUEBOLD="\e[0;34m\e[1m"
YELLOWBOLD="\e[0;33m\e[1m"
PURPLEBOLD="\e[0;35m\e[1m"
CYANBOLD="\e[0;36m\e[1m"
GREYBOLD="\e[0;37m\e[1m"

NC="\e[0m"

main_url="https://htbmachines.github.io/bundle.js"

function ctrl_c(){
  echo -e "\n\n${RED}[!] Saliendo...${NC}\n"
}

trap ctrl_c INT

showHelp() {
#  echo -e "\n${YELLOW}Uso:${NC}${GREY} $0 ${NC}${PURPLE}[OPTION]${NC}\n"
#  echo -e "  ${PURPLE}-h:${NC}${GREY} Muestra este mensaje de ayuda.${NC}"
#  echo -e "  ${PURPLE}-u:${NC}${GREY} Comprueba y descarga actualizaciones${NC}"
#  echo -e "  ${PURPLE}-d [dificultad]:${NC}${GREY} Muestra el listado de máquinas de la dificultad indicada${NC}"
#  echo -e "  ${PURPLE}-l:${NC}${GREY} Muestra el listado de máquinas disponibles${NC}"
#  echo -e "  ${PURPLE}-m [nombre]:${NC}${GREY} Muestra información de la máquina indicada${NC}"
#  echo -e "  ${PURPLE}-i [ip]:${NC}${GREY} Muestra el nombre de la máquina asociado a una IP${NC}"
#  echo -e "  ${PURPLE}-I:${NC}${GREY} Muestra el listado de IP's disponibles${NC}"
#  echo -e "  ${PURPLE}-y:${NC}${GREY} Muestra el enlace a YouTube con la resolución${NC}"
#  echo -e "  ${PURPLE}-s [sistema]:${NC}${GREY} Muestra el listado de máquinas con el sistema indicado${NC}"

  echo -e "\n${YELLOW}Uso:${NC}\n\t$0 ${CYAN}[OPCIONES]${NC}"
  echo -e "\n${YELLOW}Opciones básicas:${NC}\n"
  echo -e "\t${CYAN}-i ip${NC}\t\t\t${GREY}muestra el nombre de la máquina asociado a la IP${NC}"
  echo -e "\t${CYAN}-n nombre${NC}\t\t${GREY}muestra la información de la máquina indicada${NC}"
  echo -e "\t${CYAN}-y nombre${NC}\t\t${GREY}muestra el enlace a la resolución de la máquina${NC}"

  echo -e "\n${YELLOW}Opciones de listado:${NC}\n"
  echo -e "\t${CYAN}-d dificultad${NC}\t\t${GREY}muestra las máquinas de la dificultad indicada${NC}"
  echo -e "\t${CYAN}-I${NC}\t\t\t${GREY}muestra las IP's de las máquinas disponibles${NC}"
  echo -e "\t${CYAN}-N${NC}\t\t\t${GREY}muestra los nombres de máquinas disponibles${NC}"
  echo -e "\t${CYAN}-s sistema${NC}\t\t${GREY}muestra las máquinas con el SO indicado${NC}"

  echo -e "\n${YELLOW}Misc:${NC}\n"
  echo -e "\t${CYAN}-h${NC}\t\t\t${GREY}muestra este panel de ayuda${NC}"
  echo -e "\t${CYAN}-u${NC}\t\t\t${GREY}comprueba y descarga actualizaciones${NC}"
  exit 1
}

updateFiles(){

  # Si data.js no existe
  if [ ! -f data.js ];then
  
    # Lo descargamos
    echo -e "\n${YELLOW}[+]${NC} ${GREY}Descargando archivos...${NC}"
    curl -s $main_url | js-beautify > data.js
    code=$?

    # Evaluamos si el codigo de estado
    if [ $code -eq "0" ]; then
      echo -e "${YELLOW}[+]${NC} ${GREY}Archivos descargados con éxito${NC}"
    else
      echo -e "\n${RED}[!]${NC} ${GREY}Se produjo un error durante la descarga${NC}"
    fi

  # Si data.js existe
  else
    echo -e "\n${YELLOW}[+]${NC} ${GREY}Comprobando actualizaciones...${NC}"
    curl -s $main_url | js-beautify > data_temp.js
    code=$?

    if [ $code -ne "0" ]; then
      echo -e "\n${RED}[!]${NC} ${GREY} Error al comprobar actualizaciones.${NC}"
    else
      md5data=$(md5sum data.js | awk '{print $1}')
      md5data_temp=$(md5sum data_temp.js | awk '{print $1}')
      if [ $md5data == $md5data_temp ]; then
        rm data_temp.js
        echo -e "${YELLOW}[+]${NC} ${GREY}No hay actualizaciones disponibles.${NC}"
      else
        echo -e "${YELLOW}[+]${NC} ${GREY}Se han encontrado actualizaciones.${NC}"
        sleep 1
        mv data_temp.js data.js
        echo -e "${YELLOW}[+]${NC} ${GREY}Archivos actualizados con éxito.${NC}"
      fi
    fi

  fi
}

searchMachine(){
  machineName="$1"

  valueFromFile=$(cat data.js \
    | awk "BEGIN {IGNORECASE = 1}; /name: \"${machineName}\"/,/resuelta:/" \
    | grep -vE "id:|sku:|resuelta:" \
    | tr -d '",' \
    | sed 's/^ *//g')
  
  if [ "$valueFromFile" ]; then

    echo -e "\n${YELLOW}[+]${NC} ${GREY}Recopilando información...${NC}"

    # echo -e "$valueFromFile"
    output=""
    while read line; do
      
      field=$(echo $line | cut -d':' -f1)
      fieldValue=$(echo $line | cut -d':' -f2-)

      output+="${CYAN}${field}:${NC}${GREY}${fieldValue}${NC}\n"

    done <<< $valueFromFile

    echo -e "${YELLOW}[+]${NC} ${GREY}Detalle de la consulta:${NC}\n"
   
    echo -e $output

  else

    echo -e "\n${RED}[!] No se encontró información sobre la máquina ${machineName}${NC}.\n"
  fi
}

searchIP(){
  ipAddress="$1"

  valueFromFile=$(cat data.js \
    | grep "ip: \"${ipAddress}\"" -B10 \
    | grep "name:" \
    | awk '{print $2}' \
    | tr -d '",')

  
  if [ "$valueFromFile" ]; then

    echo -e "\n${YELLOW}[+]${NC} ${GREY}La IP ${NC}${GREEN}${ipAddress}${NC} \
${GREY}corresponde a la máquina ${NC}${GREEN}${valueFromFile}${NC}${GREY}.${NC}\n"

  else

    echo -e "\n${RED}[!] No se encontró ninguna máquina con la IP ${ipAddress}${NC}.\n"
  fi
}

getYouTubeLink(){
  machineName="$1"

#cat data.js | awk "/name: \"Mischief\"/, /youtube: /" | awk 'END{print $NF}' | tr -d '",'
  valueFromFile=$(cat data.js | awk "/name: \"${machineName}\"/, /youtube: /" | awk 'END{print $NF}' | tr -d '",')

  if [ "$valueFromFile" ]; then
    echo -e "\n${YELLOW}[+]${NC} ${GREY}Enlace a la resolución de ${NC}${GREEN}$machineName${NC}${GREY}:${NC}\n\t$valueFromFile"
  else
    echo -e "\n${RED}[!] No se encontró información sobre la máquina ${machineName}${NC}.\n"
  fi

}

listMachines(){

  valueFromFile=$(cat data.js | grep "dificultad: " -B6 | awk '/name: / {print $NF}' | tr -d '",' | sort | column)
  
  if [ "$valueFromFile" ]; then

    echo -e "\n${YELLOW}[+]${NC} ${GREY}Listado de ${CYAN}máquinas${NC} disponibles para consultar:${NC}\n"
    echo -e "$valueFromFile" | more -n 15

  else

    echo -e "${RED}[!] No se encontraron máquinas.${NC}"

  fi

}

listIPs(){

  valueFromFile=$(cat data.js | grep "dificultad: " -B6 | awk '/ip: / {print $NF}' | tr -d '",' | sort | column)
  
  if [ "$valueFromFile" ]; then

    echo -e "\n${YELLOW}[+]${NC} ${GREY}Listado de ${CYAN}IP's${NC} disponibles para consultar:${NC}\n"
    echo -e "$valueFromFile" | more -n 15

  else

    echo -e "${RED}[!] No se encontraron IP's.$OPTARG{NC}"

  fi

}

searchByLevel(){

  machineLevel="$1"
  valueFromFile=$(cat data.js \
    | grep "dificultad: \"${machineLevel}\"" -B6 \
    | awk '/name: / {print $NF}' \
    | tr -d '",')

  if [ "$valueFromFile" ]; then

    echo -e "$valueFromFile" | sort | column 

  else

    echo -e "${RED}[!] No se encontraron máquinas de dificultad ${machineLevel}.${NC}"

  fi

}

searchBySystem(){
 
  machineSystem="$1"
  
  valueFromFile=$(cat data.js \
    | grep "so: \"${machineSystem}\"" -B5 \
    | awk '/name: / {print $NF}' \
    | tr -d '",')

  if [ "$valueFromFile" ]; then

    echo -e "$valueFromFile" | sort | column 

  else

    echo -e "${RED}[!] No se encontraron máquinas con sistema ${machineSystem}.${NC}"

  fi

}

# cat data.js | grep "dificultad: \"Fácil\"" -B7 | grep "so: \"Windows\"" -B6 | awk '/name: / {print $NF}' | tr -d '",' | column

while getopts "d:uNn:i:y:hIs:" arg; do
  case $arg in
    d) machineLevel=$OPTARG;; # searchByLevel $OPTARG;;
    N) listMachines;;
    u) updateFiles;;
    n) searchMachine $OPTARG;;
    h) showHelp;;
    i) searchIP $OPTARG;;
    I) listIPs;;
    y) getYouTubeLink $OPTARG;;
    s) machineSystem=$OPTARG;; # searchBySystem $OPTARG;;
  esac
done

searchByLevelAndSystem(){
  
  valueFromFile=$(cat data.js | grep "dificultad: \"${machineLevel}\"" -B7 | grep "so: \"${machineSystem}\"" -B6 | awk '/name: / {print $NF}' | tr -d '",' | column)

  if [ "$valueFromFile" ]; then

    echo -e "$valueFromFile" 

  else

    echo -e "${RED}[!] No se encontraron máquinas con sistema ${machineSystem} y dificultad ${machineLevel}.${NC}"

  fi


}


if [ -n "$machineLevel" ] && [ -n "$machineSystem" ]; then

  searchByLevelAndSystem $machineLevel $machineSystem

elif [ -n "$machineLevel" ]; then

  searchByLevel $machineLevel

elif [ -n "$machineSystem" ]; then

  searchBySystem $machineSystem

fi
