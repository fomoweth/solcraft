// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

type Currency is address;

using {eq as ==, neq as !=, gt as >, gte as >=, lt as <, lte as <=} for Currency global;
using CurrencyLibrary for Currency global;

function eq(Currency x, Currency y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := eq(x, y)
    }
}

function neq(Currency x, Currency y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := iszero(eq(x, y))
    }
}

function gt(Currency x, Currency y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := gt(x, y)
    }
}

function gte(Currency x, Currency y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := iszero(lt(x, y))
    }
}

function lt(Currency x, Currency y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := lt(x, y)
    }
}

function lte(Currency x, Currency y) pure returns (bool z) {
    assembly ("memory-safe") {
        z := iszero(gt(x, y))
    }
}

/// @title CurrencyLibrary
/// @notice Provides the interactions of ERC-20 and native tokens for {Currency}.
/// @dev Modified from https://github.com/Uniswap/v4-core/blob/main/src/types/Currency.sol
/// @dev Reference: https://github.com/Vectorized/solady/blob/main/src/utils/SafeTransferLib.sol
/// @author fomoweth
library CurrencyLibrary {
    /// @notice Thrown when the provided currency is invalid.
    error InvalidCurrency();

    /// @notice Thrown when an ERC-20 `approve` operation has failed.
    error ApprovalFailed();

    /// @notice Thrown when an ERC-20 `transfer` operation has failed.
    error TransferFailed();

    /// @notice Thrown when a native token `transfer` has failed.
    error TransferNativeFailed();

    /// @notice Thrown when an ERC-20 `transferFrom` operation has failed.
    error TransferFromFailed();

    /// @notice Thrown when a native token `transferFrom` has failed.
    error TransferFromNativeFailed();

    /// @notice Thrown when an ERC-20 `permit` operation has failed.
    error PermitFailed();

    /// @notice Thrown when an ERC-20 `decimals` query has failed.
    error DecimalsQueryFailed();

    /// @notice Thrown when an ERC-20 `nonces` query has failed.
    error NonceQueryFailed();

    /// @notice Thrown when an ERC-20 `totalSupply` query has failed.
    error TotalSupplyQueryFailed();

    /// @notice The unique EIP-712 domain separator for the DAI token.
    bytes32 private constant DAI_DOMAIN_SEPARATOR = 0xdbb8cf42e1ecb028be3f3dbc922e1d878b963f411dc388ced501601c60f7c6f7;

    /// @notice The canonical address of the native token.
    address private constant NATIVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice A constant to represent the native currency.
    Currency internal constant NATIVE = Currency.wrap(NATIVE_ADDRESS);

    /// @notice A constant to represent the zero currency.
    Currency internal constant ZERO = Currency.wrap(address(0));

    /// @notice Sets the calling contract's allowance toward `spender` to `value`.
    /// @dev If the initial approval fails, attempts to reset the allowance to zero, then retries the approval again.
    function approve(Currency currency, address spender, uint256 value) internal {
        assembly ("memory-safe") {
            if extcodesize(currency) {
                mstore(0x00, 0x095ea7b3000000000000000000000000) // approve(address,uint256)
                mstore(0x14, spender)
                mstore(0x34, value)

                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), currency, 0x00, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x34, 0x00)
                    pop(call(gas(), currency, 0x00, 0x10, 0x44, codesize(), 0x00))
                    mstore(0x34, value)

                    if iszero(
                        and(
                            or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                            call(gas(), currency, 0x00, 0x10, 0x44, 0x00, 0x20)
                        )
                    ) {
                        mstore(0x00, 0x8164f842) // ApprovalFailed()
                        revert(0x1c, 0x04)
                    }
                }

                mstore(0x34, 0x00)
            }
        }
    }

    /// @notice Transfers `value` amount of tokens from the calling contract to `recipient`.
    function transfer(Currency currency, address recipient, uint256 value) internal {
        assembly ("memory-safe") {
            switch iszero(extcodesize(currency))
            case 0x00 {
                mstore(0x00, 0xa9059cbb000000000000000000000000) // transfer(address,uint256)
                mstore(0x14, recipient)
                mstore(0x34, value)

                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), currency, 0x00, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x90b8ec18) // TransferFailed()
                    revert(0x1c, 0x04)
                }

                mstore(0x34, 0x00)
            }
            default {
                if iszero(call(gas(), recipient, value, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb06a467a) // TransferNativeFailed()
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @notice Transfers `value` amount of tokens from `sender` to `recipient`, spending the approval given by `sender`
    /// 		to the calling contract.
    function transferFrom(Currency currency, address sender, address recipient, uint256 value) internal {
        assembly ("memory-safe") {
            switch iszero(extcodesize(currency))
            case 0x00 {
                let ptr := mload(0x40)
                mstore(0x0c, 0x23b872dd000000000000000000000000) // transferFrom(address,address,uint256)
                mstore(0x2c, shl(0x60, sender))
                mstore(0x40, recipient)
                mstore(0x60, value)

                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), currency, 0x00, 0x1c, 0x64, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x7939f424) // TransferFromFailed()
                    revert(0x1c, 0x04)
                }

                mstore(0x40, ptr)
                mstore(0x60, 0x00)
            }
            default {
                if or(lt(callvalue(), value), or(iszero(eq(sender, caller())), iszero(eq(recipient, address())))) {
                    mstore(0x00, 0xa20c5180) // TransferFromNativeFailed()
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @notice Sets `value` as the allowance of `spender` over `owner`'s tokens, given `owner`'s signed approval.
    function permit(
        Currency currency,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        assembly ("memory-safe") {
            mstore(0x00, 0x3644e515) // DOMAIN_SEPARATOR()

            if iszero(
                and(
                    lt(iszero(mload(0x00)), eq(returndatasize(), 0x20)),
                    staticcall(5000, currency, 0x1c, 0x04, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0xf5993428) // InvalidCurrency()
                revert(0x1c, 0x04)
            }

            let ptr := mload(0x40)
            mstore(add(ptr, 0x20), shr(0x60, shl(0x60, owner)))
            mstore(add(ptr, 0x40), shr(0x60, shl(0x60, spender)))
            mstore(add(ptr, 0x80), deadline)

            switch eq(mload(0x00), DAI_DOMAIN_SEPARATOR)
            case 0x01 {
                mstore(ptr, 0x7ecebe00) // nonces(address)
                pop(staticcall(gas(), currency, add(ptr, 0x1c), 0x24, add(ptr, 0x60), 0x20))

                mstore(ptr, 0x8fcbaf0c) // permit(address,address,uint256,uint256,bool,uint8,bytes32,bytes32)
                mstore(add(ptr, 0xa0), iszero(iszero(value)))
                mstore(add(ptr, 0xc0), and(0xff, v))
                mstore(add(ptr, 0xe0), r)
                mstore(add(ptr, 0x100), s)

                if iszero(call(gas(), currency, 0x00, add(ptr, 0x1c), 0x104, codesize(), 0x00)) {
                    mstore(0x00, 0xb78cb0dd) // PermitFailed()
                    revert(0x1c, 0x04)
                }
            }
            default {
                mstore(ptr, 0xd505accf) // permit(address,address,uint256,uint256,uint8,bytes32,bytes32)
                mstore(add(ptr, 0x60), value)
                mstore(add(ptr, 0xa0), and(0xff, v))
                mstore(add(ptr, 0xc0), r)
                mstore(add(ptr, 0xe0), s)

                if iszero(call(gas(), currency, 0x00, add(ptr, 0x1c), 0xe4, codesize(), 0x00)) {
                    mstore(0x00, 0xb78cb0dd) // PermitFailed()
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @notice Returns the remaining value that `spender` will be allowed to spend on behalf of `owner` through {transferFrom}.
    function allowance(Currency currency, address owner, address spender) internal view returns (uint256 result) {
        assembly ("memory-safe") {
            switch iszero(currency)
            case 0x00 {
                mstore(0x00, 0xdd62ed3e000000000000000000000000) // allowance(address,address)
                mstore(0x14, owner)
                mstore(0x34, spender)
                result := mul(
                    mload(0x20),
                    and(gt(returndatasize(), 0x1f), staticcall(gas(), currency, 0x10, 0x44, 0x20, 0x20))
                )
                mstore(0x34, 0x00)
            }
            default {
                result := not(0x00)
            }
        }
    }

    /// @notice Returns the value of tokens owned by `account`.
    function balanceOf(Currency currency, address account) internal view returns (uint256 result) {
        assembly ("memory-safe") {
            switch iszero(extcodesize(currency))
            case 0x00 {
                mstore(0x00, 0x70a08231000000000000000000000000) // balanceOf(address)
                mstore(0x14, account)
                result := mul(
                    mload(0x20),
                    and(gt(returndatasize(), 0x1f), staticcall(gas(), currency, 0x10, 0x24, 0x20, 0x20))
                )
            }
            default {
                result := balance(account)
            }
        }
    }

    /// @notice Returns the value of tokens owned by the calling contract.
    function balanceOfSelf(Currency currency) internal view returns (uint256 result) {
        assembly ("memory-safe") {
            switch iszero(extcodesize(currency))
            case 0x00 {
                mstore(0x00, 0x70a08231000000000000000000000000) // balanceOf(address)
                mstore(0x14, address())
                result := mul(
                    mload(0x20),
                    and(gt(returndatasize(), 0x1f), staticcall(gas(), currency, 0x10, 0x24, 0x20, 0x20))
                )
            }
            default {
                result := selfbalance()
            }
        }
    }

    /// @notice Returns the current nonce for `account`.
    function nonces(Currency currency, address account) internal view returns (uint256 result) {
        assembly ("memory-safe") {
            if iszero(extcodesize(currency)) {
                mstore(0x00, 0xf5993428) // InvalidCurrency()
                revert(0x1c, 0x04)
            }

            mstore(0x00, 0x7ecebe00000000000000000000000000) // nonces(address)
            mstore(0x14, account)

            if iszero(and(gt(returndatasize(), 0x1f), staticcall(gas(), currency, 0x10, 0x24, 0x20, 0x20))) {
                mstore(0x00, 0xb6abcf59) // NonceQueryFailed()
                revert(0x1c, 0x04)
            }

            result := mload(0x20)
        }
    }

    /// @notice Returns the decimal places of the `currency`.
    function decimals(Currency currency) internal view returns (uint8 result) {
        assembly ("memory-safe") {
            switch iszero(extcodesize(currency))
            case 0x00 {
                mstore(0x00, 0x313ce567) // decimals()

                if iszero(and(gt(returndatasize(), 0x1f), staticcall(gas(), currency, 0x1c, 0x04, 0x00, 0x20))) {
                    mstore(0x00, 0x1eecbb65) // DecimalsQueryFailed()
                    revert(0x1c, 0x04)
                }

                result := mload(0x00)
            }
            default {
                result := 0x12
            }
        }
    }

    /// @notice Returns the current total supply of the `currency`.
    function totalSupply(Currency currency) internal view returns (uint256 result) {
        assembly ("memory-safe") {
            if iszero(extcodesize(currency)) {
                mstore(0x00, 0xf5993428) // InvalidCurrency()
                revert(0x1c, 0x04)
            }

            mstore(0x00, 0x18160ddd)

            if iszero(and(gt(returndatasize(), 0x1f), staticcall(gas(), currency, 0x1c, 0x04, 0x00, 0x20))) {
                mstore(0x00, 0x54cd9435) // TotalSupplyQueryFailed()
                revert(0x1c, 0x04)
            }

            result := mload(0x00)
        }
    }

    function isNative(Currency currency) internal pure returns (bool result) {
        assembly ("memory-safe") {
            result := or(iszero(shl(0x60, currency)), eq(currency, NATIVE_ADDRESS))
        }
    }

    function isZero(Currency currency) internal pure returns (bool result) {
        assembly ("memory-safe") {
            result := iszero(shl(0x60, currency))
        }
    }

    function toAddress(Currency currency) internal pure returns (address result) {
        assembly ("memory-safe") {
            result := currency
        }
    }

    function toId(Currency currency) internal pure returns (uint256 id) {
        assembly ("memory-safe") {
            id := shr(0x60, shl(0x60, currency))
        }
    }

    function fromId(uint256 id) internal pure returns (Currency currency) {
        assembly ("memory-safe") {
            currency := id
        }
    }
}
