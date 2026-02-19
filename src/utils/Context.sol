// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Context
/// @notice Provides information about the current execution context.
/// @author fomoweth
abstract contract Context {
    /// @notice Thrown when the call is from an unauthorized context.
    error UnauthorizedCallContext();

    /// @notice The original address of this contract.
    /// @dev Used for checking if the context is a delegate call.
    uint256 private immutable __self = uint256(uint160(address(this)));

    modifier onlyDelegated() {
        _checkDelegated();
        _;
    }

    modifier notDelegated() {
        _checkNotDelegated();
        _;
    }

    function _msgSender() internal view virtual returns (address sender) {
        assembly ("memory-safe") {
            sender := caller()
        }
    }

    function _msgData() internal view virtual returns (bytes calldata data) {
        assembly ("memory-safe") {
            data.offset := 0x00
            data.length := calldatasize()
        }
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {}

    function _isDelegated() internal view virtual returns (bool) {
        return uint160(address(this)) != __self;
    }

    function _checkDelegated() internal view virtual {
        if (!_isDelegated()) _revertUnauthorizedCallContext();
    }

    function _checkNotDelegated() internal view virtual {
        if (_isDelegated()) _revertUnauthorizedCallContext();
    }

    function _revertUnauthorizedCallContext() private pure {
        assembly ("memory-safe") {
            mstore(0x00, 0x9f03a026) // UnauthorizedCallContext()
            revert(0x1c, 0x04)
        }
    }
}
