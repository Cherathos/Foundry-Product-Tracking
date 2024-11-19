-include .env

build:; forge build

test:; forge test

deploy-sepholia:; forge script script/DeployContract.s.sol:DeployContract --rpc-url $(SEPHOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv