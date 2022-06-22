// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

interface IStargateExample {

    /// @param qty The remote chainId sending the tokens
    /// @param bridgeToken The remote Bridge address
    /// @param dstChainId The message ordering nonce
    /// @param srcPoolId The token contract on the local chain
    /// @param dstPoolId The qty of local _token contract tokens  
    /// @param to The bytes containing the toAddress - must implement sgReceive
    /// @param deadline The bytes containing the toAddress
    /// @param destStargateComposed The bytes containing the toAddress
    function swap(
        uint qty,
        address bridgeToken,                    
        uint16 dstChainId,                      
        uint16 srcPoolId,                       
        uint16 dstPoolId,                       
        address to,                             
        uint deadline,                          
        address destStargateComposed            
    ) external payable;
}