// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Question2 {
    address private a;
    uint64 private b;
    bool private c;
    address private d;
    uint256 private e = 55;
    uint256 private f;
    address private g;

    function readStateVariable() external view returns (uint256) {
        // TODO: Read the state variable "e" using only assembly
        
        assembly {
            // Load the value of the storage slot where "e" is stored
            let result := sload(e.slot)
            mstore(0x0, result)         // load result to memory
            return(0x0, 32)            // return 32 bytes from memory, starting from location 0x40
        }
    }
}


/** Explanation:

Storage is set up based on 32 byte words.
Variables that are smaller than 32 bytes will be stored in the same word.
Multiple, contiguous items that need less than 32 bytes are packed into a single storage slot if possible.

storage slot 0 -> a,b,c 
a - address takes 20 bytes
b - uint64 takes 8 bytes  [uint256 : 32 bytes]
c - bool takes 1 byte
- has 32-29 = 3 bytes free

storage slot 1 -> d
d - address takes 20 bytes
d has to occupy a new slot since it cannot fit into slot 0.
slot 1 has 32-20 = 12 bytes free

storage slot 2 -> e
- uint256 variable occupies an entire word. 
- e has to occupy a new slot.

sload(e.slot) will load the value stored at the storage slot associated with variable e, specifically.
This is loaded into memory via mstore(0x0, result).

We opt to load into the scratch space, as scratch space can be used between statements (i.e. within inline assembly). 
There is no concern of spillage out of scratch space, as we are loading 32 bytes into a 64 byte scratch space.

Finally, we return the value stored at 0x00; returning 32 bytes reflecting what was initially loaded. 

*/