#!/bin/bash
#Criado por Michel Fernando de Castro
#e-mail: michelfdecastro@gmail.com
#https://github.com/michelkastro/OmciError-Intelbras-8820G


if [ -z ${1} ] || [ -z ${2} ] || [ -z ${3} ] || [ -z ${4} ]; then
	echo "Por favor, informe corretamente todos os dados..."
	echo 'Usage example: ./OmciErrorIntelbras "172.20.10.2" "usuário" "senha" "iSH>"'
	exit 1
fi

olts=$( echo "$1" | tr '-' ' ')

hosts=($olts)
user=$2
pass=$3
cmd=$4

conectOlt()
{
CONNECT=$(
expect -c " 
        set timeout 160
        spawn telnet "$u"
        expect \"login:\" 
        send \"$user\n\"
        expect \"password:\"
        send \"$pass\n\"
        expect \"$cmd \"
        send \"onu status\n\"
        expect \"Do you want to continue*\"
        send \"y\n\"
        #sleep 140
        expect \"*quit*\"
        send \"A\n\"
        expect \"$cmd \"
        send \"exit\"
        ")

}

resyncOnu()
{
ONUERROR=$(
            expect -c " 
            set timeout 35
            spawn telnet "$u"
            expect \"login:\" 
            send \"$user\n\"
            expect \"password:\"
            send \"$pass\n\"
            expect \"iSH> \"
            send \"onu resync $line\n\"
            sleep 5
            expect \"iSH> \"
            send \"exit\"
            ")
}

for u in "${hosts[@]}"
do
echo "Efetuando buscas na OLT $u com OmciError 2m30s aprox"

conectOlt $u

ONU=$(
while IFS= read -r line
do
   Omci=$(echo $line) 

      OmciError=$( echo $Omci | sed -n '/OmciError/p' |  awk '{print $3}' | sed 's/\-/\//g' | cut -c 3-10 | tr -d ' ')

   if [ ! -z "$OmciError" ]
      then
            echo $OmciError 
      fi
 done < <(printf '%s\n' "$CONNECT")
)

      if [ -z "$ONU" ]
            then
                  echo "Não foram encontradas ONU com status OmciError"
		logger -s "Sem OmciError $u" 2>> /var/log/OmciError.log
            else
                  while IFS= read -r line
                  do
                        echo "Efetuando resync na ONU " $line
                        resyncOnu $line
                        logger -s "Resync Onu $line na OLT $u" 2>> /var/log/OmciError.log

                  done < <(printf '%s\n' "$ONU")
      fi

done


    





