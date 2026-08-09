// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";

import "../contracts/AssetRegistry.sol";
import "../contracts/interfaces/IAssetRegistry.sol";
import "../contracts/mocks/MaliciousERC20Mocks.sol";

contract AssetRegistryHandler is Test {
    AssetRegistry internal immutable registry;

    address[] internal registeredTokens;
    bytes32[] internal registeredKeys;

    constructor(AssetRegistry registry_) {
        registry = registry_;
    }

    function registerValidToken(uint256 seed) external {
        ValidDecimalsToken token = new ValidDecimalsToken();

        bytes32 metadata = keccak256(abi.encode("metadata", seed));

        try registry.registerERC20(address(token), metadata) returns (bytes32 key) {
            registeredTokens.push(address(token));
            registeredKeys.push(key);
        } catch { }
    }

    function registerWrongDecimals(uint256 seed) external {
        WrongDecimalsToken token = new WrongDecimalsToken();

        bytes32 metadata = keccak256(abi.encode("wrong-decimals", seed));

        try registry.registerERC20(address(token), metadata) {
            revert("WRONG_DECIMALS_ACCEPTED");
        } catch { }
    }

    function registerRevertingDecimals(uint256 seed) external {
        RevertingDecimalsToken token = new RevertingDecimalsToken();

        bytes32 metadata = keccak256(abi.encode("reverting-decimals", seed));

        try registry.registerERC20(address(token), metadata) {
            revert("REVERTING_DECIMALS_ACCEPTED");
        } catch { }
    }

    function registeredTokenCount() external view returns (uint256) {
        return registeredTokens.length;
    }

    function registeredTokenAt(uint256 index) external view returns (address) {
        return registeredTokens[index];
    }

    function registeredKeyAt(uint256 index) external view returns (bytes32) {
        return registeredKeys[index];
    }
}

contract AssetRegistryInvariantTest is StdInvariant, Test {
    AssetRegistry internal registry;
    AssetRegistryHandler internal handler;

    function setUp() public {
        registry = new AssetRegistry();
        handler = new AssetRegistryHandler(registry);

        targetContract(address(handler));
    }

    function invariant_nativeAssetAlwaysRegistered() public view {
        bytes32 nativeKey = registry.nativeAssetKey();

        assertTrue(nativeKey != bytes32(0));
        assertTrue(registry.isRegistered(nativeKey));

        IAssetRegistry.AssetRecord memory asset = registry.getAsset(nativeKey);

        assertEq(uint8(asset.assetType), uint8(IAssetRegistry.AssetType.NATIVE));

        assertEq(uint8(asset.assetStatus), uint8(IAssetRegistry.AssetStatus.REGISTERED));

        assertEq(
            uint8(asset.verificationStatus), uint8(IAssetRegistry.VerificationStatus.UNVERIFIED)
        );
    }

    function invariant_registeredTokensRemainConsistent() public view {
        uint256 count = handler.registeredTokenCount();

        for (uint256 i = 0; i < count; ++i) {
            address token = handler.registeredTokenAt(i);
            bytes32 key = handler.registeredKeyAt(i);

            assertTrue(registry.isRegistered(key));
            assertEq(registry.getAssetToken(key), token);
            assertEq(registry.getAssetKey(token), key);
        }
    }

    function invariant_registeredKeysAreNotNative() public view {
        bytes32 nativeKey = registry.nativeAssetKey();
        uint256 count = handler.registeredTokenCount();

        for (uint256 i = 0; i < count; ++i) {
            bytes32 key = handler.registeredKeyAt(i);

            assertTrue(key != nativeKey);
        }
    }
}
