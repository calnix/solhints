# https://www.rareskills.io/post/gas-optimization

Use SSTORE2 or SSTORE3 to store a lot of data
SSTORE
SSTORE is an EVM opcode that allows us to store persistent data on a key value basis . As everything in EVM, a key and value are both 32 bytes values.

Costs of writing(SSTORE) and reading(SLOAD) are very expensive in terms of gas spent. Writing 32 bytes costs 22,100 gas, which translates to about 690 gas per bytes. On the other hand, writing a smart contract’s bytecode costs 200 gas per bytes.


SSTORE2
SSTORE2 is a unique concept in a way that it uses a contract’s bytecode to write and store data. To achieve this we use bytecode’s inherent property of immutability.

Some properties of SSTORE2:

We can write only once. Effectively using CREATE instead of SSTORE.

To read, instead of using SLOAD, we now call EXTCODECOPY on the deployed address where the particular data is stored as bytecode.

Writing data becomes significantly cheaper when more and more data needs to be stored.

Example:

Writing data

Our goal is to store a specific data (in bytes format) as the contract’s bytecode.
To achieve this,We need to do 2 things:-

Copy our data to memory first, as EVM then takes this data from memory and store it as runtime code. You can learn more in our article about contract creation code.

Return and store the newly deployed contract address for future use.

We add the contract code size in place of the four zeroes(0000) between 61 and 80 in the below code
0x61000080600a3d393df300. Hence if code size is 65, it will become 0x61004180600a3d393df300(0x0041 = 65)

This bytecode is responsible for step 1 we mentioned.

Now we return the newly deployed address for step 2.

Final contract bytecode = 00 + data (00 = STOP is prepended to ensure the bytecode cannot be executed by calling the address mistakenly)


Reading data

To get the relevant data , you need the address where you stored the data.

We revert if code size is = 0 for obvious reasons.

Now we simply return the contract’s bytecode from the relevant starting position which is after 1 bytes(remember first byte is STOP OPCODE(0x00)).

Additional Information for the curious:

We can also use pre-deterministic address using CREATE2 to calculate the pointer address off chain or on chain without relying on storing the pointer.

Ref: solady


SSTORE3
To understand SSTORE3, first let’s recap an important property of SSTORE2.

The newly deployed address is dependent on the data we intend to store.

Write data
SSTORE3 implements a design such that the newly deployed address is independent of our provided data. The provided data is first stored in storage using SSTORE.
Then we pass a constant INIT_CODE as data in CREATE2 which internally reads the provided data stored in storage to deploy it as code.

This design choice enables us to efficiently calculate the pointer address of our data just by providing the salt(which can be less than 20 bytes). Thus enabling us to pack our pointer with other variables, thereby reducing storage costs.

Read data
Try to imagine how we could be reading the data.

Answer is we can easily compute the deployed address just by providing salt.

Then after we receive the pointer address, use the same EXTCODECOPY opcode to get the required data.

To summarize:

SSTORE2 is helpful in cases where write operations are rare, and large read operations are frequent (and pointer > 14 bytes)

SSTORE3 is better when you write very rarely, but read very often. (and pointer < 14 bytes)

Credit to Philogy for SSTORE3.