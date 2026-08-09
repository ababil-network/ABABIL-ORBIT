// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ABABIL DEX Asset Identity
/// @notice Deterministic canonical asset-key derivation.
/// @dev Contains no custody, registration, or external token calls.
library AssetIdentity {
    bytes32 internal constant NATIVE_DOMAIN = keccak256("ABABIL_ORBIT_NATIVE_ABABIL_V1");

    bytes32 internal constant ERC20_DOMAIN = keccak256("ABABIL_ORBIT_ERC20_V1");

    function nativeAssetKey() internal pure returns (bytes32) {
        return NATIVE_DOMAIN;
    }

    function erc20AssetKey(uint256 chainId, address token) internal pure returns (bytes32) {
        return keccak256(abi.encode(ERC20_DOMAIN, chainId, token));
    }
}
