// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract RevertingDecimalsToken {
    function decimals() external pure returns (uint8) {
        revert("DECIMALS_REVERTED");
    }
}

contract NoDecimalsToken {
    fallback() external {
        revert("NO_DECIMALS");
    }
}

contract WrongDecimalsToken {
    function decimals() external pure returns (uint8) {
        return 6;
    }
}

contract ValidDecimalsToken {
    function decimals() external pure returns (uint8) {
        return 18;
    }
}

contract GasHeavyDecimalsToken {
    uint256 private _counter;

    function decimals() external returns (uint8) {
        for (uint256 i = 0; i < 100; ++i) {
            _counter += i;
        }

        return 18;
    }
}
