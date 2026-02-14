// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

type BitMap is uint256;

using {
    eq as ==,
    neq as !=,
    gt as >,
    gte as >=,
    lt as <,
    lte as <=,
    and as &,
    or as |,
    xor as ^,
    not as ~
} for BitMap global;
using BitMapLibrary for BitMap global;

function eq(BitMap x, BitMap y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := eq(x, y)
    }
}

function neq(BitMap x, BitMap y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := iszero(eq(x, y))
    }
}

function gt(BitMap x, BitMap y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := gt(x, y)
    }
}

function gte(BitMap x, BitMap y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := iszero(lt(x, y))
    }
}

function lt(BitMap x, BitMap y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := lt(x, y)
    }
}

function lte(BitMap x, BitMap y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := iszero(gt(x, y))
    }
}

function and(BitMap x, BitMap y) pure returns (BitMap z) {
    assembly ("memory-safe") {
        z := and(x, y)
    }
}

function or(BitMap x, BitMap y) pure returns (BitMap z) {
    assembly ("memory-safe") {
        z := or(x, y)
    }
}

function xor(BitMap x, BitMap y) pure returns (BitMap z) {
    assembly ("memory-safe") {
        z := xor(x, y)
    }
}

function not(BitMap x) pure returns (BitMap z) {
    assembly ("memory-safe") {
        z := not(x)
    }
}

/// @title BitMapLibrary
/// @notice Bit-level manipulation utilities for a 256-bit bitmap
/// @author fomoweth
library BitMapLibrary {
    /// @notice Sets the bit at a given index to 1 and returns the updated `x`
    function set(BitMap x, uint8 i) internal pure returns (BitMap z) {
        assembly ("memory-safe") {
            z := or(x, shl(i, 0x01))
        }
    }

    /// @notice Sets the bit at a given index to 0 and returns the updated `x`
    function unset(BitMap x, uint8 i) internal pure returns (BitMap z) {
        assembly ("memory-safe") {
            z := and(x, not(shl(i, 0x01)))
        }
    }

    /// @notice Sets the bit at a given index to a specific value and returns the updated `x`
    function setTo(BitMap x, uint8 i, bool b) internal pure returns (BitMap z) {
        assembly ("memory-safe") {
            z := or(and(x, not(shl(i, 0x01))), shl(i, iszero(iszero(b))))
        }
    }

    /// @notice Flips the bit at a given index and returns the updated `x`
    function toggle(BitMap x, uint8 i) internal pure returns (BitMap z) {
        assembly ("memory-safe") {
            z := or(and(x, not(shl(i, 0x01))), shl(i, iszero(and(x, shl(i, 0x01)))))
        }
    }

    /// @notice Reads the bit at a given index
    function get(BitMap x, uint8 i) internal pure returns (bool z) {
        assembly ("memory-safe") {
            z := and(x, shl(i, 0x01))
        }
    }

    /// @notice Counts the number of bits set to 1 in the `x`
    function count(BitMap x) internal pure returns (uint256 r) {
        // forgefmt: disable-next-item
        assembly ("memory-safe") {
            r := sub(x, and(shr(1, x), 0x5555555555555555555555555555555555555555555555555555555555555555))
            r := add(and(r, 0x3333333333333333333333333333333333333333333333333333333333333333), 
                and(shr(2, r), 0x3333333333333333333333333333333333333333333333333333333333333333))
            r := and(add(r, shr(4, r)), 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F)
            r := or(shl(8, eq(x, not(0))), shr(248, mul(r, 0x101010101010101010101010101010101010101010101010101010101010101)))
        }
    }

    /// @notice Finds the index of the most significant bit set to 1, returns 256 if `x` is empty
    function findLastSet(BitMap x) internal pure returns (uint256 r) {
        // forgefmt: disable-next-item
        assembly ("memory-safe") {
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0x0706060506020504060203020504030106050205030304010505030400000000))
        }
    }

    /// @notice Finds the index of the least significant bit set to 1, returns 256 if `x` is empty
    function findFirstSet(BitMap x) internal pure returns (uint256 r) {
        // forgefmt: disable-next-item
        assembly ("memory-safe") {
            x := and(x, add(not(x), 1))
            r := shl(5, shr(252, shl(shl(2, shr(250, mul(x,
                0xb6db6db6ddddddddd34d34d349249249210842108c6318c639ce739cffffffff))),
                0x8040405543005266443200005020610674053026020000107506200176117077)))
            r := or(r, byte(and(div(0xd76453e0, shr(r, x)), 0x1f),
                0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
        }
    }

    /// @notice Checks if the `x` is zero (all bits unset)
    function isEmpty(BitMap x) internal pure returns (bool z) {
        assembly ("memory-safe") {
            z := iszero(x)
        }
    }
}
