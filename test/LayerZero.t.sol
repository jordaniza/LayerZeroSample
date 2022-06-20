// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/LayerZero.sol";

contract TestLayerZeroApp is Test {
     LayerZeroContract public lz;

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
    }

    function testApplicationBuilds() public {
        assert(lz.ping());
    }

    // This took a bit of digging, the bytes return value will return a single
    // app config setting which will need to be decoded as above
    function testCanGetOracle() public {
        uint8 layerZeroLibVersion = 1;
        uint16 mainnetChainId = 1;
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
}
