# Using smaller uints

WHY: Using the smallest possible data type that still guarantees the correct execution of the code.

- in structs
- or packed into the same storage slot

uint		Digits	Max value
-----------------------------
uint8		3		255
uint16		5		65,535
uint24		8		16,777,215             [16 million]
uint32		10		4,294,967,295          [4.29 billion]
uint40		13		1,099,511,627,775      [1.009 trillion]
uint48		15		281,474,976,710,655
uint56		17		72,057,594,037,927,935
uint64		20		18,446,744,073,709,551,615
uint72		22		4,722,366,482,869,645,213,695
uint80		25		1,208,925,819,614,629,174,706,175
uint88		27		309,485,009,821,345,068,724,781,055
uint96		29		79,228,162,514,264,337,593,543,950,335       [79 octillion]
...
uint128		39		340,282,366,920,938,463,463,374,607,431,768,211,455   [340 decillion]
...
uint256		78		115,792,089,237,316,195,423,570,985,008,687,907,853,269,984,665,640,564,039,457,584,007,913,129,639,935

## Using uint128 for tracking token values

```java
    struct Snapshot {
        uint128 blockNumber;
        uint128 value;
    }
```

Analogy:

There is currently 77 million ether in existence, and around 18m is created every year. In 20 years we'll have in total around (77m + 18*20m) * 10^18 wei.
This fits into 89 bits.

If your app needs to perform multiplication, 89 + 1 bit = 90 bits (shifting left 1 bit is the same as multiply the number by 2).


> conversion tool https://ico.atorresg.com/

## Using uint128 for timestamps

- block.timestamp is uint256
- Using uint32 should be good enough until '2106-02-07T06:28:15+00:00'
- Using uint64 should be good for 584,942,417,355 years after 1970.

Bottom-line; uint32 should be more than enough. Of course, this only matters if variable packing is possible, like in a struct.
If not, you waste gas downscaling. 

if your contract is storing many timestamps, it can save gas to use uint128 so that you can store 2 of them in 1 storage slot

> convert integer ranges to datetime: https://www.unixtimestamp.com/index.php

## Others

https://ethereum.stackexchange.com/questions/24184/how-do-i-combine-integers-to-save-gas-on-transaction-data-and-storage?rq=1
