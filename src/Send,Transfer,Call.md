## transfer() and send() be avoided.

- Since its introduction, transfer() has typically been recommended by the security community because it helps guard against reentrancy attacks.
- This guidance made sense under the assumption that gas costs wouldn’t change, but that assumption turned out to be incorrect. 
- We now recommend that transfer() and send() be avoided.

Any smart contract that uses transfer() or send() is taking a hard dependency on gas costs by forwarding a fixed amount of gas: 2300.

EIP 1884 increases the gas cost of SLOAD. Other future EIPs might modify gas costs of opcodes as well.
This will break some smart contracts, because their fallback functions now consume more than 2300 gas, which is all that is afforded by transfer or send.

With insufficient gas, such transactions will fail.

## Use call

stop using transfer() and send() in your code and switch to using call() instead:

```java
contract Vulnerable {
    function withdraw(uint256 amount) external {
        // This forwards 2300 gas, which may not be enough if the recipient
        // is a contract and gas costs change.
        msg.sender.transfer(amount);
    }
}

contract Fixed {
    function withdraw(uint256 amount) external {
        // This forwards all available gas. Be sure to check the return value!
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Transfer failed.");
    }
}
```

## What About Reentrancy?

- The whole reason transfer() and send() were introduced was to address the cause of the infamous hack on The DAO.
- The idea was that 2300 gas is enough to emit a log entry but insufficient to make a reentrant call that then modifies storage.
- But if gas costs are subject to change, which means this is a bad way to address reentrancy anyway.

## Solutions
- Checks-Effects-Interactions Pattern
- Use a Reentrancy Guard
- FREi-PI: global invariant require statments. x*y=k