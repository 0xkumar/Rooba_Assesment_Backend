// SPDX-License-Identifier: MIT
import "./SmartWallet.sol";

pragma solidity ^0.8.0;

contract SmartWalletFactory {
    //mapping to store the user's smart wallet
    mapping(address => address) public userToSmartWallet;

    event SmartWalletCreated(address indexed user, address indexed smartWallet);
    event SmartWalletDestroyed(address indexed user, address indexed smartWallet);

    //Function to create a new smart wallet
    function createSmartWallet() public returns (address) {
        require(userToSmartWallet[msg.sender] == address(0), "SmartWalletFactory: User already has a smart wallet");

        SmartWallet newSmartWallet = new SmartWallet(msg.sender, address(this));
        userToSmartWallet[msg.sender] = address(newSmartWallet);
        emit SmartWalletCreated(msg.sender, address(newSmartWallet));
        return address(newSmartWallet);
    }

    //Function to destroy the user's smart wallet
    function destroySmartWallet() public {
        require(msg.sender != address(0), "SmartWalletFactory: Invalid address");
        require(userToSmartWallet[msg.sender] != address(0), "SmartWalletFactory: User does not have a smart wallet");
        SmartWallet userSmartWallet = SmartWallet(payable(userToSmartWallet[msg.sender]));
        userSmartWallet.destroySmartWallet();
        userToSmartWallet[msg.sender] = address(0);
        emit SmartWalletDestroyed(msg.sender, address(userSmartWallet));
    }

    //function to get the address
    function getWalletAddress() public view returns (address) {
        require(msg.sender != address(0), " SmartWalletFactory: 0 address call");
        require(userToSmartWallet[msg.sender] != address(0), "SmartWalletFactory: Wallet not created");
        return userToSmartWallet[msg.sender];
    }

    //function to create and destroy the accounts
    function destroyAndRecreateSmartWallet() external {
        destroySmartWallet();
        createSmartWallet();
    }
}
