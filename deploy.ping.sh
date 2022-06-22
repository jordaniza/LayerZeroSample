#!/bin/bash

# Deploy the ping pong contracts to testnets

forge create --rpc-url "https://api.avax-test.network/ext/C/rpc" --etherscan-api-key "C87WPMH72BRVG9WV28CE88ZQMWEW5BPA4V" --constructor-args "0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706" --private-key "75ab1459912c33e7000673df77570b7693c1a033138f38167543d2dbe41f34ea" src/PingPong.sol:PingPong --verify

# forge create --rpc-url "https://rpc.testnet.fantom.network" --etherscan-api-key "JWZIY4C48D8725WUKIDZFNNSXR133AXTFK" --constructor-args "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf" --private-key "75ab1459912c33e7000673df77570b7693c1a033138f38167543d2dbe41f34ea" src/PingPong.sol:PingPong --verify


# forge verify-contract --chain-id 4002 \
#     --constructor-args $(cast abi-encode "constructor(address)" "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf") \
#     --compiler-version v0.8.13+commit.abaa5c0e \
#     "0xcb162b56427b0bff26a9b490781fdd2de03e283c" \
#     src/PingPong.sol:PingPong \
#     "JWZIY4C48D8725WUKIDZFNNSXR133AXTFK"


# forge create --rpc-url "https://rpc-mumbai.maticvigil.com" \
    # --constructor-args "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8" \
    # --private-key "75ab1459912c33e7000673df77570b7693c1a033138f38167543d2dbe41f34ea" \
    # src/PingPong.sol:PingPong

# forge verify-contract --chain-id 80001 \
#     --constructor-args $(cast abi-encode "constructor(address)" "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8") \
#     --compiler-version v0.8.13+commit.abaa5c0e \
#     --num-of-optimizations 200 \
#     "0xb3b3b80828b4f30ddb338d768d19191e918d730c" \
#     src/PingPong.sol:PingPong \
#     "PJZHDBQ8NR4S3SCHFY6C4D5SJUUD6C6MDG"

# Version: 0.8.13+commit.abaa5c0e.Linux.g++



# forge verify-check --chain-id 80001 "y2wvbgzg2qgt4ihmtlpygrcp9wk8avdxnv3mv9zcx52xjb2pu2" "PJZHDBQ8NR4S3SCHFY6C4D5SJUUD6C6MDG"

# forge verify-check --chain-id 80001 "spc44e4rkwkjnvdyubqwlb9vbnzvjnqtwgpw8kwfwd2up2tp2e" "PJZHDBQ8NR4S3SCHFY6C4D5SJUUD6C6MDG"


