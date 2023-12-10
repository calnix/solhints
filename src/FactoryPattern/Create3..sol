// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3} from "solmate/utils/CREATE3.sol";
import {ICREATE3Factory} from "./ICREATE3Factory.sol";

/// @title Factory for deploying contracts to deterministic addresses via CREATE3
/// @author zefram.eth
/// @notice Enables deploying contracts using CREATE3. Each deployer (msg.sender) has
/// its own namespace for deployed addresses.
contract CREATE3Factory is ICREATE3Factory {
    /// @inheritdoc	ICREATE3Factory
    function deploy(bytes32 salt, bytes memory creationCode) external payable override returns (address deployed) {
        // hash salt with the deployer address to give each deployer its own namespace
        salt = keccak256(abi.encodePacked(msg.sender, salt));
        return CREATE3.deploy(salt, creationCode, msg.value);
    }

    /// @inheritdoc	ICREATE3Factory
    function getDeployed(address deployer, bytes32 salt) external view override returns (address deployed) {
        // hash salt with the deployer address to give each deployer its own namespace
        salt = keccak256(abi.encodePacked(deployer, salt));
        return CREATE3.getDeployed(salt);
    }
}


/*
Create3: Deploying to multi-chain w/ same address
Deploying a contract to multiple chains with the same address is annoying.
One usually would create a new Ethereum account, seed it with enough tokens to pay for gas on every chain, and then deploy the contract naively. 
This relies on the fact that the new account's nonce is synced on all the chains, therefore resulting in the same contract address. 
However, deployment is often a complex process that involves several transactions (e.g. for initialization), which means it's easy for nonces to fall out of sync and make it forever impossible to deploy the contract at the desired address.

One could use a CREATE2 factory that deterministically deploys contracts to an address that's unrelated to the deployer's nonce, but the address is still related to the hash of the contract's creation code. 
This means if you wanted to use different constructor parameters on different chains, the deployed contracts will have different addresses.

A CREATE3 factory offers the best solution: the address of the deployed contract is determined by only the deployer address and the salt. 
This makes it far easier to deploy contracts to multiple chains at the same addresses.

Note:
The salt provided is hashed together with the deployer address (i.e. msg.sender) to form the final salt, such that each deployer has its own namespace of deployed addresses.
The deployed contract should be aware that msg.sender in the constructor will be the temporary proxy contract used by CREATE3 rather than the deployer, so common patterns like Ownable should be modified to accomodate for this.

*/