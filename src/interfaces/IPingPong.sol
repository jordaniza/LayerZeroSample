// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.10;

// interface PingPong {
    
//     // disable ping-ponging
//     function enable(bool en) external;

//     // pings the destination chain, along with the current number of pings sent
//     function ping(
//         uint16 _dstChainId, // send a ping to this destination chainId
//         address _dstPingPongAddr, // destination address of PingPong contract
//         uint pings // the number of pings
//     ) public whenNotPaused;

//     function _nonblockingLzReceive(
//         uint16 _srcChainId,
//         bytes memory _srcAddress,
//         uint64, /*_nonce*/
//         bytes memory _payload
//     ) internal;

//     // allow this contract to receive ether
//     receive() external;
// }
