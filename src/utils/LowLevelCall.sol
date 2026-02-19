// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title LowLevelCall
/// @notice Library of low level call functions that implement different calling strategies.
/// @author fomoweth
library LowLevelCall {
    /// @notice Performs a Solidity function call using a low level `call`.
    function call(address target, bytes memory data) internal returns (bool success) {
        return call(target, 0, data);
    }

    /// @notice Performs a Solidity function call using a low level `call`.
    function call(address target, uint256 value, bytes memory data) internal returns (bool success) {
        assembly ("memory-safe") {
            success := call(gas(), target, value, add(data, 0x20), mload(data), codesize(), 0x00)
        }
    }

    /// @notice Performs a Solidity function call using a low level `delegatecall`.
    function callDelegate(address target, bytes memory data) internal returns (bool success) {
        assembly ("memory-safe") {
            success := delegatecall(gas(), target, add(data, 0x20), mload(data), codesize(), 0x00)
        }
    }

    /// @notice Performs a Solidity function call using a low level `staticcall`.
    function callStatic(address target, bytes memory data) internal view returns (bool success) {
        assembly ("memory-safe") {
            success := staticcall(gas(), target, add(data, 0x20), mload(data), codesize(), 0x00)
        }
    }

    /// @notice Returns the size of the return data buffer.
    function returnDataSize() internal pure returns (uint256 size) {
        assembly ("memory-safe") {
            size := returndatasize()
        }
    }

    /// @notice Returns a buffer containing the return data from the last call.
    function returnData() internal pure returns (bytes memory returndata) {
        assembly ("memory-safe") {
            returndata := mload(0x40)
            mstore(returndata, returndatasize())
            returndatacopy(add(returndata, 0x20), 0x00, returndatasize())
            mstore(0x40, add(add(returndata, 0x20), returndatasize()))
        }
    }

    /// @notice Revert with the return data from the last call.
    function bubbleRevert() internal pure {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            returndatacopy(ptr, 0x00, returndatasize())
            revert(ptr, returndatasize())
        }
    }

    function bubbleRevert(bytes memory returndata) internal pure {
        assembly ("memory-safe") {
            revert(add(returndata, 0x20), mload(returndata))
        }
    }
}
