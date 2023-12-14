# Gas Golfing

## Use delete instead of reassigning the default value

```java
uint internal count;

delete count; // Clears count to the default uint value (0)
```

You get a gas refund when you ‘empty out’ variables.
Deleting has the same effect as reassigning the value type with the default value, such as the zero address for addresses and 0 for integers.
Deleting a variable refunds 15,000 gas up to a maximum of half the gas cost of the transaction.

## Use constant and immutable keywords

Reading constant and immutable variables is no longer considered a storage read (SSTORE),
because it uses EXTCODE* opcodes instead which is much cheaper.

## Cache storage values in memory

Anytime you are reading from storage more than once, it is cheaper to cache variables in memory. 
An SLOAD cost 100 GAS while MLOAD and MSTORE only cost 3 GAS.

This is especially true in for loops when using the length of a storage array as the condition being checked after each loop.

## Splitting require statements that use && saves gas

```java
// Before
require(result >= MIN_64x64 && result <= MAX_64x64);

// After
require(result >= MIN_64x64);
require(result <= MAX_64x64);
```

## ++i costs less gas compared to i++ or i += 1

++i costs less gas compared to i++ or i += 1 for an unsigned integer, as pre-increment is cheaper (about 5 gas per iteration).

- i++ increments i and returns the initial value of i
- ++i returns the actual incremented value.

# OUTDATED

## Gas costs: internal < external < public 

There is no difference in Gas Cost Between Public/External/Internal/Private for Variables and Functions.

- It’s still better to define function visibility strictly because of security reasons, but it won’t affect gas usage.
- But it would affect deployment gas costs for such functions.
- There is no difference in internal and private functions in deployment gas cost.

Public variables cost the same amount as the internal and private ones to read.

- But variable visibility affects the deployed gas.
- public variables cost more than private or internal, but there is no difference in deployment gas cost between private and internal.

## Don’t make variables public unless it is necessary to do so

A public storage variable has an implicit public function of the same name. 
A public function increases the size of the jump table and adds bytecode to read the variable in question. 

That makes the contract larger.

## > 0 is more expensive than != 0 for unsigned integers

!= 0 costs 6 less GAS compared to > 0 for unsigned integers in require statements with the optimizer enabled.
operations like >=, <= would cost 6 gas because of the two operations LT/GT + EQ = 6 gas. 

> Somewhere around solidity 0.8.12 or so, this stopped being true. If you are forced to use an old version, you can still benchmark it.