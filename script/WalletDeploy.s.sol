//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/SmartWallet.sol";
import "../src/SmartWalletFactory.sol";
import {Script} from "forge-std/Script.sol";

contract DeployWallet is Script{
    
    function run() external returns(SmartWalletFactory){
        vm.startBroadcast();
        SmartWalletFactory factory = new SmartWalletFactory();
        vm.stopBroadcast();
        return factory;
    }
}