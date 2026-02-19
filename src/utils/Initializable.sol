// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Initializable
/// @notice Initializable mixin for upgradeable contracts.
/// @author fomoweth
abstract contract Initializable {
    /// @notice Thrown when initialization is attempted in invalid state.
    error InvalidInitialization();

    /// @notice Thrown when a function requires initializing state but contract is not initializing.
    error NotInitializing();

    /// @notice Emitted when the contract is initialized to a specific version.
    event Initialized(uint64 version);

    /// @notice Precomputed keccak256 hash of the {Initialized} event signature.
    ///	@dev Equivalent to `keccak256("Initialized(uint64)")`.
    bytes32 private constant INITIALIZED_EVENT_SIGNATURE =
        0xc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d2;

    /// @notice Precomputed keccak256 hash of the storage slot for initialization.
    /// @dev Equivalent to `bytes32(~uint256(uint32(bytes4(keccak256("INITIALIZATION_SLOT")))))`.
    bytes32 private constant INITIALIZATION_SLOT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff865973bc;

    /// @notice Maximum initialization version number.
    /// @dev Used as a sentinel value to permanently disable initializers.
    uint64 private constant MAX_VERSION = (1 << 64) - 1;

    /// @notice Guards an initializer function so that can be invoked at most once.
    /// @dev Emits an {Initialized} event.
    modifier initializer() {
        bool isTopLevelCall;
        assembly ("memory-safe") {
            let initialization := sload(INITIALIZATION_SLOT)
            sstore(INITIALIZATION_SLOT, 0x03)

            isTopLevelCall := iszero(and(initialization, 0x01))

            if initialization {
                if iszero(lt(extcodesize(address()), eq(shr(0x01, initialization), 0x01))) {
                    mstore(0x00, 0xf92ee8a9) // InvalidInitialization()
                    revert(0x1c, 0x04)
                }
            }
        }
        _;
        assembly ("memory-safe") {
            if isTopLevelCall {
                sstore(INITIALIZATION_SLOT, 0x02)
                mstore(0x20, 0x01)
                log1(0x20, 0x20, INITIALIZED_EVENT_SIGNATURE)
            }
        }
    }

    /// @notice Guards a reinitializer function so that can be invoked at most once.
    /// @dev Emits an {Initialized} event.
    modifier reinitializer(uint64 version) {
        assembly ("memory-safe") {
            version := shl(0x01, and(version, MAX_VERSION))
            let initialization := sload(INITIALIZATION_SLOT)

            if iszero(lt(and(initialization, 0x01), lt(initialization, version))) {
                mstore(0x00, 0xf92ee8a9) // InvalidInitialization()
                revert(0x1c, 0x04)
            }

            sstore(INITIALIZATION_SLOT, or(0x01, version))
        }
        _;
        assembly ("memory-safe") {
            sstore(INITIALIZATION_SLOT, version)
            mstore(0x20, shr(0x01, version))
            log1(0x20, 0x20, INITIALIZED_EVENT_SIGNATURE)
        }
    }

    /// @notice Guards a function so that it can only be invoked in the scope of functions
    /// 		with the {initializer} and {reinitializer} modifiers, directly or indirectly.
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /// @notice Reverts if the contract is not in an initializing state.
    function _checkInitializing() internal view virtual {
        assembly ("memory-safe") {
            if iszero(and(0x01, sload(INITIALIZATION_SLOT))) {
                mstore(0x00, 0xd7e6bcf8) // NotInitializing()
                revert(0x1c, 0x04)
            }
        }
    }

    /// @notice Locks the contract, preventing any future initializations.
    /// @dev Emits an {Initialized} event the first time it is successfully executed.
    function _disableInitializers() internal virtual {
        assembly ("memory-safe") {
            let initialization := sload(INITIALIZATION_SLOT)

            if and(initialization, 0x01) {
                mstore(0x00, 0xf92ee8a9) // InvalidInitialization()
                revert(0x1c, 0x04)
            }

            if iszero(eq(shr(0x01, initialization), MAX_VERSION)) {
                sstore(INITIALIZATION_SLOT, shl(0x01, MAX_VERSION))
                mstore(0x20, MAX_VERSION)
                log1(0x20, 0x20, INITIALIZED_EVENT_SIGNATURE)
            }
        }
    }

    /// @notice Returns the highest version that has been initialized.
    function _getInitializedVersion() internal view virtual returns (uint64 version) {
        assembly ("memory-safe") {
            version := shr(0x01, sload(INITIALIZATION_SLOT))
        }
    }

    /// @notice Returns whether the contract is currently initializing or not.
    function _isInitializing() internal view virtual returns (bool result) {
        assembly ("memory-safe") {
            result := and(0x01, sload(INITIALIZATION_SLOT))
        }
    }
}
