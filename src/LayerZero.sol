// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {NonblockingLzApp} from './lzApp/NonblockingLzApp.sol';

/// @title a test implementation for Layer Zero
contract LayerZeroContract is NonblockingLzApp {
    uint public count;

    mapping(uint => bool) public acceptedChainIds;


    // ---------------
    // Errors
    // ---------------
    error UnknownChain(uint16 chainId);

    constructor() {
        count = 0;
    }

    /// @dev implement the lzSend, we're going to allow any dest chain id to be passed 
    function crossChainIncrement(
        uint16 _dstChainId
    ) public {
        if (!acceptedChainIds[_dstChainId]) revert UnknownChain(_dstChainId);

        // We do not send any data we only increment
        bytes _payload = bytes("");

        

        _lzSend(
            _dstChainId,
            _payload,
            _refundAddress,
            _zroPaymentAddress,
            _adapterParams
        );
    }
}
