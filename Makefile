# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean install update build

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_13

# Clean the repo
clean  :; forge clean

# Install the Modules
install :; forge install

# Update Dependencies
update:; forge update

# Builds
build  :; forge build

# chmod scripts
scripts :; chmod +x ./scripts/*

# execute script on optimism or arbitrum testnets
run-optimism-test :; forge script --rpc-url https://kovan.optimism.io \
	scripts/Stargate.s.sol:StargateScriptOptimismKovan \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	-vvvv

run-arbitrum-test :; forge script --rpc-url https://rinkeby.arbitrum.io/rpc \
	scripts/Stargate.s.sol:StargateScriptArbitrum \
	--private-key ${PRIVATE_KEY} \
	--broadcast \
	-vvvv


# execute on a mainnet fork
run-mainnet :; forge script --fork-url https://rpc.ankr.com/eth \
	--private-key ${PRIVATE_KEY} \
	scripts/Stargate.s.sol:StargateScriptMainnet \
	-vvvv

# env var check
check-env :; echo $(PRIVATE_KEY)


