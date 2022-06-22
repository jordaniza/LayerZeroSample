// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;
pragma abicoder v2;

import "src/stargate/interfaces/IStargateReceiver.sol";
import "src/stargate/interfaces/IStargateRouter.sol";

import "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";


contract StargateExample is IStargateReceiver {

    event ReceivedOnDestination(address token, uint amount, uint16 srcChainId);
    event ActionReceived(bool success);

    address public stargateRouter;

    constructor(address _stargateRouter) {
        stargateRouter = _stargateRouter;
    }

    /// @param _chainId The remote chainId sending the tokens
    /// @param _srcAddress The remote Bridge address
    /// @param _nonce The message ordering nonce
    /// @param _token The token contract on the local chain
    /// @param amountLD The qty of local _token contract tokens  
    /// @param _payload The bytes containing the _tokenOut, _deadline, _amountOutMin, _toAddr    
    /// @dev will implement the callback action
    function sgReceive(
        uint16 _chainId,
        bytes memory _srcAddress,
        uint256 _nonce,
        address _token,
        uint256 amountLD,
        bytes memory _payload
    ) override external {
        require(
            msg.sender == address(stargateRouter), "only stargate router can call sgReceive!"
        );
        (address _toAddr, uint8 _action) = abi.decode(_payload, (address,uint8));
        IERC20(_token).transfer(_toAddr, amountLD);
        emit ReceivedOnDestination(_token, amountLD, _chainId);
        if (_action == 8) {
            emit ActionReceived(true);
        } else {
            emit ActionReceived(false);
        }
    }

    /// @param qty number of tokens to send
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
    ) external payable {
        require(msg.value > 0, "stargate requires a msg.value to pay crosschain message");
        require(qty > 0, 'error: swap() requires qty > 0');

        bytes memory data = _encode(to);
        // this contract calls stargate swap()
        IERC20(bridgeToken).transferFrom(msg.sender, address(this), qty);
        IERC20(bridgeToken).approve(address(stargateRouter), qty);

        // Stargate's Router.swap() function sends the tokens to the destination chain.
        IStargateRouter(stargateRouter).swap{value:msg.value}(
            dstChainId,                                     // the destination chain id
            srcPoolId,                                      // the source Stargate poolId
            dstPoolId,                                      // the destination Stargate poolId
            payable(msg.sender),                            // refund adddress. if msg.sender pays too much gas, return extra eth
            qty,                                            // total tokens to send to destination chain
            0,                                              // min amount allowed out
            IStargateRouter.lzTxObj(200000, 0, "0x"),       // default lzTxObj
            abi.encodePacked(destStargateComposed),         // destination address, the sgReceive() implementer
            data                                            // bytes payload
        );
    }

    function _encode(address _to) internal pure returns (bytes memory data) {
        uint8 action = 8;
        bytes memory data = abi.encode(_to, action); // 8 is some arbitrary data
        return data;
    }

}