// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/LayerZero.sol";
import "./mocks/LZEndpointMock.sol";
import "src/interfaces/ILayerZeroEndpoint.sol";

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

    address mainnetEndpoint = 0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675;

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
        lz = new LayerZeroContract(mainnetEndpoint);

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

        // set each contract as trusted - note that in this pattern there
        // is only one trusted remote per chain
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
        uint16 _mainnetChainId = 1;
        uint oracleConfigOption = 6;

        bytes memory data = lz.getConfig(
            layerZeroLibVersion,
            _mainnetChainId, 
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

    function testIncrementCounterCrossChain(uint _qty) public {
        _lzMockB.crossChainIncrement(mainnetChainId, _qty);
        _lzMockA.crossChainIncrement(mainnetChainId, _qty);

        assertEq(_lzMockA.count(), _qty);
        assertEq(_lzMockB.count(), _qty);
    }

    function testCanEstimateGasPriceForTransaction() public {
        uint16 _dstChainId = mainnetChainId;
        address _userApplication = address(lz);
        bytes memory _payload = abi.encodePacked(uint(100));
        bool _payInZRO = false;
        bytes memory _adapterParam = bytes("");
                
        (uint nativeFee, uint zroFee) = ILayerZeroEndpoint(mainnetEndpoint).estimateFees(
            _dstChainId,
            _userApplication,
            _payload,
            _payInZRO,
            _adapterParam
        );

        console.log("native fee estimation", nativeFee);

        assertEq(zroFee, 0);
        assertGt(nativeFee, 0);
    }
}
