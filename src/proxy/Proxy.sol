// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Proxy
/// @notice Provides a fallback function that delegates all calls to implementation contract using `delegatecall`.
abstract contract Proxy {
    /// @notice Delegates the current call to `implementation`.
    function _delegate(address implementation) internal virtual {
        assembly ("memory-safe") {
            calldatacopy(0x00, 0x00, calldatasize())

            let success := delegatecall(gas(), implementation, 0x00, calldatasize(), 0x00, 0x00)
            returndatacopy(0x00, 0x00, returndatasize())

            switch success
            case 0x00 {
                revert(0x00, returndatasize())
            }
            default {
                return(0x00, returndatasize())
            }
        }
    }

    /// @notice Returns the address to which the fallback function should delegate.
    function _implementation() internal view virtual returns (address);

    /// @notice Delegates the current call to the address returned by `_implementation()`.
    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    /// @notice Fallback function that delegates calls to the address returned by `_implementation()`.
    /// @dev Will run if no other function in the contract matches the call data.
    fallback() external payable virtual {
        _fallback();
    }

    /// @notice Fallback function that delegates calls to the address returned by `_implementation()`.
    /// @dev Will run if the call data is empty.
    receive() external payable virtual {
        _fallback();
    }
}
