// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/PingPong.sol";
import "./mocks/LZEndpointMock.sol";
import "src/interfaces/ILayerZeroEndpoint.sol";
import "src/interfaces/IPingPong.sol";

contract TestPingPong is Test {
    uint16 chainIdSrc = 1;
    uint16 chainIdDst = 137;

    LZEndpointMock layerZeroEndpointMockSrc;
    LZEndpointMock layerZeroEndpointMockDst;

    PingPong pingPongA;
    PingPong pingPongB;

    // trusted remote needs converting address to bytes
    bytes public byteAddressA; 
    bytes public byteAddressB;    

    // event emitted every ping() to keep track of consecutive pings count
    event Ping(uint pings);         

    function setUp() public {
        // deploy mocks
        layerZeroEndpointMockSrc = new LZEndpointMock(chainIdSrc); 
        layerZeroEndpointMockDst = new LZEndpointMock(chainIdDst); 

        // set mock fees
        uint mockEstimatedNativeFee = 0.001 ether; 
        uint mockEstimatedZroFee = 0.0025 ether; 
        layerZeroEndpointMockSrc.setEstimatedFees(mockEstimatedNativeFee, mockEstimatedZroFee);
        layerZeroEndpointMockDst.setEstimatedFees(mockEstimatedNativeFee, mockEstimatedZroFee);

        // create two PingPong instances
        pingPongA = new PingPong(address(layerZeroEndpointMockSrc));
        pingPongB = new PingPong(address(layerZeroEndpointMockDst));

        // top up PingPong with ether
        vm.deal(address(pingPongA), 0.1 ether);
        vm.deal(address(pingPongB), 0.1 ether);

        // setup dest endpoints
        layerZeroEndpointMockSrc.setDestLzEndpoint(address(pingPongB), address(layerZeroEndpointMockDst));
        layerZeroEndpointMockDst.setDestLzEndpoint(address(pingPongA), address(layerZeroEndpointMockSrc));

        // set each contracts source address so it can send to each other
        byteAddressA = abi.encodePacked(address(pingPongA));
        byteAddressB = abi.encodePacked(address(pingPongB));
        pingPongA.setTrustedRemote(chainIdDst, byteAddressB);
        pingPongB.setTrustedRemote(chainIdSrc, byteAddressA);

        // enable ping pong
        pingPongA.enable(true);
        pingPongB.enable(true);
    }

    function testIsEnabled() public {
        assert(pingPongA.paused());
        assert(pingPongB.paused());
    }

    function testContractsHaveBalance() public {
        assertEq(address(pingPongA).balance, 0.1 ether);
        assertEq(address(pingPongB).balance, 0.1 ether);
    }

    function testPing() public {
        pingPongA.enable(false);
        pingPongB.enable(false);
        vm.expectEmit(false, false, false, true);
        emit Ping(1);
        pingPongA.ping(chainIdDst, address(pingPongB), 0);
    }

    // function testRealContractExists() public {
    //     IPingPong pingPongFTM = IPingPong(0x2e05590c1b24469eaef2b29c6c7109b507ec2544);
    //     assertEq(address(pingPongFTM), "0x2e05590c1b24469eaef2b29c6c7109b507ec2544");
    // }
}