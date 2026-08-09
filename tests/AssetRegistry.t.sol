// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../contracts/AssetRegistry.sol";
import "../contracts/mocks/MaliciousERC20Mocks.sol";

contract MockERC20 {
    uint8 private immutable _decimals;

    constructor(uint8 decimals_) {
        _decimals = decimals_;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }
}

contract AssetRegistryTest is Test {
    AssetRegistry internal registry;

    function setUp() public {
        registry = new AssetRegistry();
    }

    function testNativeAssetIsRegisteredAtDeployment() public view {
        bytes32 key = registry.nativeAssetKey();

        assertTrue(key != bytes32(0));
        assertTrue(registry.isRegistered(key));

        IAssetRegistry.AssetRecord memory asset = registry.getAsset(key);

        assertEq(uint8(asset.assetType), uint8(IAssetRegistry.AssetType.NATIVE));

        assertEq(uint8(asset.assetStatus), uint8(IAssetRegistry.AssetStatus.REGISTERED));

        assertEq(
            uint8(asset.verificationStatus), uint8(IAssetRegistry.VerificationStatus.UNVERIFIED)
        );

        assertEq(asset.registryVersion, registry.REGISTRY_VERSION());
        assertEq(asset.metadataReference, bytes32(0));
    }

    function testNativeAssetTokenIsZeroAddress() public view {
        bytes32 key = registry.nativeAssetKey();

        assertEq(registry.getAssetToken(key), address(0));
    }

    function testZeroAddressRejected() public {
        vm.expectRevert(IAssetRegistry.ZeroAddress.selector);

        registry.computeERC20AssetKey(address(0));
    }

    function testZeroAddressRejectedOnRegistration() public {
        vm.expectRevert(IAssetRegistry.ZeroAddress.selector);

        registry.registerERC20(address(0), keccak256("metadata"));
    }

    function testZeroMetadataRejected() public {
        MockERC20 token = new MockERC20(18);

        vm.expectRevert(IAssetRegistry.MetadataInvalid.selector);

        registry.registerERC20(address(token), bytes32(0));
    }

    function testEOARejectedAsToken() public {
        address eoa = address(0x123456);

        vm.expectRevert(IAssetRegistry.InvalidTokenCode.selector);

        registry.registerERC20(eoa, keccak256("metadata"));
    }

    function testWrongDecimalsRejected() public {
        MockERC20 token = new MockERC20(6);

        vm.expectRevert(IAssetRegistry.InvalidTokenDecimals.selector);

        registry.registerERC20(address(token), keccak256("metadata"));
    }

    function testValidERC20CanBeRegistered() public {
        MockERC20 token = new MockERC20(18);
        bytes32 metadata = keccak256("metadata");

        bytes32 expectedKey = registry.computeERC20AssetKey(address(token));

        bytes32 returnedKey = registry.registerERC20(address(token), metadata);

        assertEq(returnedKey, expectedKey);
        assertTrue(registry.isRegistered(expectedKey));

        assertEq(registry.getAssetToken(expectedKey), address(token));

        assertEq(registry.getAssetKey(address(token)), expectedKey);

        assertEq(registry.getMetadataReference(expectedKey), metadata);
    }

    function testDuplicateERC20RegistrationRejected() public {
        MockERC20 token = new MockERC20(18);
        bytes32 metadata = keccak256("metadata");

        bytes32 key = registry.registerERC20(address(token), metadata);

        vm.expectRevert(abi.encodeWithSelector(IAssetRegistry.AssetAlreadyRegistered.selector, key));

        registry.registerERC20(address(token), metadata);
    }

    function testUnknownAssetRejected() public {
        bytes32 unknownKey = keccak256("unknown");

        vm.expectRevert(
            abi.encodeWithSelector(IAssetRegistry.AssetNotRegistered.selector, unknownKey)
        );

        registry.getAsset(unknownKey);
    }

    function testLifecycleFunctionsRemainUnauthorized() public {
        bytes32 key = registry.nativeAssetKey();

        vm.expectRevert(IAssetRegistry.Unauthorized.selector);
        registry.validateAsset(key);

        vm.expectRevert(IAssetRegistry.Unauthorized.selector);
        registry.submitVerification(key, keccak256("evidence"));

        vm.expectRevert(IAssetRegistry.Unauthorized.selector);
        registry.enableTradingEligibility(key);

        vm.expectRevert(IAssetRegistry.Unauthorized.selector);
        registry.suspendAsset(key, keccak256("reason"));

        vm.expectRevert(IAssetRegistry.Unauthorized.selector);
        registry.delistAsset(key, keccak256("reason"));
    }
}

contract AssetRegistryMaliciousTokenTest is Test {
    AssetRegistry internal registry;

    function setUp() public {
        registry = new AssetRegistry();
    }

    function testDecimalsRevertIsRejected() public {
        RevertingDecimalsToken token = new RevertingDecimalsToken();

        vm.expectRevert(
            abi.encodeWithSelector(IAssetRegistry.InvalidTokenInterface.selector, address(token))
        );

        registry.registerERC20(address(token), keccak256("metadata"));
    }

    function testMissingDecimalsInterfaceIsRejected() public {
        NoDecimalsToken token = new NoDecimalsToken();

        vm.expectRevert(
            abi.encodeWithSelector(IAssetRegistry.InvalidTokenInterface.selector, address(token))
        );

        registry.registerERC20(address(token), keccak256("metadata"));
    }

    function testWrongDecimalsTokenIsRejected() public {
        WrongDecimalsToken token = new WrongDecimalsToken();

        vm.expectRevert(IAssetRegistry.InvalidTokenDecimals.selector);

        registry.registerERC20(address(token), keccak256("metadata"));
    }

    function testValidDecimalsTokenCanRegister() public {
        ValidDecimalsToken token = new ValidDecimalsToken();

        bytes32 metadata = keccak256("metadata");

        bytes32 key = registry.registerERC20(address(token), metadata);

        assertTrue(registry.isRegistered(key));
        assertEq(registry.getAssetToken(key), address(token));
    }

    function testRegistrationRevertLeavesNoRegistryState() public {
        WrongDecimalsToken token = new WrongDecimalsToken();

        bytes32 key = registry.computeERC20AssetKey(address(token));

        vm.expectRevert(IAssetRegistry.InvalidTokenDecimals.selector);

        registry.registerERC20(address(token), keccak256("metadata"));

        assertFalse(registry.isRegistered(key));
        assertEq(registry.getAssetKey(address(token)), bytes32(0));
    }

    function testRegistrationCannotOverwriteExistingTokenMapping() public {
        ValidDecimalsToken token = new ValidDecimalsToken();

        bytes32 firstKey = registry.registerERC20(address(token), keccak256("metadata-a"));

        assertEq(registry.getAssetKey(address(token)), firstKey);

        vm.expectRevert(
            abi.encodeWithSelector(IAssetRegistry.AssetAlreadyRegistered.selector, firstKey)
        );

        registry.registerERC20(address(token), keccak256("metadata-b"));

        assertEq(registry.getAssetKey(address(token)), firstKey);
    }

    function testERC20KeyIsDifferentFromNativeKey() public {
        ValidDecimalsToken token = new ValidDecimalsToken();

        bytes32 nativeKey = registry.nativeAssetKey();
        bytes32 erc20Key = registry.computeERC20AssetKey(address(token));

        assertTrue(nativeKey != erc20Key);
    }
}
