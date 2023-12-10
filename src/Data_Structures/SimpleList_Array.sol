// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleList {
    
    struct UserInfo{
        address userAddress;
        uint256 userData;
        // more fields
    }

    UserInfo[] public users;

    // add new user
    // returns length of array
    function addUser(address userAddress_, uint256 userData_) external returns(uint256) {
        //create struct
        UserInfo memory newUser = UserInfo({userAddress: userAddress_, userData: userData_});
        
        // add to array. psuh returns length.
        users.push(newUser); 
        return users.length;
    }
}

/*
Strengths

- chronological order
- Provides a count
- arbitrary access by array index

Weaknesses

- Uncontrolled growth of the list (big list, massive gas)
- No assurance of uniqueness
- No check for duplicates 
- No random access by Id

*/