// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ABABIL Orbit Asset Registry Interface
/// @notice Canonical asset identity and protocol-state interface.
/// @dev This interface does not hold user trading balances.
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
        address assetId;
        AssetType assetType;
        AssetStatus assetStatus;
        VerificationStatus verificationStatus;
        bytes32 metadataReference;
        uint64 registrationTimestamp;
        uint32 registryVersion;
    }

    error InvalidAsset();
    error AssetAlreadyRegistered(address assetId);
    error AssetNotRegistered(address assetId);
    error UnsupportedAssetType();
    error InvalidTokenInterface(address assetId);
    error InvalidAssetState();
    error InvalidVerificationState();
    error TradingNotAllowed(address assetId);
    error Unauthorized();
    error ZeroAddress();
    error MetadataInvalid();
    error NativeAssetAlreadyRegistered();

    event AssetRegistered(
        address indexed assetId,
        AssetType indexed assetType,
        uint64 timestamp
    );

    event AssetValidated(
        address indexed assetId,
        uint64 timestamp
    );

    event AssetStatusUpdated(
        address indexed assetId,
        AssetStatus indexed previousStatus,
        AssetStatus indexed newStatus,
        bytes32 reasonReference
    );

    event VerificationSubmitted(
        address indexed assetId,
        bytes32 indexed evidenceReference,
        uint64 timestamp
    );

    event VerificationStatusUpdated(
        address indexed assetId,
        VerificationStatus indexed previousStatus,
        VerificationStatus indexed newStatus,
        bytes32 evidenceReference,
        uint64 timestamp
    );

    event AssetMetadataUpdated(
        address indexed assetId,
        bytes32 indexed metadataReference,
        uint64 timestamp
    );

    function isRegistered(address assetId)
        external
        view
        returns (bool);

    function getAsset(address assetId)
        external
        view
        returns (AssetRecord memory);

    function getAssetStatus(address assetId)
        external
        view
        returns (AssetStatus);

    function getVerificationStatus(address assetId)
        external
        view
        returns (VerificationStatus);

    function getMetadataReference(address assetId)
        external
        view
        returns (bytes32);
}
