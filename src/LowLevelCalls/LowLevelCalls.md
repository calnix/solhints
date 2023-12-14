# Low-level calls

- call
- delegateCall
- staticCall

Low-level calls use the call(), staticcall(), or delegatecall() methods on an address type, and we must ABI-encode the call data (which encodes the function to call and the parameters) ourselves.
Instead of reverting if the call fails, you get back a tuple (bool success, bytes returnOrRevertData), where the meaning of returnOrRevertData depends on whether the function succeeded or not.

```java
(bool success, bytes memory returnOrRevertData) = address(someContract).call(
    // Encode the call data (function on someContract to call + arguments)
    abi.encodeCall(someContract.someFunction, (arg1, arg2))
);
if (success) {
    // Process `returnOrRevertData` as encoded return data.
    uint256 someResult = abi.decode(returnOrRevertData, (uint256));
} else {
    // Process `returnOrRevertData` as encoded revert data.
}
```

- if success, the return data is the whatever the called return data is.
- if failed, the return data is the revert data, should there be one.

## Low-level calls do not revert

It is important to note that low-level `call` or `delegatecall` does not revert, while calling a function that reverts:

```java
  function bar() external {
    revert AccessForbidden(msg.sender);
  }

    // assume these call bar() on another contract
    // These won't revert even if the target contract reverts!
    (bool success, bytes memory result) = target.call(data);
    (bool success, bytes memory result) = target.delegatecall(data);
```

The `success` variable signals whether the call was successful (true) or unsuccessful (false).
Using this, we could revert in the calling contract like so:

```java
    (bool success, bytes memory result) = target.delegatecall(data);
    require(success);
```

This is why `require(success)` is a very important pairing with low-level calls.

## Bubbling up errors

- However, the above code swallows any errors returned from the target contract. 
- We don’t know what went wrong because no errors are bubbled up even though contract B reverts.
- We just know if it failed, but not WHY it failed.

### Error-handling example

```java

(bool success, bytes memory result) = address(this).delegatecall(data);

// If call reverts
if (!success) { 
  // If there is no return data, the call reverted without a reason or custom error.
  if (result.length == 0) revert();

  assembly {
    // use Yul's revert() to bubble up errors from the target contract.
    // revert(pointer, arrayLength)
    revert(add(32, result), mload(result))
  }
}
```

- If the external contract call fails, the error object is returned in result. 
- `result` is a dynamic-size byte array.

The Yul revert function takes in two inputs:
    1) pointer of where the error byte array starts,
    2) how long the byte array is.

For dynamic-size byte arrays, the first 32 bits of the pointer stores its size.
    To fill in 1), we do add(32, result) to calculate the pointer where the byte array starts.
    To fill in 2), we do mload(result) to retrieve this value.

|---32bits: length of array|--- array starts here-----|
 mload loads the first 32 bits, which is the length of the array. 
 then we add 32 bits to move past the length, to point to where the values actually start.

When there is no revert data returned by the target contract, we terminate early with an empty revert.

## Handling return values

use abi.decode(...)

```java
    function delegatecallSetN(address _e, uint _n) public returns (uint, bytes32, uint, string memory) {
        bytes memory data = abi.encodeWithSelector(bytes4(keccak256("setN(uint256)")), _n);
     
        (bool success, bytes memory returnedData) = _e.delegatecall(data);
        require(success);
     
        return abi.decode(returnedData, (uint, bytes32, uint, string));
    }
```


## Calldata

- constructing calldata to be sent via .call()
- https://github.com/CJ42/All-About-Solidity/blob/master/articles/data-locations/Calldata.md