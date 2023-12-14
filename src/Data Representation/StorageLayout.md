# Storage layout

- Storage capacity is 2²⁵⁶-1 elements.
- Storage is used to hold all state variables that are not declared `constant` or `immutable`.
- Storage, unlike the other locations (memory, calldata), is a packed, not padded, location.

## Storage vs memory
- Variable packing occurs only in storage — memory and call data are not packed. Solidity packs variables in storage to minimize gas costs.
- You will not save space trying to pack function arguments or local variables in memory.
- The EVM operates on 32 bytes words, so even if you use smaller types, they are padded to fill a word.

## Strings and bytes


# Reference Types

## Dynamic array

For an array, in the slot it is declared only its length is saved.

- its elements are stored somewhere else in the storage.
- location of the first element is computed like so: **hash(slot) + (index)**


```java
contract StorageLayout {
    //slot 0: 3 (length of array)
    uint256[] public values = [1,2,3];

    // fixed-array: occupies slot 1-3
    uint256[3] newArray = [5,6,7];

    struct Entry {
        uint256 id;
        uint256 value;
    }

    Entry c;       // slots 4-5
    
    // abi.encode(0) will return 0x0000000000000000000000000000000000000000000000000000000000000000
    // keccak256(abi.encode(0)) will return 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
    bytes32 constant public startingIndexOfArrayElements = keccak256(abi.encode(0));
    
    function getElementIndexInStorage(uint256 _elementIndex) public pure returns(bytes32) {
        return bytes32(uint256(startingIndexOfArrayElements) + _elementIndex);
    }
}
```

values[0] = 1, is stored at 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563 in storage. (0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563 + 0)
values[1] = 2, is stored at 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e564 in storage. (0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563 + 1)

### Packing

If our array was uint8[], then many elements of the array would fit in a single slot until 32 bytes are occupied.

```java
contract StorageLayout {
    uint8[] public values = [1,2,3,4,5,6,7,8];
    
    bytes32 constant public startingIndexOfValuesArrayElementsInStorage = keccak256(abi.encode(0));
    
    function getElementIndexInStorage(uint256 _elementIndex) public pure returns(bytes32) {
        return bytes32(uint256(startingIndexOfValuesArrayElementsInStorage) + _elementIndex);
    }
}
```
> 1st index is at storage: 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
When we try to get the element at the index of the first array element, we get: 0x0000000000000000000000000000000000000000000000000807060504030201


## Mapping

- Mapping elements are not stored sequentially as arrays.
- The storage slot of element is computed using a Keccak-256 hash of the key and storage slot of the mapping.
- storage location of mapping element: **bytes32 location = keccak256(abi.encode(keyValue, uint256(slot)));**

```java

    //slot 0    
    mapping(uint256 => address) public ownerOf;

    // to get location of ownerOf[11]
    bytes32 location = keccak256(abi.encode(11, uint256(0)));

    // load element
    address ret;
    assembly {
            ret := sload(location)
    }

```

After obtaining the storage location of the element, we load the data stored in that position by using sload.

For mapping elements, there is no way to order them to save space by fitting smaller types into a single slot like with arrays.
This is due to the nature of the hashing method.

> Solidity keeps the slot where the mapping was declared, to use its index to concatenate it with the key and produce a different hash for similar mappings. 

```java
 
 //slot 0
 mapping(uint256 => address) private ownerOf;

    constructor() {
        ownerOf[0] = address(1);
        ownerOf[1] = address(2);
    }

    function readOwnerOf(uint256 tokenId) external view returns (address) {        
        uint256 slot;
        address ret;

        // get storage slot of mapping
        assembly {
            slot := ownerOf.slot
        }
        
        // get location of element
        bytes32 location = keccak256(abi.encode(tokenId, uint256(slot)));

        // load element
        assembly {
            ret := sload(location)
        }

        return ret;
    }
```

For mappings, the main word itself is unused and left as zero; only its position p is used.
Mappings, famously, do not store what keys exist; keys that don’t exist and keys whose corresponding element is 0 (which is always the encoding of the default value for anything in storage) are treated the same.




## References

- https://ethdebug.github.io/solidity-data-representation/#user-content-types-overview-overview-of-the-types-direct-types-representations-of-direct-types
- https://github.com/CJ42/All-About-Solidity/blob/master/articles/Bytes.md