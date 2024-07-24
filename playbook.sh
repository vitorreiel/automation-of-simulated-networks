#!/bin/bash

echo -e "\n\033[1;32m- [ Checando Dependências e Atualizações. ] \033[0m\n"
sudo apt update -y > /dev/null 2>&1
sudo apt install git python3 python3-pip ansible -y > /dev/null 2>&1
pip install boto3 ansible-core==2.16.0 Jinja2==3.1.3 urllib3==1.26.5 > /dev/null 2>&1
ansible-galaxy collection install community.aws > /dev/null 2>&1
echo -e "\033[1;32m- [ Dependências instaladas com Sucesso! ] \033[0m\n"

#echo -e "\n\033[1;34m- [ Iniciando Processo de Automatização de Redes Simuladas ] \033[0m"

aws_access_key=$(awk -F= '/aws_access_key_id/ && !/^#/ {print $2}' aws_access)
aws_secret_key=$(awk -F= '/aws_secret_access_key/ && !/^#/ {print $2}' aws_access)
aws_session_token=$(awk -F= '/aws_session_token/ && !/^#/ {sub(/aws_session_token=/, ""); print}' aws_access)
arquivo_destino="playbook-automated-networks/vars/main.yaml"
script_destino="playbook-automated-networks/utils/network-components/start.sh"
key_destino="playbook-automated-networks/credentials/keypair.pem"

#clear
echo -e "\n\033[1;33m- [ Atenção: É necessário que sua conta AWS Academy esteja iniciada! ] \033[0m"
sleep 1
echo -e '\n\033[1;33m- [ Atenção: É necessário que tenha colocado sua AWS CLI no arquivo "aws_access". ] \033[0m\n'
sleep 1
echo -e "\n\033[1;36m- [ Digite: 1 - Para iniciar o processo criação automatizada de rede emulada. ] \033[0m"
sleep 1
echo -e "\n\033[1;31m- [ Digite: 2 - Para deletar um cenário de rede emulada já existente. ] \033[0m\n"
read confirmacao

if [ "$confirmacao" = "1" ] || [ "$confirmacao" = "01" ]; then

  clear
  echo -e "\n\033[1;32m- [ Digite apenas o número correspondente a topologia desejada! ] \033[0m\n"
  sleep 1
  echo -e "\n\033[1;34m- [ 1 ] : Topologia de Rede Anel ] \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 2 ] : Topologia de Rede Árvore ] \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 3 ] : Topologia de Rede Estrela ] \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 4 ] : Topologia de Rede Malha ] \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 5 ] : Topologia de Rede Serial ] \033[0m\n"
  sleep 0.5
  read topologia

  if [ "$topologia" = "1" ] || [ "$topologia" = "01" ]; then

    echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
    awk -v new_value_1="$aws_access_key" 'NR == 2 {print "aws_access_key: " new_value_1} NR != 2' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_2="$aws_secret_key" 'NR == 3 {print "aws_secret_key: " new_value_2} NR != 3' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_3="$aws_session_token" 'NR == 4 {print "aws_session_token: " new_value_3} NR != 4' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/ring-topology+g" "$script_destino"
    ansible-playbook -i playbook-automated-networks/hosts playbook-automated-networks/playbook.yaml
    ip=$(awk '/ansible_host/ {match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); print substr($0, RSTART, RLENGTH)}' playbook-automated-networks/hosts)
    ssh -i "$key_destino" ubuntu@"$ip"
  
  elif [ "$topologia" = "2" ] || [ "$topologia" = "02" ]; then
  
    echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
    awk -v new_value_1="$aws_access_key" 'NR == 2 {print "aws_access_key: " new_value_1} NR != 2' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_2="$aws_secret_key" 'NR == 3 {print "aws_secret_key: " new_value_2} NR != 3' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_3="$aws_session_token" 'NR == 4 {print "aws_session_token: " new_value_3} NR != 4' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/tree-topology+g" "$script_destino"
    ansible-playbook -i playbook-automated-networks/hosts playbook-automated-networks/playbook.yaml
    ip=$(awk '/ansible_host/ {match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); print substr($0, RSTART, RLENGTH)}' playbook-automated-networks/hosts)
    ssh -i "$key_destino" ubuntu@"$ip"

  elif [ "$topologia" = "3" ] || [ "$topologia" = "03" ]; then
  
    echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
    awk -v new_value_1="$aws_access_key" 'NR == 2 {print "aws_access_key: " new_value_1} NR != 2' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_2="$aws_secret_key" 'NR == 3 {print "aws_secret_key: " new_value_2} NR != 3' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_3="$aws_session_token" 'NR == 4 {print "aws_session_token: " new_value_3} NR != 4' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/star-topology+g" "$script_destino"
    ansible-playbook -i playbook-automated-networks/hosts playbook-automated-networks/playbook.yaml
    ip=$(awk '/ansible_host/ {match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); print substr($0, RSTART, RLENGTH)}' playbook-automated-networks/hosts)
    ssh -i "$key_destino" ubuntu@"$ip"

  elif [ "$topologia" = "4" ] || [ "$topologia" = "04" ]; then
  
    echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
    awk -v new_value_1="$aws_access_key" 'NR == 2 {print "aws_access_key: " new_value_1} NR != 2' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_2="$aws_secret_key" 'NR == 3 {print "aws_secret_key: " new_value_2} NR != 3' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_3="$aws_session_token" 'NR == 4 {print "aws_session_token: " new_value_3} NR != 4' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/mesh-topology+g" "$script_destino"
    ansible-playbook -i playbook-automated-networks/hosts playbook-automated-networks/playbook.yaml
    ip=$(awk '/ansible_host/ {match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); print substr($0, RSTART, RLENGTH)}' playbook-automated-networks/hosts)
    ssh -i "$key_destino" ubuntu@"$ip"

  elif [ "$topologia" = "5" ] || [ "$topologia" = "05" ]; then
  
    echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
    awk -v new_value_1="$aws_access_key" 'NR == 2 {print "aws_access_key: " new_value_1} NR != 2' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_2="$aws_secret_key" 'NR == 3 {print "aws_secret_key: " new_value_2} NR != 3' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_3="$aws_session_token" 'NR == 4 {print "aws_session_token: " new_value_3} NR != 4' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/serial-topology+g" "$script_destino"
    ansible-playbook -i playbook-automated-networks/hosts playbook-automated-networks/playbook.yaml
    ip=$(awk '/ansible_host/ {match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); print substr($0, RSTART, RLENGTH)}' playbook-automated-networks/hosts)
    ssh -i "$key_destino" ubuntu@"$ip"

  else

    echo -e "\n\033[1;33m- [ Não consegui entender o que quis dizer :( ] \033[0m"

  fi

elif [ "$confirmacao" = "2" ] || [ "$confirmacao" = "02" ]; then

  echo -e '\n\033[1;33m- [ Por favor, modifique o arquivo "aws_access" e inserindo toda sua AWS CLI. ] \033[0m'

else

  echo -e "\n\033[1;33m- [ Não consegui entender o que quis dizer :( ] \033[0m"

fi