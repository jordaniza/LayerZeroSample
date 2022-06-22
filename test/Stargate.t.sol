// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "src/stargate/Router.sol";
import "src/stargate/Bridge.sol";
import "src/stargate/Factory.sol";

import "./mocks/LZEndpointMock.sol";
import "src/interfaces/ILayerZeroEndpoint.sol";

import "src/stargate/Stargate.sol";

contract TestStargate is Test {

    LZEndpointMock lzEndpoint;

    Router router;
    Bridge bridge;
    Factory factory;
    StargateExample app;

    uint16 chainId = 1;
    uint16 poolId = 11;
    uint16 dstChainId = 2;
    uint16 dstPoolId = 22;
    uint8 decimals = 18;

    function setUp() public {
        lzEndpoint = new LZEndpointMock(chainId);
        router = new Router();
        bridge = new Bridge(address(lzEndpoint), address(router));
        factory = new Factory(address(router)); 

        router.setBridgeAndFactory(bridge, factory);

        app = new StargateExample(address(router));
    }

    function testEverythingSetup() external {
        console.log(
            "router, bridge, factory",
            address(router), 
            address(bridge), 
            address(factory)
        );
        console.log(
            "lzEndpoint, app",
            address(lzEndpoint), 
            address(app)
        );
    }

    function testAppSwap() external {
        
    }
}