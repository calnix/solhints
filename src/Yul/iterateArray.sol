// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Question1 {
    function iterateEachElementInArrayAndReturnTheSum(uint256[] calldata array) external pure returns (uint256 sum) {
        // TODO: Iterate each element in the array using only assembly
        assembly {
           
            // len := calldataload(0x24)
            // startCondition | stopCondition | counter update
            //                | 1 if i < calldataload(0x24), 0 otherwise and loop ends
            for {let i := 0} lt(i, calldataload(0x24)) {i := add(i,1)}
            {        
                // calldatacopy(copyToMemoryLocation, copyFromCallDataLocation, copySize)
                // calldatacopy(ptr, add(add(0x24, 0x20), mul(i, 0x20)), 32)
                sum := add(sum, calldataload(add(add(0x24, 0x20), mul(i, 0x20))))
            }
        }
    }
}

/** Explanation:
    To iterate through the array, we need the length of the array.
     We obtain the length of the array with calldataload(0x24).
     calldataload(startingOffset) loads 32 bytes starting from the specified offset in the calldata onto the stack.
    
    On calldataload(0x24): 
     The first 4 bytes of calldata contain the function signature.
     The next 32 bytes (0x04 - 0x24) in calldata point to the location in calldata where the array begins.
     Basically a pointer, since the array is dynamic.     
     So we want an startingOffset of 0x24 (32+4 = 36 bytes).
     Therefore, calldataload(0x24) loads the length of the array.

    Then we set up a for loop to iterate through the array elements.   
    
    calldataload(add(add(0x24, 0x20), mul(i, 0x20)))
     The 1st element is located 32 bytes after the length space, at add(0x24, 0x20) = 0x44 
     The 2nd element is located 32 bytes after the first element, at add(add(0x24, 0x20), 32)
     The 3rd element is located 32 bytes after the second, at add(add(0x24, 0x20), mul(32, 2))
     So to traverse down the calldata space, from element to element in the loop, we add mul(i, 0x20) to the 1st element's position. i=[0,lengthArr)
     Essentially, mul(i, 0x20) allows for iteration of elements in the array by increasing the memory offset from the 1st element.


0eff2c18														 //	fn sig: 4 bytes
0000000000000000000000000000000000000000000000000000000000000020 // 0x00: pointer to where array starts, (points to 0x20)
0000000000000000000000000000000000000000000000000000000000000002 // 0x20: length of array
0000000000000000000000000000000000000000000000000000000000000001 // 0x40: param1
0000000000000000000000000000000000000000000000000000000000000002 // 0x60: param2 

Static types are encoded in-place and dynamic types are encoded at a separately allocated location after the current block 
The following types are called “dynamic”
- bytes 
- string
- T[] for any T -> dynamic arrays of any types, uint256[]...
- T[k] for any dynamic T


 */