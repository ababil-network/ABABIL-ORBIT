// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ABABIL Orbit Asset Registry Interface
/// @notice Canonical asset identity and protocol-state interface.
/// @dev The registry is non-custodial and never stores user trading balances.
interface IAssetRegistry {
    enum AssetType {
        NATIVE,
        ERC20
    }

    enum AssetStatus {
        REGISTERED,
        VALIDATED,
        ELIGIBLE,
        SUSPENDED,
        DELISTED
    }

    enum VerificationStatus {
        UNVERIFIED,
        SUBMITTED,
        SCANNING,
        VERIFIED,
        REJECTED,
        SUSPENDED
    }

    struct AssetRecord {
        AssetType assetType;
        AssetStatus assetStatus;
        VerificationStatus verificationStatus;
        uint64 registrationTimestamp;
        uint32 registryVersion;
        bytes32 metadataReference;
    }

    error InvalidAsset();
    error AssetAlreadyRegistered(bytes32 assetKey);
    error AssetNotRegistered(bytes32 assetKey);
    error UnsupportedAssetType();
    error InvalidTokenInterface(address token);
    error InvalidAssetState();
    error InvalidVerificationState();
    error TradingNotAllowed(bytes32 assetKey);
    error Unauthorized();
    error ZeroAddress();
    error MetadataInvalid();
    error NativeAssetAlreadyRegistered();
    error InvalidTokenCode();
    error InvalidTokenDecimals();
    error InvalidStateTransition();

    event AssetRegistered(
        bytes32 indexed assetKey,
        AssetType indexed assetType,
        address indexed token,
        uint64 timestamp
    );

    event AssetValidated(bytes32 indexed assetKey, uint64 timestamp);

    event AssetStatusUpdated(
        bytes32 indexed assetKey,
        AssetStatus indexed previousStatus,
        AssetStatus indexed newStatus,
        bytes32 reasonReference
    );

    event VerificationSubmitted(
        bytes32 indexed assetKey, bytes32 indexed evidenceReference, uint64 timestamp
    );

    event VerificationStatusUpdated(
        bytes32 indexed assetKey,
        VerificationStatus indexed previousStatus,
        VerificationStatus indexed newStatus,
        bytes32 evidenceReference,
        uint64 timestamp
    );

    event AssetMetadataUpdated(
        bytes32 indexed assetKey, bytes32 indexed metadataReference, uint64 timestamp
    );

    function nativeAssetKey() external view returns (bytes32);

    function computeERC20AssetKey(address token) external view returns (bytes32);

    function isRegistered(bytes32 assetKey) external view returns (bool);

    function getAsset(bytes32 assetKey) external view returns (AssetRecord memory);

    function getAssetToken(bytes32 assetKey) external view returns (address);

    function getAssetStatus(bytes32 assetKey) external view returns (AssetStatus);

    function getVerificationStatus(bytes32 assetKey) external view returns (VerificationStatus);

    function getMetadataReference(bytes32 assetKey) external view returns (bytes32);

    function getAssetKey(address token) external view returns (bytes32);

    function registerERC20(address token, bytes32 metadataReference)
        external
        returns (bytes32 assetKey);

    function validateAsset(bytes32 assetKey) external;

    function submitVerification(bytes32 assetKey, bytes32 evidenceReference) external;

    function enableTradingEligibility(bytes32 assetKey) external;

    function suspendAsset(bytes32 assetKey, bytes32 reasonReference) external;

    function delistAsset(bytes32 assetKey, bytes32 reasonReference) external;
}
