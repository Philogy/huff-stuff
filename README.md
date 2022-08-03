# Huff Stuff

A collection of heavily optimized Huff contrats.

## ERC20
Source: `ERC20.huff`

### ERC20 - General Usage

**Basic Macros:**

The `_ERC20_SELECTOR_SWITCH` macro inserts the ERC20 selector switch into your
code. It takes 1 stack argument, the selector and returns it, meaning the macro
can seamlessly be added to an existing selector switch. Example:

```huff
GET_SELECTOR()
dup1 __FUNC_SIG(mint) eq mint jumpi
dup1 _ERC20_SELECTOR_SWITCH(decimals, symbol, name)
__FUNC_SIG(burn) eq burn jumpi
}
```

The `_ERC20_SELECTOR_SWITCH` macro takes the token's decimals and 2 jump labels
as macro arguments. The first jump label being the ERC20 symbol return logic and
the second the name.

**Minting / Burning:**

In order to mint/burn tokens in the constructor or elsewhere use the
`ERC20_SAFE_BURN` and `ERC20_SAFE_MINT` macros. They take 2 stack arguments:
\[amount, account\]. They're called "safe" because they do overflow / underflow
checking, meaning that if only these methods are used to adjust the supply it
will not not overflow.

The two macros also take 2 macro arguments `mem1` and `mem2`. These are meant to be free memory pointers whereby `mem2 = 0x20 + mem1`, `mem2` is passed as a macro argument to avoid having to calculate it via `0x20 add` at runtime.

**Other Macros:**

The `ERC20.huff` library currently has no other internal macros for retrieving
balance / allowance / total supply internally. They may however be added in the
future.

**Storage layout:**
Variable|Slot
------|------
totalSupply|`SLOT_TOTAL_SUPPLY`
balanceOf(account)|`keccak256(SLOT_BALANCE_OF . account)`
allowance(owner, spender)|`keccak256(SLOT_ALLOWANCE . spender . owner)`

