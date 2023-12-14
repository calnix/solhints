# Endianness & bytes data layout in Solidity

Consider the variable x in its hexadecimal representation `0x01234567`.

    Big_Endian:    0x [01][23][45][67]
    Little_Endian: 0x [67][01][23][45]

- In the EVM, all data (regardless of its Solidity type) is stored big-endian at the low level inside the virtual machine.
- EVM uses 32 bytes words to manipulate data.
- However, depending on its type ( bytesN , uintN , address , etc…), the data is laid out differently.

## strings and bytes

