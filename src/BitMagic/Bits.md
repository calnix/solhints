# Bits

Each bit can be 0 or 1.

uint4 will have 4 bits:
 3        0
[ ][ ][ ][ ]

The index begins from the RHS, starting at 0.
So the 4th bit has an index of 3.

Solidity follows the little-endian format, where the least significant byte (LSB) is stored at the lowest address; the right-most bit.

## Ints

The indicator for whether a number is positive or negative requires an extra bit, so it can only store numbers up to one bit less than the unsigned version.
The maximum magnitude of a Two’s Complement negative number is one higher than the maximum magnitude of the positive number.

max(int8) = 127
min(int8) = -128

int8 ranges: [-2^7, 2^7 -1]

### Consider int8

-128 = [1] 000 0000 -> [-2^7] + 0 = -128

The MSB is treated as negative. All the others 0s are treated as positive values.

-128 = [1] 000 0001 -> [-2^7] + 2^0 = -128 + 1 = -127

-128 = [1] 000 0010 -> [-2^7] + 2^1 = -128 + 2 = -126

As more of the positive bits are activated, the negative value decreases.

-1 = [1] 111 1111 -> [-2^7] + 2^6 + .. = -128 + ... + 1 = -1


## Convert positive to negative

1. Invert each bit
2. Add 1

Consider converting 3 to -3.

     3:  0000 0011
invert:  1111 1100
    +1:  1111 1101 = [-3]

### Why does this owrks?






## References
- https://www.youtube.com/watch?v=g6zTuo1NdTw
- https://www.rareskills.io/post/signed-int-solidity