#!/bin/bash

# Usage of this file
# ARG1: besu/ganache
# ARG2: Absolute path of tcf_connector.toml file
# ARG3: Absolute path of startup.sh script incase of ganache

if [ $1 = "ganache" ] || [ $1 = "besu" ]; then
	echo "The configuration selected is $1"
else
	echo "Please provide the configuration either as 'besu' or 'ganache'"
	exit 1
fi

if [[ $1 == "ganache" ]]; then
	lineNo=$(($(grep -n "trufflesuite/ganache-cli" $3/startup.sh | grep -Eo '^[^:]+')+1))

	sed ${lineNo}'i--account="0x38dfdb0acb3e0beb096af5efe927cf2bb3bc73bc0ec1cbad9d5506cf3b16ef2d,100000000000000000000" \\' $3/startup.sh > $3/startup_tmp.sh
	mv $3/startup_tmp.sh $3/startup.sh

	a=$(sed -n '/^worker_registry_contract_address =/=' $2)
	sed -i "${a}s/.*/worker_registry_contract_address = \"0x785C11b9b4636B1afDc5dfB4b02dC9749b287705\"/" $2

	a=$(sed -n '/^work_order_contract_address =/=' $2)
	sed -i "${a}s/.*/work_order_contract_address = \"0xdF38be8C1A45A12c00ddE9CEB4F25CeC289FA733\"/" $2

	a=$(sed -n '/^eth_account =/=' $2)
	sed -i "${a}s/.*/eth_account = \"0xa525fB2e3fEaCC5716B89119cB84faB2B3793BDc\"/" $2

	a=$(sed -n '/^provider =/=' $2)
	sed -i "${a}s/.*/provider = \"http\:\/\/local-ganache\:8545\"/" $2

	a=$(sed -n '/^event_provider =/=' $2)
	sed -i "${a}s/.*/event_provider = \"http\:\/\/local-ganache\:8545\"/" $2

elif [[ $1 == "besu" ]]; then
	a=$(sed -n '/^worker_registry_contract_address =/=' $2)
        sed -i "${a}s/.*/worker_registry_contract_address = \"0x75a3Fd17E8c5CceAa9121251c359bFe4b9C343C8\"/" $2

	a=$(sed -n '/^work_order_contract_address =/=' $2)
        sed -i "${a}s/.*/work_order_contract_address = \"0xf873133fae1d1f80642c551a6edd5A14f37129c2\"/" $2

        a=$(sed -n '/^eth_account =/=' $2)
        sed -i "${a}s/.*/eth_account = \"0x7085d4d4c6efea785edfba5880bb62574e115626\"/" $2
fi
