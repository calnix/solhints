# Things to note when using delegatecall

DelegateCall basically copies the logic from the implementation contract, and applies it to the state of the calling contract.
Therefore, the value of address(this), msg.sender, and msg.value do not change their values.

## Common pitfalls

### 1) Managing the state variable layout between the calling contract and the target contract:

- it is important for the calling contract and the target contract to have the same state variable layout for any state variables that are read from or written to by both contracts.
- This ensures that both contracts access state variables in the same order, preventing issues such as overwriting or misinterpreting each other’s state variables.

### 2) delegatecall called on an EOA it will return a true status value

- EOA has no code
- This behavior can cause bugs if the code expects delegatecall functions to return false when they cannot execute.

If there is any uncertainty as to whether the address will always contain code, it's important to check and revert if the address does not contain code.

```java
function hasCode(address _address) internal view returns (bool) {
    uint256 codeSize;
    assembly { codeSize := extcodesize(_address) }
    return codeSize > 0;
}
```

### 3) delegatecall() does not return the execution outcome but converts the value returned by the function called to a boolean instead

- The return value of the delegate call is simply the data interpreted as a Boolean.
- If the parameter function returns at least 32 zero bytes, the delegate call will always return false even if the call did not throw an exception.
- 