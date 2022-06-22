// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {NonblockingLzApp} from './lzApp/NonblockingLzApp.sol';

/// @title a test implementation for Layer Zero
contract LayerZeroContract is NonblockingLzApp {
    uint public count;

    mapping(uint => bool) public acceptedChainIds;

    // ---------------
    // Errors
    // ---------------
    error UnknownChain(uint16 chainId);

    event Increment(uint qty);

    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        count = 0;
        acceptedChainIds[1] = true;
    }

    function ping() public pure returns (bool success) {
        return true;
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {
        uint qty = decode(_payload);
        count += qty;
        emit Increment(qty);
    }

   function decode(bytes memory data) public pure returns (uint b) {
        assembly {
            // Load the length of data (first 32 bytes)
            let len := mload(data)
            // Load the data after 32 bytes, so add 0x20
            b := mload(add(data, 0x20))
        }
    }    

    function crossChainIncrement(
        uint16 _dstChainId,
        uint _incrementQty
    ) public {
        if (!acceptedChainIds[_dstChainId]) revert UnknownChain(_dstChainId);

        // We do not send any data we only increment
        bytes memory _payload = abi.encodePacked(_incrementQty);
        
        // address to rebate any additional gas fees
        address payable _refundAddress = payable(msg.sender);

        // from docs - looks to be a future feature
        address _zroPaymentAddress = address(0);

        // advanced feature we don't need at this stage
        bytes memory _adapterParams = bytes("");

        _lzSend(
            _dstChainId,
            _payload,
            _refundAddress,
            _zroPaymentAddress,
            _adapterParams
        );
    }
}
