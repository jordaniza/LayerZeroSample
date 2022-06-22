// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;
pragma abicoder v2;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "src/interfaces/ILayerZeroEndpoint.sol";
import "src/stargate/interfaces/IStargateRouter.sol";
import "src/stargate/interfaces/IStargateExample.sol";
import "src/stargate/Stargate.sol";


/// @title shared logic for cross chain deploys 
contract BaseScript is Script {

    address public immutable testingAccountAddr = 0x63BCe354DBA7d6270Cb34dAA46B869892AbB3A79;

    address public deployedApplicationAddress = address(0);
    address public destinationAddress = address(0);

    IStargateRouter public router; 
    StargateExample public app;

    uint16 public chainId;
    address public routerAddr;
    address public USDC;
    
    constructor(
        uint16 _chainId,
        address _routerAddr,
        address _USDC
    ) {
        chainId = _chainId;
        routerAddr = _routerAddr;
        USDC = _USDC;
        router = IStargateRouter(routerAddr);
    }

    function _deploy() internal {
        app = new StargateExample(routerAddr);
        deployedApplicationAddress = address(app);
    }

    function _executeSwap(address _appAddress, uint16 _dstChainId, uint _fee, address _destinationAddress) public payable {
        require(_appAddress != address(0), "Cannot execute swap without a valid app address");
        require(_destinationAddress != address(0), "Cannot execute swap without a valid dest address");
        // require(msg.value >= _fee, "Fee is too low");

        IStargateExample _app = IStargateExample(_appAddress);

        uint qty = 1e9; // usdc is 6 decimals
        uint16 usdcPoolId = 1;

        _app.swap{value:_fee}(
            qty,
            USDC,
            _dstChainId, // param
            usdcPoolId, 
            usdcPoolId,
            testingAccountAddr,
            0, // ignore
            _destinationAddress
        ); 
    }

    function _setAllowance(address _addr) internal {
        vm.broadcast(testingAccountAddr);
        IERC20(USDC).approve(_addr, type(uint).max);

        uint allowance = IERC20(USDC).allowance(testingAccountAddr, _addr); 
        console.log("allowance set to", allowance);
    }


    function _run(
        uint16 _dstChainId,
        address _deployedApplicationAddress,
        address _destinationAddress
    ) public payable {
        uint balance = testingAccountAddr.balance;
        console.log("Balance of the testing account is", balance);

        uint8 _functionType = 1; // swap
        bytes memory _toAddress = abi.encodePacked(testingAccountAddr);
        bytes memory _transferAndCallPayload = abi.encode(testingAccountAddr, 8);
        IStargateRouter.lzTxObj memory _lzTxParams = IStargateRouter.lzTxObj({
            dstGasForCall: 0,
            dstNativeAmount: 0,
            dstNativeAddr: abi.encodePacked(testingAccountAddr)
        });

        (uint fees,) = router.quoteLayerZeroFee(_dstChainId, _functionType, _toAddress, _transferAndCallPayload, _lzTxParams);
        console.log("Fees are", fees);

        destinationAddress = _destinationAddress;
        deployedApplicationAddress = _deployedApplicationAddress;
        console.log(destinationAddress, deployedApplicationAddress);

        _setAllowance(deployedApplicationAddress);
        // uncomment if you need to deploy (say, on a fork)
        // _deploy();

        vm.startBroadcast(testingAccountAddr);
    
        _executeSwap(
            deployedApplicationAddress,
            _dstChainId,
            fees,
            destinationAddress
        );

        vm.stopBroadcast();
    }
}

/// @dev _chainId, router, usdc address
contract StargateScriptOptimismKovan is Script,
    BaseScript(
        10011,
        0xCC68641528B948642bDE1729805d6cf1DECB0B00,
        0x567f39d9e6d02078F357658f498F80eF087059aa
    ) 
{
    uint16 arbitrumRinkebyId = 10010;
    address _deployedApplicationAddress = 0xCb162B56427B0BFF26A9B490781fdd2DE03e283c;
    address _destinationAddress = 0xCb162B56427B0BFF26A9B490781fdd2DE03e283c;

    function run() external {
        _run(
            arbitrumRinkebyId,
            _deployedApplicationAddress,
            _destinationAddress
        );
    }
}


/// @dev _chainId, router, usdc address
contract StargateScriptMainnet is Script,
    BaseScript(
        1,
        0x8731d54E9D02c286767d56ac03e8037C07e01e98,
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    ) 
{
    uint16 mainnetId = 1;

    function run() external {
        _run(mainnetId, 0xCb162B56427B0BFF26A9B490781fdd2DE03e283c, address(0));
    }
}

/// @dev _chainId, router, usdc address
contract StargateScriptArbitrum is Script,
    BaseScript(
        10010,
        0x6701D9802aDF674E524053bd44AA83ef253efc41,
        0x1EA8Fb2F671620767f41559b663b86B1365BBc3d
    ) 
{
    uint16 optimismKovanId = 10011;
    address _deployedApplicationAddress = 0xCb162B56427B0BFF26A9B490781fdd2DE03e283c;
    address _destinationAddress = 0xCb162B56427B0BFF26A9B490781fdd2DE03e283c;    

    function run() external {
        _run(
            optimismKovanId,
            _deployedApplicationAddress,
            _destinationAddress
        );
    }
}
