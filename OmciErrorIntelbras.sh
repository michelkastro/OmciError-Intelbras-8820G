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
data=$(date +%d/%m/%Y-%T)

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

echo "Salvando os dados..."

conectOlt $u

echo "$CONNECT" > /tmp/onu-$hosts

sed -n '/OmciError/p' /tmp/onu-$hosts > /tmp/onu-2$hosts

awk '{print $3}' /tmp/onu-2$hosts > /tmp/onu-3$hosts

sed 's/\-/\//g' /tmp/onu-3$hosts > /tmp/onu-4$hosts

onuerror=$(cat /tmp/onu-4$hosts)

        if [ -z "$onuerror" ]
            then
                echo "Não foram encontradas ONU com status OmciError"
		logger -s "Sem OmciError $u" 2>> /var/log/OmciError.log
                rm /tmp/onu-*$hosts
            else
                 while read p; do

                onuchek=$(echo "$p" | cut -c 3-10)
                echo "Efetuando o resync na onu $onuchek"
                        resyncOnu $onuchek
                        logger -s "Resync Onu $onuchek na OLT $u" 2>> /var/log/OmciError.log
                done </tmp/onu-4$hosts
        fi
rm /tmp/onu-*$hosts
done
