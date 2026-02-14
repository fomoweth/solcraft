// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {
    AddressSlot,
    BooleanSlot,
    Bytes32Slot,
    Uint256Slot,
    Int256Slot,
    BytesSlot,
    StringSlot,
    StorageSlot
} from "src/types/StorageSlot.sol";

contract StorageSlotTest is Test {
    AddressSlot internal constant ADDRESS_SLOT = AddressSlot.wrap("ADDRESS_SLOT");
    BooleanSlot internal constant BOOLEAN_SLOT = BooleanSlot.wrap("BOOLEAN_SLOT");
    Bytes32Slot internal constant BYTES32_SLOT = Bytes32Slot.wrap("BYTES32_SLOT");
    Uint256Slot internal constant UINT256_SLOT = Uint256Slot.wrap("UINT256_SLOT");
    Int256Slot internal constant INT256_SLOT = Int256Slot.wrap("INT256_SLOT");
    BytesSlot internal constant BYTES_SLOT = BytesSlot.wrap("BYTES_SLOT");
    StringSlot internal constant STRING_SLOT = StringSlot.wrap("STRING_SLOT");

    function test_fuzz_persistent_storage_address(address value) public {
        assertSlotEmpty(ADDRESS_SLOT, false);
        testStore(ADDRESS_SLOT, value, false);
        testStore(ADDRESS_SLOT, address(0), false);
        assertSlotEmpty(ADDRESS_SLOT, false);
    }

    function test_fuzz_persistent_storage_boolean(bool value) public {
        assertSlotEmpty(BOOLEAN_SLOT, false);
        testStore(BOOLEAN_SLOT, value, false);
        testStore(BOOLEAN_SLOT, !value, false);
    }

    function test_fuzz_persistent_storage_bytes32(bytes32 value) public {
        assertSlotEmpty(BYTES32_SLOT, false);
        testStore(BYTES32_SLOT, value, false);
        testStore(BYTES32_SLOT, bytes32(0), false);
        assertSlotEmpty(BYTES32_SLOT, false);
    }

    function test_fuzz_persistent_storage_uint256(uint256 value) public {
        assertSlotEmpty(UINT256_SLOT, false);
        testStore(UINT256_SLOT, value, false);
        testStore(UINT256_SLOT, uint256(0), false);
        assertSlotEmpty(UINT256_SLOT, false);
    }

    function test_fuzz_persistent_storage_int256(int256 value) public {
        assertSlotEmpty(INT256_SLOT, false);
        testStore(INT256_SLOT, value, false);
        testStore(INT256_SLOT, int256(0), false);
        assertSlotEmpty(INT256_SLOT, false);
    }

    function test_fuzz_persistent_storage_bytes(bytes memory value) public {
        assertSlotEmpty(BYTES_SLOT, false);
        testStore(BYTES_SLOT, value, false);
        testStore(BYTES_SLOT, new bytes(0), false);
        assertSlotEmpty(BYTES_SLOT, false);
    }

    function test_fuzz_persistent_storage_string(string memory value) public {
        assertSlotEmpty(STRING_SLOT, false);
        testStore(STRING_SLOT, value, false);
        testStore(STRING_SLOT, new string(0), false);
        assertSlotEmpty(STRING_SLOT, false);
    }

    function test_fuzz_transient_storage_address(address value) public {
        assertSlotEmpty(ADDRESS_SLOT, true);
        testStore(ADDRESS_SLOT, value, true);
        ADDRESS_SLOT.tclear();
        assertSlotEmpty(ADDRESS_SLOT, true);
    }

    function test_fuzz_transient_storage_boolean(bool value) public {
        assertSlotEmpty(BOOLEAN_SLOT, true);
        testStore(BOOLEAN_SLOT, value, true);
        BOOLEAN_SLOT.tclear();
        assertSlotEmpty(BOOLEAN_SLOT, true);
    }

    function test_fuzz_transient_storage_bytes32(bytes32 value) public {
        assertSlotEmpty(BYTES32_SLOT, true);
        testStore(BYTES32_SLOT, value, true);
        BYTES32_SLOT.tclear();
        assertSlotEmpty(BYTES32_SLOT, true);
    }

    function test_fuzz_transient_storage_uint256(uint256 value) public {
        assertSlotEmpty(UINT256_SLOT, true);
        testStore(UINT256_SLOT, value, true);
        UINT256_SLOT.tclear();
        assertSlotEmpty(UINT256_SLOT, true);
    }

    function test_fuzz_transient_storage_int256(int256 value) public {
        assertSlotEmpty(INT256_SLOT, true);
        testStore(INT256_SLOT, value, true);
        INT256_SLOT.tclear();
        assertSlotEmpty(INT256_SLOT, true);
    }

    function test_fuzz_transient_storage_bytes(bytes memory value) public {
        assertSlotEmpty(BYTES_SLOT, true);
        testStore(BYTES_SLOT, value, true);
        BYTES_SLOT.tclear();
        assertSlotEmpty(BYTES_SLOT, true);
    }

    function test_fuzz_transient_storage_string(string memory value) public {
        assertSlotEmpty(STRING_SLOT, true);
        testStore(STRING_SLOT, value, true);
        STRING_SLOT.tclear();
        assertSlotEmpty(STRING_SLOT, true);
    }

    function testStore(AddressSlot slot, address value, bool isTransient) internal {
        if (isTransient) {
            slot.tstore(value);
            assertEq(slot.tload(), value);
        } else {
            slot.sstore(value);
            assertEq(slot.sload(), value);
        }
    }

    function testStore(BooleanSlot slot, bool value, bool isTransient) internal {
        if (isTransient) {
            slot.tstore(value);
            assertEq(slot.tload(), value);
        } else {
            slot.sstore(value);
            assertEq(slot.sload(), value);
        }
    }

    function testStore(Bytes32Slot slot, bytes32 value, bool isTransient) internal {
        if (isTransient) {
            slot.tstore(value);
            assertEq(slot.tload(), value);
        } else {
            slot.sstore(value);
            assertEq(slot.sload(), value);
        }
    }

    function testStore(Uint256Slot slot, uint256 value, bool isTransient) internal {
        if (isTransient) {
            slot.tstore(value);
            assertEq(slot.tload(), value);
        } else {
            slot.sstore(value);
            assertEq(slot.sload(), value);
        }
    }

    function testStore(Int256Slot slot, int256 value, bool isTransient) internal {
        if (isTransient) {
            slot.tstore(value);
            assertEq(slot.tload(), value);
        } else {
            slot.sstore(value);
            assertEq(slot.sload(), value);
        }
    }

    function testStore(BytesSlot slot, bytes memory value, bool isTransient) internal {
        if (value.length > StorageSlot.LENGTH_MASK) {
            vm.expectRevert(StorageSlot.ExceededMaxDataLength.selector);
            if (isTransient) slot.tstore(value);
            else slot.sstore(value);
            return;
        }

        if (isTransient) {
            slot.tstore(value);
            assertEq(slot.tlength(), value.length);
            assertEq(slot.tload(), value);
        } else {
            slot.sstore(value);
            assertEq(slot.slength(), value.length);
            assertEq(slot.sload(), value);
        }
    }

    function testStore(StringSlot slot, string memory value, bool isTransient) internal {
        if (bytes(value).length > StorageSlot.LENGTH_MASK) {
            vm.expectRevert(StorageSlot.ExceededMaxDataLength.selector);
            if (isTransient) slot.tstore(value);
            else slot.sstore(value);
            return;
        }

        if (isTransient) {
            slot.tstore(value);
            assertEq(slot.tlength(), bytes(value).length);
            assertEq(slot.tload(), value);
        } else {
            slot.sstore(value);
            assertEq(slot.slength(), bytes(value).length);
            assertEq(slot.sload(), value);
        }
    }

    function assertSlotEmpty(AddressSlot slot, bool isTransient) internal view {
        if (isTransient) {
            assertTrue(slot.isEmpty());
            assertEq(slot.tload(), address(0));
        } else {
            assertEq(slot.sload(), address(0));
        }
    }

    function assertSlotEmpty(BooleanSlot slot, bool isTransient) internal view {
        if (isTransient) {
            assertTrue(slot.isEmpty());
            assertEq(slot.tload(), false);
        } else {
            assertEq(slot.sload(), false);
        }
    }

    function assertSlotEmpty(Bytes32Slot slot, bool isTransient) internal view {
        if (isTransient) {
            assertTrue(slot.isEmpty());
            assertEq(slot.tload(), bytes32(0));
        } else {
            assertEq(slot.sload(), bytes32(0));
        }
    }

    function assertSlotEmpty(Uint256Slot slot, bool isTransient) internal view {
        if (isTransient) {
            assertTrue(slot.isEmpty());
            assertEq(slot.tload(), uint256(0));
        } else {
            assertEq(slot.sload(), uint256(0));
        }
    }

    function assertSlotEmpty(Int256Slot slot, bool isTransient) internal view {
        if (isTransient) {
            assertTrue(slot.isEmpty());
            assertEq(slot.tload(), int256(0));
        } else {
            assertEq(slot.sload(), int256(0));
        }
    }

    function assertSlotEmpty(BytesSlot slot, bool isTransient) internal view {
        if (isTransient) {
            assertTrue(slot.isEmpty());
            assertEq(slot.tlength(), uint256(0));
            assertEq(slot.tload(), new bytes(0));
        } else {
            assertEq(slot.slength(), uint256(0));
            assertEq(slot.sload(), new bytes(0));
        }
    }

    function assertSlotEmpty(StringSlot slot, bool isTransient) internal view {
        if (isTransient) {
            assertTrue(slot.isEmpty());
            assertEq(slot.tlength(), uint256(0));
            assertEq(slot.tload(), new string(0));
        } else {
            assertEq(slot.slength(), uint256(0));
            assertEq(slot.sload(), new string(0));
        }
    }
}
