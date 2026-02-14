// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

type AddressSlot is bytes32;
type BooleanSlot is bytes32;
type Bytes32Slot is bytes32;
type Uint256Slot is bytes32;
type Int256Slot is bytes32;
type BytesSlot is bytes32;
type StringSlot is bytes32;

using StorageSlot for AddressSlot global;
using StorageSlot for BooleanSlot global;
using StorageSlot for Bytes32Slot global;
using StorageSlot for Uint256Slot global;
using StorageSlot for Int256Slot global;
using StorageSlot for BytesSlot global;
using StorageSlot for StringSlot global;

/// @title StorageSlot
/// @notice Provides type-safe storage operations for both persistent and transient storage
/// @author fomoweth
library StorageSlot {
    /// @notice Thrown when attempting to store a dynamic value (bytes/string) exceeding 2³² - 1 bytes
    error ExceededMaxDataLength();

    /// @notice Maximum bytes of data that can be stored inline in a single slot (28 bytes)
    uint256 internal constant MAX_CAPACITY = 0x1c;

    /// @notice Mask for extracting the length value from storage (4 bytes)
    uint256 internal constant LENGTH_MASK = 0xffffffff;

    /// @notice Size of the length field in bytes (4 bytes)
    uint256 internal constant LENGTH_SIZE = 0x04;

    /// @notice Bit shift amount to position length in the high-order bytes (224 bits)
    uint256 internal constant LENGTH_SHIFT = 0xe0;

    /// @notice Casts an arbitrary slot to a AddressSlot
    function asAddress(bytes32 slot) internal pure returns (AddressSlot) {
        return AddressSlot.wrap(slot);
    }

    /// @notice Loads the value held at location `slot` in persistent storage
    function sload(AddressSlot slot) internal view returns (address result) {
        assembly ("memory-safe") {
            result := sload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in persistent storage
    function sstore(AddressSlot slot, address value) internal {
        assembly ("memory-safe") {
            sstore(slot, shr(0x60, shl(0x60, value)))
        }
    }

    /// @notice Loads the value held at location `slot` in transient storage
    function tload(AddressSlot slot) internal view returns (address result) {
        assembly ("memory-safe") {
            result := tload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in transient storage
    function tstore(AddressSlot slot, address value) internal {
        assembly ("memory-safe") {
            tstore(slot, shr(0x60, shl(0x60, value)))
        }
    }

    /// @notice Clears the value at location `slot` in transient storage
    function tclear(AddressSlot slot) internal {
        assembly ("memory-safe") {
            tstore(slot, 0x00)
        }
    }

    /// @notice Checks whether the transient storage at `slot` is empty (zero address)
    function isEmpty(AddressSlot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(shl(0x60, tload(slot)))
        }
    }

    /// @notice Casts an arbitrary slot to a BooleanSlot
    function asBoolean(bytes32 slot) internal pure returns (BooleanSlot) {
        return BooleanSlot.wrap(slot);
    }

    /// @notice Loads the value held at location `slot` in persistent storage
    function sload(BooleanSlot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := sload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in persistent storage
    function sstore(BooleanSlot slot, bool value) internal {
        assembly ("memory-safe") {
            sstore(slot, iszero(iszero(value)))
        }
    }

    /// @notice Loads the value held at location `slot` in transient storage
    function tload(BooleanSlot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := tload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in transient storage
    function tstore(BooleanSlot slot, bool value) internal {
        assembly ("memory-safe") {
            tstore(slot, iszero(iszero(value)))
        }
    }

    /// @notice Clears the value at location `slot` in transient storage
    function tclear(BooleanSlot slot) internal {
        assembly ("memory-safe") {
            tstore(slot, 0x00)
        }
    }

    /// @notice Checks whether the transient storage at `slot` is empty (false)
    function isEmpty(BooleanSlot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(tload(slot))
        }
    }

    /// @notice Casts an arbitrary slot to a Bytes32Slot
    function asBytes32(bytes32 slot) internal pure returns (Bytes32Slot) {
        return Bytes32Slot.wrap(slot);
    }

    /// @notice Loads the value held at location `slot` in persistent storage
    function sload(Bytes32Slot slot) internal view returns (bytes32 result) {
        assembly ("memory-safe") {
            result := sload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in persistent storage
    function sstore(Bytes32Slot slot, bytes32 value) internal {
        assembly ("memory-safe") {
            sstore(slot, value)
        }
    }

    /// @notice Loads the value held at location `slot` in transient storage
    function tload(Bytes32Slot slot) internal view returns (bytes32 result) {
        assembly ("memory-safe") {
            result := tload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in transient storage
    function tstore(Bytes32Slot slot, bytes32 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /// @notice Clears the value at location `slot` in transient storage
    function tclear(Bytes32Slot slot) internal {
        assembly ("memory-safe") {
            tstore(slot, 0x00)
        }
    }

    /// @notice Checks whether the transient storage at `slot` is empty (zero bytes32)
    function isEmpty(Bytes32Slot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(tload(slot))
        }
    }

    /// @notice Casts an arbitrary slot to a Uint256Slot
    function asUint256(bytes32 slot) internal pure returns (Uint256Slot) {
        return Uint256Slot.wrap(slot);
    }

    /// @notice Loads the value held at location `slot` in persistent storage
    function sload(Uint256Slot slot) internal view returns (uint256 result) {
        assembly ("memory-safe") {
            result := sload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in persistent storage
    function sstore(Uint256Slot slot, uint256 value) internal {
        assembly ("memory-safe") {
            sstore(slot, value)
        }
    }

    /// @notice Loads the value held at location `slot` in transient storage
    function tload(Uint256Slot slot) internal view returns (uint256 result) {
        assembly ("memory-safe") {
            result := tload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in transient storage
    function tstore(Uint256Slot slot, uint256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /// @notice Clears the value at location `slot` in transient storage
    function tclear(Uint256Slot slot) internal {
        assembly ("memory-safe") {
            tstore(slot, 0x00)
        }
    }

    /// @notice Checks whether the transient storage at `slot` is empty (zero)
    function isEmpty(Uint256Slot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(tload(slot))
        }
    }

    /// @notice Casts an arbitrary slot to a Int256Slot
    function asInt256(bytes32 slot) internal pure returns (Int256Slot) {
        return Int256Slot.wrap(slot);
    }

    /// @notice Loads the value held at location `slot` in persistent storage
    function sload(Int256Slot slot) internal view returns (int256 result) {
        assembly ("memory-safe") {
            result := sload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in persistent storage
    function sstore(Int256Slot slot, int256 value) internal {
        assembly ("memory-safe") {
            sstore(slot, value)
        }
    }

    /// @notice Loads the value held at location `slot` in transient storage
    function tload(Int256Slot slot) internal view returns (int256 result) {
        assembly ("memory-safe") {
            result := tload(slot)
        }
    }

    /// @notice Stores `value` at location `slot` in transient storage
    function tstore(Int256Slot slot, int256 value) internal {
        assembly ("memory-safe") {
            tstore(slot, value)
        }
    }

    /// @notice Clears the value at location `slot` in transient storage
    function tclear(Int256Slot slot) internal {
        assembly ("memory-safe") {
            tstore(slot, 0x00)
        }
    }

    /// @notice Checks whether the transient storage at `slot` is empty (zero)
    function isEmpty(Int256Slot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(tload(slot))
        }
    }

    /// @notice Casts an arbitrary slot to a BytesSlot
    function asBytes(bytes32 slot) internal pure returns (BytesSlot) {
        return BytesSlot.wrap(slot);
    }

    /// @notice Gets the length of bytes data stored at `slot` in persistent storage
    function slength(BytesSlot slot) internal view returns (uint256 length) {
        assembly ("memory-safe") {
            length := shr(LENGTH_SHIFT, sload(slot))
        }
    }

    /// @notice Loads the value held at location `slot` in persistent storage
    function sload(BytesSlot slot) internal view returns (bytes memory result) {
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, 0x00)
            mstore(add(result, MAX_CAPACITY), sload(slot))

            let length := mload(result)
            let offset := add(result, 0x20)
            let guard := add(offset, length)

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    mstore(offset, sload(slot))
                    offset := add(offset, 0x20)
                    if gt(offset, guard) { break }
                    slot := add(slot, 0x01)
                }
            }

            mstore(guard, 0x00)
            mstore(0x40, add(guard, 0x20))
        }
    }

    /// @notice Stores `value` at location `slot` in persistent storage
    function sstore(BytesSlot slot, bytes memory value) internal {
        assembly ("memory-safe") {
            let length := mload(value)
            if gt(length, LENGTH_MASK) {
                mstore(0x00, 0x06045ade) // ExceededMaxDataLength()
                revert(0x1c, 0x04)
            }

            let offset := add(value, 0x20)
            sstore(slot, mload(sub(offset, LENGTH_SIZE)))

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)

                let guard := sub(add(offset, length), 0x01)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    sstore(slot, mload(offset))
                    offset := add(offset, 0x20)
                    if gt(offset, guard) { break }
                    slot := add(slot, 0x01)
                }
            }
        }
    }

    /// @notice Gets the length of bytes data stored at `slot` in transient storage
    function tlength(BytesSlot slot) internal view returns (uint256 length) {
        assembly ("memory-safe") {
            length := shr(LENGTH_SHIFT, tload(slot))
        }
    }

    /// @notice Loads the value held at location `slot` in transient storage
    function tload(BytesSlot slot) internal view returns (bytes memory result) {
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, 0x00)
            mstore(add(result, MAX_CAPACITY), tload(slot))

            let length := mload(result)
            let offset := add(result, 0x20)
            let guard := add(offset, length)

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    mstore(offset, tload(slot))
                    offset := add(offset, 0x20)
                    if gt(offset, guard) { break }
                    slot := add(slot, 0x01)
                }
            }

            mstore(guard, 0x00)
            mstore(0x40, add(guard, 0x20))
        }
    }

    /// @notice Stores `value` at location `slot` in transient storage
    function tstore(BytesSlot slot, bytes memory value) internal {
        assembly ("memory-safe") {
            let length := mload(value)
            if gt(length, LENGTH_MASK) {
                mstore(0x00, 0x06045ade) // ExceededMaxDataLength()
                revert(0x1c, 0x04)
            }

            let offset := add(value, 0x20)
            tstore(slot, mload(sub(offset, LENGTH_SIZE)))

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)

                let guard := sub(add(offset, length), 0x01)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    tstore(slot, mload(offset))
                    offset := add(offset, 0x20)
                    if gt(offset, guard) { break }
                    slot := add(slot, 0x01)
                }
            }
        }
    }

    /// @notice Clears the value at location `slot` in transient storage
    function tclear(BytesSlot slot) internal {
        assembly ("memory-safe") {
            tstore(slot, 0x00)
        }
    }

    /// @notice Checks whether the transient storage at `slot` is empty
    function isEmpty(BytesSlot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(tload(slot))
        }
    }

    /// @notice Casts an arbitrary slot to a StringSlot
    function asString(bytes32 slot) internal pure returns (StringSlot) {
        return StringSlot.wrap(slot);
    }

    /// @notice Gets the length of string data stored at `slot` in persistent storage
    function slength(StringSlot slot) internal view returns (uint256 length) {
        assembly ("memory-safe") {
            length := shr(LENGTH_SHIFT, sload(slot))
        }
    }

    /// @notice Loads the value held at location `slot` in persistent storage
    function sload(StringSlot slot) internal view returns (string memory result) {
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, 0x00)
            mstore(add(result, MAX_CAPACITY), sload(slot))

            let length := mload(result)
            let offset := add(result, 0x20)
            let guard := add(offset, length)

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    mstore(offset, sload(slot))
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, guard)) { break }
                    slot := add(slot, 0x01)
                }
            }

            mstore(guard, 0x00)
            mstore(0x40, add(guard, 0x20))
        }
    }

    /// @notice Stores `value` at location `slot` in persistent storage
    function sstore(StringSlot slot, string memory value) internal {
        assembly ("memory-safe") {
            let length := mload(value)
            if gt(length, LENGTH_MASK) {
                mstore(0x00, 0x06045ade) // ExceededMaxDataLength()
                revert(0x1c, 0x04)
            }

            let offset := add(value, 0x20)
            sstore(slot, mload(sub(offset, LENGTH_SIZE)))

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)

                let guard := sub(add(offset, length), 0x01)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    sstore(slot, mload(offset))
                    offset := add(offset, 0x20)
                    if gt(offset, guard) { break }
                    slot := add(slot, 0x01)
                }
            }
        }
    }

    /// @notice Gets the length of string data stored at `slot` in transient storage
    function tlength(StringSlot slot) internal view returns (uint256 length) {
        assembly ("memory-safe") {
            length := shr(LENGTH_SHIFT, tload(slot))
        }
    }

    /// @notice Loads the value held at location `slot` in transient storage
    function tload(StringSlot slot) internal view returns (string memory result) {
        assembly ("memory-safe") {
            result := mload(0x40)
            mstore(result, 0x00)
            mstore(add(result, MAX_CAPACITY), tload(slot))

            let length := mload(result)
            let offset := add(result, 0x20)
            let guard := add(offset, length)

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    mstore(offset, tload(slot))
                    offset := add(offset, 0x20)
                    if iszero(lt(offset, guard)) { break }
                    slot := add(slot, 0x01)
                }
            }

            mstore(guard, 0x00)
            mstore(0x40, add(guard, 0x20))
        }
    }

    /// @notice Stores `value` at location `slot` in transient storage
    function tstore(StringSlot slot, string memory value) internal {
        assembly ("memory-safe") {
            let length := mload(value)
            if gt(length, LENGTH_MASK) {
                mstore(0x00, 0x06045ade) // ExceededMaxDataLength()
                revert(0x1c, 0x04)
            }

            let offset := add(value, 0x20)
            tstore(slot, mload(sub(offset, LENGTH_SIZE)))

            if gt(length, MAX_CAPACITY) {
                mstore(0x00, slot)
                slot := keccak256(0x00, 0x20)

                let guard := sub(add(offset, length), 0x01)
                offset := add(offset, MAX_CAPACITY)

                for {} 0x01 {} {
                    tstore(slot, mload(offset))
                    offset := add(offset, 0x20)
                    if gt(offset, guard) { break }
                    slot := add(slot, 0x01)
                }
            }
        }
    }

    /// @notice Clears the value at location `slot` in transient storage
    function tclear(StringSlot slot) internal {
        assembly ("memory-safe") {
            tstore(slot, 0x00)
        }
    }

    /// @notice Checks whether the transient storage at `slot` is empty
    function isEmpty(StringSlot slot) internal view returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(tload(slot))
        }
    }
}
