// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {BitMap} from "src/types/BitMap.sol";

contract BitMapTest is Test {
    function test_fuzz_set(BitMap x, uint8 i) public pure {
        assertTrue(x.set(i).get(i));
    }

    function test_fuzz_unset(BitMap x, uint8 i) public pure {
        assertFalse(x.unset(i).get(i));
    }

    function test_fuzz_setTo(BitMap x, uint8 i) public pure {
        bool value = x.get(i);
        x = x.setTo(i, !value);
        assertEq(x.get(i), !value);
        x = x.setTo(i, value);
        assertEq(x.get(i), value);
    }

    function test_fuzz_toggle(BitMap x, uint8 i) public pure {
        bool value = x.get(i);
        x = x.toggle(i);
        assertEq(x.get(i), !value);
        x = x.toggle(i);
        assertEq(x.get(i), value);
    }

    function test_count() public pure {
        unchecked {
            for (uint256 i = 1; i < 256; ++i) {
                assertEq(BitMap.wrap(uint256((1 << i) | 1)).count(), 2);
            }
        }
    }

    function test_fuzz_count(BitMap x) public pure {
        uint256 c;
        unchecked {
            for (uint256 t = BitMap.unwrap(x); t != 0; ++c) {
                t &= t - 1;
            }
        }
        assertEq(x.count(), c);
    }

    function test_findFirstSet_powersOfTwo() public pure {
        for (uint256 i = 1; i < 256; ++i) {
            assertEq(BitMap.wrap(1 << i).findFirstSet(), i);
        }
    }

    function test_fuzz_findFirstSet(BitMap x) public pure {
        assertEq(x.findFirstSet(), leastSignificantBitReference(BitMap.unwrap(x)));
    }

    function test_findLastSet_powersOfTwo() public pure {
        for (uint256 i = 1; i < 255; ++i) {
            assertEq(BitMap.wrap(1 << i).findLastSet(), i);
        }
    }

    function test_fuzz_findLastSet(BitMap x) public pure {
        assertEq(x.findLastSet(), mostSignificantBitReference(BitMap.unwrap(x)));
    }

    function test_isEmpty() public pure {
        assertTrue(BitMap.wrap(0).isEmpty());
        assertFalse(BitMap.wrap(1).isEmpty());
    }

    function mostSignificantBitReference(uint256 x) private pure returns (uint256 i) {
        unchecked {
            if (x == 0) return 256;
            while ((x >>= 1) > 0) {
                ++i;
            }
        }
    }

    function leastSignificantBitReference(uint256 x) private pure returns (uint256 i) {
        unchecked {
            if (x == 0) return 256;
            while ((x >> i) & 1 == 0) {
                ++i;
            }
        }
    }
}
