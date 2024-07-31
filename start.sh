#!/bin/bash
aws_access_key=$(awk -F= '/aws_access_key_id/ && !/^#/ {print $2}' aws_access)
aws_secret_key=$(awk -F= '/aws_secret_access_key/ && !/^#/ {print $2}' aws_access)
aws_session_token=$(awk -F= '/aws_session_token/ && !/^#/ {sub(/aws_session_token=/, ""); print}' aws_access)

arquivo_destino="automated-networks/ansible-playbook/vars/main.yaml"
script_destino="automated-networks/utils/network-components/start.sh"
key_destino="automated-networks/ansible-playbook/credentials/keypair.pem"

echo -e "\n\033[1;33m- [ Atenção: É necessário que sua conta AWS Academy esteja iniciada! ] \033[0m"
sleep 1
echo -e '\n\033[1;33m- [ Atenção: É necessário que tenha colocado sua AWS CLI no arquivo "aws_access". ] \033[0m\n'
sleep 1
echo -e "\n\033[1;36m- [ Digite: 1 - Para iniciar o processo criação automatizada de rede emulada. ] \033[0m"
sleep 1
echo -e "\n\033[1;31m- [ Digite: 2 - Para deletar um cenário de rede emulada já existente. ] \033[0m\n"
read confirmacao

if [[ "$confirmacao" =~ ^(1|01)$ ]]; then

  echo -e "\n\033[1;32m- [ Qual ferramenta deseja utilizar para criação do cenário? Digite apenas o número! ] \033[0m\n"
  sleep 1
  echo -e "\n\033[1;34m- [ 1 ] : Ansible \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 2 ] : Terraform \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 3 ] : Chef \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 4 ] : Puppet \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 5 ] : Pulumi \033[0m\n"
  sleep 0.5
  read iac

  echo -e "\n\033[1;32m- [ Digite apenas o número correspondente a topologia desejada! ] \033[0m\n"
  sleep 1
  echo -e "\n\033[1;34m- [ 1 ] : Topologia de Rede Anel \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 2 ] : Topologia de Rede Árvore \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 3 ] : Topologia de Rede Estrela \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 4 ] : Topologia de Rede Malha \033[0m"
  sleep 0.5
  echo -e "\n\033[1;34m- [ 5 ] : Topologia de Rede Serial \033[0m\n"
  sleep 0.5
  read topologia

  case $topologia in
  1|01)
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/ring-topology+g" "$script_destino"
  esac

  case $topologia in
    2|02)
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/tree-topology+g" "$script_destino"
  esac

  case $topologia in
    3|03)
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/star-topology+g" "$script_destino"
  esac

  case $topologia in
    4|04)
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/mesh-topology+g" "$script_destino"
  esac

  case $topologia in
    5|05)
    sed -i "s+/topologies/[^[:space:]]*-topology+/topologies/serial-topology+g" "$script_destino"
  esac

  case $iac in
  1|01)
    echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
    sudo apt update -y > /dev/null 2>&1
    sudo apt install git python3 python3-pip ansible -y > /dev/null 2>&1
    pip install boto3 ansible-core==2.16.0 Jinja2==3.1.3 urllib3==1.26.5 > /dev/null 2>&1
    ansible-galaxy collection install community.aws > /dev/null 2>&1
    awk -v new_value_1="$aws_access_key" 'NR == 2 {print "aws_access_key: " new_value_1} NR != 2' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_2="$aws_secret_key" 'NR == 3 {print "aws_secret_key: " new_value_2} NR != 3' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    awk -v new_value_3="$aws_session_token" 'NR == 4 {print "aws_session_token: " new_value_3} NR != 4' "$arquivo_destino" > tmpfile && mv tmpfile "$arquivo_destino"
    echo -e "\033[1;32m- [ Dependências instaladas com Sucesso! ] \033[0m\n"
    ansible-playbook -i automated-networks/ansible-playbook/hosts automated-networks/ansible-playbook/playbook.yaml
    ip=$(awk '/ansible_host/ {match($0, /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); print substr($0, RSTART, RLENGTH)}' automated-networks/ansible-playbook/hosts)
    ssh -i "$key_destino" ubuntu@"$ip"
  esac

  case $iac in
  2|02)
    echo -e "\n\033[1;33m- [ Iniciando configurações da Infraestrutura. Aguarde! ] \033[0m\n"
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform > /dev/null 2>&1
  esac
fi