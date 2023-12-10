# Data Representation in Solidity

All the data in the storage is saved as bytes, and are converted to it from their initial data types.
Some are left-padded, others are right-padded.

> All the values in the storage are saved ABI-Encoded and when retrieving the value using its variable they are decoded automatically.

## uint/int

Integers are left-padded.

```java
    uint256 public id = 543;

```
Convert from decimal to hex: **543 -> 021f**
left padded to 32 bytes: *0x000000000000000000000000000000000000000000000000000000000000021f*

## strings and bytes

```java
    // 0x4a6572656d79000000000000000000000000000000000000000000000000000c
    string public name = "Jeremy";

```

Notice that we have bytes to the left, followed by a bunch of zeros, then we have more bytes to the right.

- string “Jeremy” has 12 bytes, which are placed on the left-most side of the slot: **4a6572656d79** (if convert to text: “Jeremy”)
- if we convert the right-most byte *0c* to decimal, we get 12.
- ["Jeremy"]["Padding"]["length"]

### But, what if the string is > 31 bytes (31 bytes because 1 other byte holds the length)?

- same rules as accessing an array element apply
- string is split into 32-byte chunks and put starting in the slot index calculated by **keccak256(stringDeclarationSlotIndex)**
- length of string is stored in the string declaration slot index.

> this is why they say string is basically a bytes array

```java

    // slot0 holds 0x047d (len of str)
    string public name = 
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";

```

 - 0x047d: length of string. 1149 in decimals.
 - Since declaration in slot0, string value is located at **keccak256(0)** = 290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
 - the entire string is not stored there, but BEGINS from there, as multiple 32 byte slots are required. 
 - **sload(290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563)** = [0] = *0x206f6620746865207072696e74696e6720616e64207479706573657474696e67* = "Lorem Ipsum is simply dummy text of the printing and typesetting"
 - **sload(290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563 + 1)** = [1] = *...* 

 
