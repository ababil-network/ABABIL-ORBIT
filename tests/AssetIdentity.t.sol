// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/libraries/AssetIdentity.sol";

contract AssetIdentityTest is Test {
    function testNativeAssetKeyIsDeterministic() public pure {
        bytes32 expected = keccak256("ABABIL_ORBIT_NATIVE_ABABIL_V1");

        assertEq(AssetIdentity.nativeAssetKey(), expected);
    }

    function testERC20AssetKeyIsDeterministic() public pure {
        uint256 chainId = 12345;
        address token = address(0x1234);

        bytes32 first = AssetIdentity.erc20AssetKey(chainId, token);

        bytes32 second = AssetIdentity.erc20AssetKey(chainId, token);

        assertEq(first, second);
    }

    function testERC20AssetKeySeparatesChainId() public pure {
        address token = address(0x1234);

        bytes32 keyA = AssetIdentity.erc20AssetKey(1, token);

        bytes32 keyB = AssetIdentity.erc20AssetKey(2, token);

        assertTrue(keyA != keyB);
    }

    function testERC20AssetKeySeparatesTokenAddress() public pure {
        uint256 chainId = 12345;

        bytes32 keyA = AssetIdentity.erc20AssetKey(chainId, address(0x1234));

        bytes32 keyB = AssetIdentity.erc20AssetKey(chainId, address(0x5678));

        assertTrue(keyA != keyB);
    }

    function testNativeAndERC20DomainsAreSeparated() public view {
        bytes32 nativeKey = AssetIdentity.nativeAssetKey();

        bytes32 erc20Key = AssetIdentity.erc20AssetKey(block.chainid, address(0x1234));

        assertTrue(nativeKey != erc20Key);
    }
}
