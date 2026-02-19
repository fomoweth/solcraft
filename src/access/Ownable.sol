// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Ownable
/// @notice Provides a basic access control mechanism.
/// @author fomoweth
abstract contract Ownable {
    /// @notice Thrown when the provided owner address is invalid.
    error InvalidNewOwner();

    /// @notice Thrown when unauthorized account attempts restricted operation.
    error Unauthorized();

    /// @notice Emitted when the ownership is transferred from `previousOwner` to `newOwner`.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Precomputed keccak256 hash of the {OwnershipTransferred} event signature.
    /// @dev Equivalent to `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    bytes32 private constant OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @notice Precomputed keccak256 hash of the storage slot for owner.
    /// @dev Equivalent to `keccak256(abi.encode(uint256(keccak256("OWNER_SLOT")) - 1)) & ~bytes32(uint256(0xff))`.
    bytes32 internal constant OWNER_SLOT = 0x17350785e853da06f8ebd8841784c87c4db47e187312ef795d78f6789f351a00;

    /// @notice Throws if called by any account other than the owner.
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /// @notice Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        assembly ("memory-safe") {
            result := sload(OWNER_SLOT)
        }
    }

    /// @notice Transfers ownership of the contract to a new account.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        _checkNewOwner(newOwner);
        _transferOwnership(newOwner);
    }

    /// @notice Leaves the contract without owner.
    function renounceOwnership() public payable virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /// @notice Transfers ownership of the contract without access restriction.
    function _transferOwnership(address newOwner) internal virtual {
        assembly ("memory-safe") {
            newOwner := shr(0x60, shl(0x60, newOwner))
            log3(0x00, 0x00, OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(OWNER_SLOT), newOwner)
            sstore(OWNER_SLOT, newOwner)
        }
    }

    /// @notice Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        assembly ("memory-safe") {
            if iszero(eq(caller(), sload(OWNER_SLOT))) {
                mstore(0x00, 0x82b42900) // Unauthorized()
                revert(0x1c, 0x04)
            }
        }
    }

    /// @notice Throws if the given new owner is zero address.
    function _checkNewOwner(address newOwner) internal view virtual {
        assembly ("memory-safe") {
            if iszero(shl(0x60, newOwner)) {
                mstore(0x00, 0x54a56786) // InvalidNewOwner()
                revert(0x1c, 0x04)
            }
        }
    }
}
