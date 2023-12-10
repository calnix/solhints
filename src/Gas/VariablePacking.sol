// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Packing {
    
    // slot 0
    uint32 value1;
    uint32 value2;
    uint64 value3;
    uint128 value4;
    
    //storage slot 1
    uint256 value5;


}


/*
    STORAGE(SLOT) PACKING

each slot can hold 32 bytes.
values1 to values4 are all packed into slot 0.
values 5 will take up the entire of slot 1.

bytes layout: |----val4: 17-32-----|-----val3: bytes 9-16 -----|-----val3: bytes5-8 -----|-----val1: bytes 1-4 -----|
[val4][val3][val2][val1]

> uints are left aligned?

SStore and SSload deal in 32byte values.

SSLOAD will load the entire of slot 0 onto the stack. 
EVM will use bit operators(AND,OR,NOT) to create a bitmask to extract a specific value from the slot packed will multiple values. 

THEREFORE, slot packing is sensible if the variables in that slot are going to be used as a group for read/write operations. 
If you are not reading or writing all the values in a slot at the same time -> this might cost more gas.


> Structs and array data always start a new slot and occupy whole slots (but items inside a struct or array are packed tightly according to these rules).


    MEMORY 
reading uint8 is more expensive than uint256 in memory. 
it will cost more gas than because its data needs to be padded to fit a word which takes 256 bits.

So in the case where uint8 and uint256 occupy diff storage slots, and are called, using uint8 is pointless.
However, if you have more than one, like 32, uint8 occupying the same storage slot - no padding is required in memory. 
you get the benefit of storage packing without the memory overhead. 
of course, this only makes sense if these uint8 will be used together. 

> Using the smallest possible data type that still guarantees the correct execution of the code.


    Not all elements can be packed

Elements in Memory and Call Data cannot be packed. There is no gas saving in solidity by using smaller variables in function calls and memory.


 */