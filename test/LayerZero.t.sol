// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/LayerZero.sol";
import "./mocks/LZEndpointMock.sol";

contract TestLayerZeroApp is Test {
    LayerZeroContract public lz;
    LZEndpointMock public mock; 
    LayerZeroContract public _lzMockA;
    LayerZeroContract public _lzMockB;

    
    uint16 public mainnetChainId = 1;
    bytes public byteAddressA; 
    bytes public byteAddressB; 



    // for reference
    struct ApplicationConfiguration {
        uint16 inboundProofLibraryVersion;
        uint64 inboundBlockConfirmations;
        address relayer;
        uint16 outboundProofType;
        uint64 outboundBlockConfirmations;
        address oracle;
    }

    enum AppConfigOptions {
        DONOTUSE,
        INBOUNDPROOFLIBRARYVERSION,
        INBOUNDBLOCKCONFIRMATIONS,
        RELAYER,
        OUTBOUNDPROOFTYPE,
        OUTBOUNDBLOCKCONFIRMATIONS,
        ORACLE
    }

    function setUp() public {
        // https://layerzero.gitbook.io/docs/technical-reference/mainnet/supported-chain-ids
        lz = new LayerZeroContract(
            // mainnet endpoint
            0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675
        );

        mock = new LZEndpointMock(mainnetChainId);

        // deploy the xchain contracts
        _lzMockA = new LayerZeroContract(address(mock));
        _lzMockB = new LayerZeroContract(address(mock));

        // set destination endpoints
        // this is saying: set the layerzero endpoint for contract A and B to the mock
        mock.setDestLzEndpoint(address(_lzMockA), address(mock));
        mock.setDestLzEndpoint(address(_lzMockB), address(mock));

        // trusted remote needs converting address to bytes
        byteAddressA = abi.encodePacked(address(_lzMockA));
        byteAddressB = abi.encodePacked(address(_lzMockB));

        // set each contract as trusted
        _lzMockA.setTrustedRemote(mainnetChainId, byteAddressB);
        _lzMockB.setTrustedRemote(mainnetChainId, byteAddressA);
    }        


    function testApplicationBuilds() public {
        assert(lz.ping());
    }

    function testCanDeployMocks() public {
        assert(_lzMockA.ping());
        assert(_lzMockB.ping());
    } 
  

    // This took a bit of digging, the bytes return value will return a single
    // app config setting which will need to be decoded depending on the type in the config struct above
    function testCanGetOracle() public {
        uint8 layerZeroLibVersion = 1;
        uint oracleConfigOption = 6;

        bytes memory data = lz.getConfig(
            layerZeroLibVersion,
            mainnetChainId, 
            address(lz),
            uint(AppConfigOptions.ORACLE)
        );

        address config = abi.decode(data, (address));
        console.log("Oracle is at:", config);

        assert(address(config) == config);
    }


    function testCanGetRelayer() public {

        uint8 layerZeroLibVersion = 1;
        uint16 mainnetChainId = 1;
        uint oracleConfigOption = 6;

        bytes memory data = lz.getConfig(
            layerZeroLibVersion,
            mainnetChainId, 
            address(lz),
            uint(AppConfigOptions.RELAYER)
        );

        address config = abi.decode(data, (address));
        console.log("Relayer is at:", config);

        assert(address(config) == config);
    }

    function testTrustedRemotesCorrectlySet() public {
        bool BTrustedInA = _lzMockA.isTrustedRemote(mainnetChainId, byteAddressB);
        bool ATrustedInB = _lzMockB.isTrustedRemote(mainnetChainId, byteAddressA);

        assert(BTrustedInA);
        assert(ATrustedInB);
    }

    function testIncrementCounterCrossChain () public {
        assertEq(_lzMockA.count(), 0);
        assertEq(_lzMockB.count(), 0);

        _lzMockA.crossChainIncrement(mainnetChainId);

        assertEq(_lzMockB.count(), 1);
    }
  
}
