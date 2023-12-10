# Decoding

The abi.decode() built-in function is the inverse of abi.encode(), taking arbitrary, ABI-encoded data and unpacking it into its original values, provided you know the encoded types in advance.


```java
// Decodes to x = 123, a = 0xF0e20f3Be40923b0C720e61A75Fb6940A3929019
(uint256 x, address a) = abi.decode(encoded, (uint256, address));
```

## abi.decodeWithSelector()

- But often when processing raw function calls and revert errors you first need to identify the function or revert error before assuming how the parameter data is encoded.
- That's why, for function calls and revert errors, the ABI-encoded parameters are also prefixed with a 4-byte "selector", identifying the function or revert error type.
- This is exactly what the abi.encodeWithSelector() and abi.encodeCall() built-ins do.

**There is no built-in reverse function for abi.encodeWithSelector() -> decodeWithSelector does not exist.**

## Custom implementation of decodeWithSelector

https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/abi-decode-with-selector