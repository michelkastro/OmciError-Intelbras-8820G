# Script para identificar e ressincronizar ONU com status Omcierror na OLT intelbras 8820G
#### Desenvolvido por Michel Fernando de Castro ####
_doações_ [paypal](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=lucianemoreira%40hotmail%2ecom&lc=BR&no_note=0&currency_code=BRL&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest).

Algumas requisições no sistema linux:

telnet expect

```
apt-get install telnet expect
```

Colocar o script shell em um servidor linux para executar a ação.

ex: /usr/local/etc/OmciErrorIntelbras.sh

Inserir a tarefa no cron do sistema 
```
*/20 **** root /usr/local/etc/OmciErrorIntelbras.sh "10.10.10.1" "usuario" "senha" "shell" > /dev/null
```

Como o terminal da OLT pode ser configurado, verifique o inicio do terminal na sua OLT e insira no "shell" da chamada do script, no meu caso "iSH>"

*/20 **** root /usr/local/etc/OmciErrorIntelbras.sh "10.10.10.1" "michel" "senha" "iSH>" > /dev/null

```ruby

*/20 -> tempo de executação do script

/usr/local/etc/OmciErrorIntelbras.sh -> arquivo shell

"10.10.10.1" -> ip da OLT 8820G - pode ser usada multiplas "10.10.10.1-10.10.10.2-10.10.10.3"

"usuario" -> login usuário da OTL

"senha" -> senha do usuário da OLT

"shell" -> exemplo "iSH>"

```
Obs: Script criado por necessidade.  
