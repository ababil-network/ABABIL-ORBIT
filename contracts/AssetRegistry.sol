// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IAssetRegistry.sol";
import "./libraries/AssetIdentity.sol";

interface IERC20MetadataMinimal {
    function decimals() external view returns (uint8);
}

contract AssetRegistry is IAssetRegistry {
    uint32 public constant REGISTRY_VERSION = 1;
    uint8 public constant REQUIRED_ERC20_DECIMALS = 18;

    mapping(bytes32 => AssetRecord) private _assets;
    mapping(bytes32 => address) private _assetTokens;
    mapping(address => bytes32) private _tokenAssetKeys;

    bytes32 private immutable _nativeKey;

    constructor() {
        _nativeKey = AssetIdentity.nativeAssetKey();

        _assets[_nativeKey] = AssetRecord({
            assetType: AssetType.NATIVE,
            assetStatus: AssetStatus.REGISTERED,
            verificationStatus: VerificationStatus.UNVERIFIED,
            registrationTimestamp: uint64(block.timestamp),
            registryVersion: REGISTRY_VERSION,
            metadataReference: bytes32(0)
        });

        emit AssetRegistered(_nativeKey, AssetType.NATIVE, address(0), uint64(block.timestamp));
    }

    function nativeAssetKey() external view returns (bytes32) {
        return _nativeKey;
    }

    function computeERC20AssetKey(address token) external view returns (bytes32) {
        if (token == address(0)) revert ZeroAddress();

        return AssetIdentity.erc20AssetKey(block.chainid, token);
    }

    function isRegistered(bytes32 assetKey) external view returns (bool) {
        return _isRegistered(assetKey);
    }

    function getAsset(bytes32 assetKey) external view returns (AssetRecord memory) {
        if (!_isRegistered(assetKey)) {
            revert AssetNotRegistered(assetKey);
        }

        return _assets[assetKey];
    }

    function getAssetToken(bytes32 assetKey) external view returns (address) {
        if (!_isRegistered(assetKey)) {
            revert AssetNotRegistered(assetKey);
        }

        return _assetTokens[assetKey];
    }

    function getAssetStatus(bytes32 assetKey) external view returns (AssetStatus) {
        if (!_isRegistered(assetKey)) {
            revert AssetNotRegistered(assetKey);
        }

        return _assets[assetKey].assetStatus;
    }

    function getVerificationStatus(bytes32 assetKey) external view returns (VerificationStatus) {
        if (!_isRegistered(assetKey)) {
            revert AssetNotRegistered(assetKey);
        }

        return _assets[assetKey].verificationStatus;
    }

    function getMetadataReference(bytes32 assetKey) external view returns (bytes32) {
        if (!_isRegistered(assetKey)) {
            revert AssetNotRegistered(assetKey);
        }

        return _assets[assetKey].metadataReference;
    }

    function getAssetKey(address token) external view returns (bytes32) {
        if (token == address(0)) revert ZeroAddress();

        return _tokenAssetKeys[token];
    }

    function registerERC20(address token, bytes32 metadataReference)
        external
        returns (bytes32 assetKey)
    {
        if (token == address(0)) revert ZeroAddress();

        if (metadataReference == bytes32(0)) {
            revert MetadataInvalid();
        }

        assetKey = AssetIdentity.erc20AssetKey(block.chainid, token);

        if (_isRegistered(assetKey)) {
            revert AssetAlreadyRegistered(assetKey);
        }

        if (_tokenAssetKeys[token] != bytes32(0)) {
            revert AssetAlreadyRegistered(_tokenAssetKeys[token]);
        }

        uint256 codeSize;

        assembly {
            codeSize := extcodesize(token)
        }

        if (codeSize == 0) {
            revert InvalidTokenCode();
        }

        uint8 decimalsValue;

        try IERC20MetadataMinimal(token).decimals() returns (uint8 value) {
            decimalsValue = value;
        } catch {
            revert InvalidTokenInterface(token);
        }

        if (decimalsValue != REQUIRED_ERC20_DECIMALS) {
            revert InvalidTokenDecimals();
        }

        _assets[assetKey] = AssetRecord({
            assetType: AssetType.ERC20,
            assetStatus: AssetStatus.REGISTERED,
            verificationStatus: VerificationStatus.UNVERIFIED,
            registrationTimestamp: uint64(block.timestamp),
            registryVersion: REGISTRY_VERSION,
            metadataReference: metadataReference
        });

        _assetTokens[assetKey] = token;
        _tokenAssetKeys[token] = assetKey;

        emit AssetRegistered(assetKey, AssetType.ERC20, token, uint64(block.timestamp));
    }

    function validateAsset(bytes32 assetKey) external {
        revert Unauthorized();
    }

    function submitVerification(bytes32 assetKey, bytes32 evidenceReference) external {
        revert Unauthorized();
    }

    function enableTradingEligibility(bytes32 assetKey) external {
        revert Unauthorized();
    }

    function suspendAsset(bytes32 assetKey, bytes32 reasonReference) external {
        revert Unauthorized();
    }

    function delistAsset(bytes32 assetKey, bytes32 reasonReference) external {
        revert Unauthorized();
    }

    function _isRegistered(bytes32 assetKey) internal view returns (bool) {
        return _assets[assetKey].registrationTimestamp != 0;
    }
}
