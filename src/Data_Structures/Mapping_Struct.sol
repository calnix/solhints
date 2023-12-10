// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


contract MappingwStruct {

    struct UserInfo {
        bool isActive;
        uint256 userData;
    }

    mapping(address user => UserInfo userInfo) public users;

    function getUserState(address user) external view returns(bool) {
        bool isActive = users[user].isActive;
        return isActive;
    }

    function addUser(address user, uint256 data) external {
        users[user] = UserInfo({isActive: true, userData: data});
    }

    // true -> false | viceversa
    function updateUserState(address user, bool state) external {
        users[user].isActive = state;
    }

    function updateUserData(address user, uint256 data) external {
        users[user].userData = data;
    }

    // delete saves gas vs setting to 0/default.  
    function removeUser(address user) external {
        delete users[user];
    }
}


/*
Strengths

- Random access by unique key: address
- Assurance of key Uniqueness
- Enclose arrays, mappings, structs within each "record"

Weaknesses
- Unable to enumerate the keys -> cannot loop
- Unable to count the keys -> cannot count the keys. cos they all exist
- Needs a manual check to distinguish a default from an explicitly "all 0" record
*/