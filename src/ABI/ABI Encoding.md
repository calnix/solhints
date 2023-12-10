# ABI Encoding

When you define a function in Solidity, you can specify its input and output parameters. 
These parameters have types, such as uint256, string, or address. When you call a function, the input parameters must be encoded so the EVM can understand. 
Similarly, when a function returns a value, that value needs to get encoded in a way external systems can understand.

Encoding is really generic term. It basically means "creating byte representation of something more high level".

On a EVM level there is no functions and contracts. There are only bytes.
Because of that, functions and values have to be encoded (create a sequence of bytes).

Encoding has to follow rules. There are different rules how to encode things in EVM, depending on what you are encoding. Transactions, for example, are encoded like this:

- first 4 bytes are function selector (F)
- rest are encoded parameters (P)

Raw transaction data does look like this: 0xFFFFPPPP...PPPP.

## Encode Data Before hashing

keccak256(): 
- computes hash, which is always returned as a fixed-length `bytes32` value.
- resulting hash is a string of hex characters (letters and numbers) that can be represented in hexadecimal format.

### keccak256 expects a byte array and nothing else

So if your data is already of type bytes there is no difference

```java 
function equality() public pure returns (bool) {
 bytes memory test = "0x01020304";

 // True
 return keccak256(test) == keccak256(abi.encodePacked(test));
}

```

If <data input> is of any other type, then abi.encodePacked or abi.encode are ways of converting a variable number of arguments, with possibly different types, to bytes to allow for the use of keccak256.

It is recommended to encode input data before hashing.
This ensures proper formatting and is especially important for protecting the integrity of the information.

## abi.encodeWithSignature

encodeWithSignature takes the function signature and its parameter values and encodes them into a byte array.

```java

function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }

    function test() public pure {
        uint256 a = 123;
        uint256 b = 456;

        bytes memory data = abi.encodeWithSignature("add(uint256,uint256)", a, b);
    }
```

## abi.encode

abi.encode takes parameters as arguments and returns a byte array containing the encoded data.
This is useful when you don’t know the function signature at compile time.

```java 

    function test() public pure {
        uint256 a = 123;
        uint256 b = 456;
        bytes memory data = abi.encode(a, b);
    }
```

## abi.encodePacked

same thing as abi.encode, however, there the data is not packed to fit into 32byte chunks.
This is useful for saving gas costs by reducing the data size.

> returns a byte array containing the tightly packed encoded data
> abi.encodePacked should stop to be used since there are conversions around to deprecate it in future versions of Solidity

## Comparing abi.encode and abi.encodedPacked

Generally speaking, using abi.encodePacked will result in a lower gas cost than abi.encode. 
This is because abi.encode adds padding to ensure the encoded arguments are correctly aligned, which can result in additional gas costs.

## Collision Problem

Collisions can occur with abi.encode and abi.encodePacked. However, the likelihood of a collision occurring with abi.encodePacked is slightly higher because it produces a tightly packed byte array, potentially resulting in more collisions than abi.encode. This can be a concern when using hashes to represent data in smart contracts, as it could potentially allow an attacker to manipulate the contract by providing a different input that produces the same hash as the original input.

That said, the probability of a hash collision occurring is still relatively low. Proper testing and validation of the inputs used to generate the hash can mitigate this possibility. Additionally, you can also use larger hash sizes to reduce the likelihood of a collision occurring.

