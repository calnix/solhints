// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ArraywithIds {
    
    struct UserInfo {
        bool isActive;
        uint256 userData;
    }

    UserInfo[] public users;
    mapping(address => bool) knownEntity;


//https://ethereum.stackexchange.com/questions/13167/are-there-well-solved-and-simple-storage-patterns-for-solidity/13168#13168
}