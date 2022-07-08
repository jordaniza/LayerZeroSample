#!/bin/bash

# is the contract paused
cast call 0x2e05590c1b24469eaef2b29c6c7109b507ec2544 "paused()(bool)" --rpc-url "https://rpc.testnet.fantom.network"

# set the dest addr
cast send 0x2e05590c1b24469eaef2b29c6c7109b507ec2544 \
    "setDestLzEndpoint(address,address)" "0xb3b3b80828b4f30ddb338d768d19191e918d730c" "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8" \
    --rpc-url "https://rpc.testnet.fantom.network" \
    --private-key PK
