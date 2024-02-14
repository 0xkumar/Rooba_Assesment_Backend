// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/SmartWallet.sol";
import "../src/SmartWalletFactory.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

contract SmartWalletTest is Test {
    SmartWalletFactory factory;

    function setUp() public {
        factory = new SmartWalletFactory();
    }

    function test_createSmartWallet() public {
        address wallet = factory.createSmartWallet();
        assertEq(wallet, factory.userToSmartWallet(address(this)));
    }

    function test_destroySmartWallet() public {
        address wallet = factory.createSmartWallet();
        assertEq(wallet, factory.userToSmartWallet(address(this)));
        factory.destroySmartWallet();
        assertEq(address(0), factory.userToSmartWallet(address(this)));
    }

    function test_getWalletAddress() public {
        address wallet = factory.createSmartWallet();
        assertEq(wallet, factory.getWalletAddress());
    }

    function test_destroyAndRecreateSmartWallet() public {
        //Initially wallet was createde
        vm.prank(address(123));
        address wallet = factory.createSmartWallet();
        assertEq(wallet, factory.userToSmartWallet(address(123)));
        console.log("Wallet Address: ", wallet);


        //Wallet was destroyed  and recreated
        vm.prank(address(123));
        factory.destroyAndRecreateSmartWallet();
        assertTrue(factory.userToSmartWallet(address(123)) != address(0));
        assertTrue(factory.userToSmartWallet(address(123)) != wallet);
    }

    function test_sendEther() public {
        hoax(address(123), 100 ether);
        address wallet = factory.createSmartWallet();
        SmartWallet userSmartWallet = SmartWallet(payable(wallet));
        vm.prank(address(123));
        (bool success,) = address(userSmartWallet).call{value: 1 ether}("");
        require(success, "Failed to send money");
        assertEq(1 ether, address(userSmartWallet).balance);
        vm.prank(address(123));
        userSmartWallet.sendEther(payable(address(456)), 0.5 ether);
        assertEq(0.5 ether, address(userSmartWallet).balance);
        //what if the non owner tries to send ether
        vm.prank(address(456));
        vm.expectRevert();
        userSmartWallet.sendEther(payable(address(789)), 0.1 ether);

    }

    function test_receiveEther() public {
        hoax(address(123), 100 ether);
        address wallet = factory.createSmartWallet();
        assertEq(wallet, factory.userToSmartWallet(address(123)));

        SmartWallet userSmartWallet = SmartWallet(payable(wallet));
        vm.prank(address(123));
        (bool success,) = address(userSmartWallet).call{value: 1 ether}(abi.encodeWithSignature("receiveEther()", " "));
        require(success, "Failed to send money");
        assertEq(1 ether, userSmartWallet.balances(address(123)));

    }

    function test_withdrawEther() public {
        hoax(address(123), 100 ether);
        address wallet = factory.createSmartWallet();
        assertEq(wallet, factory.userToSmartWallet(address(123)));
        SmartWallet userSmartWallet = SmartWallet(payable(wallet));
        vm.prank(address(123));
        (bool success,) = address(userSmartWallet).call{value: 1 ether}("");
        require(success, "Failed to send money");
        assertEq(1 ether, address(userSmartWallet).balance);
        vm.prank(address(123));
        (success,) = address(userSmartWallet).call(abi.encodeWithSignature("withdrawEther(uint256)", 0.5 ether));
        require(success, "Failed to withdraw money");
        console.log("balance of userSmartWallet is", address(userSmartWallet).balance / 1e18);
        assertEq(0.5 ether, address(userSmartWallet).balance);

    }

    function test_delegateCallToContract() public {
        hoax(address(123), 100 ether);
        address wallet = factory.createSmartWallet();
        SmartWallet userSmartWallet = SmartWallet(payable(wallet));
        vm.prank(address(123));
        (bool success,) = address(userSmartWallet).call(
            abi.encodeWithSignature("delegateCallToContract(address,bytes)", address(456), " ")
        );
        require(success, "Failed to delegate call");
    }

    function test_check_balance() public {
        hoax(address(123), 100 ether);
        address wallet = factory.createSmartWallet();
        SmartWallet userSmartWallet = SmartWallet(payable(wallet));
        vm.prank(address(123));
        (bool success,) = address(userSmartWallet).call{value: 1 ether}(abi.encodeWithSignature("receiveEther()", " "));
        require(success, "Failed to send money");
        assertEq(1 ether, userSmartWallet.check_balance(address(123)));
    }

    function test_DestroySmartWallet() public {
        hoax(address(123),100 ether);
        address wallet =factory.createSmartWallet();
        SmartWallet userSmartWallet = SmartWallet(payable(wallet));
        vm.prank(address(123));
        (bool success,) = address(userSmartWallet).call{value: 1 ether}("");
        require(success, "Failed to send money");
        assertEq(1 ether, address(userSmartWallet).balance);
        assertEq(address(123).balance,99 ether);
        vm.prank(address(123));
        factory.destroySmartWallet();
        assertEq(address(0), factory.userToSmartWallet(address(123)));
        assertEq(address(123).balance,100 ether);
    }

    //What if someone tries to destroy our contract
    function test_DestroySmartWallet2() public{
        vm.prank(address(123));
        address wallet = factory.createSmartWallet();
        SmartWallet userSmartWallet = SmartWallet(payable(wallet));


        vm.prank(address(1337));
        vm.expectRevert();
        factory.destroySmartWallet();
    }


    //check if someone tries to drain our contract
    function test_withdrawEther1()public{
        hoax(address(123),100 ether);
        address wallet = factory.createSmartWallet();
        SmartWallet userSmartWallet = SmartWallet(payable(wallet));
        vm.prank(address(123));
        (bool success,) = address(userSmartWallet).call{value: 1 ether}("");
        require(success, "Failed to send money");
        assertEq(1 ether, address(userSmartWallet).balance);
        vm.prank(address(1337));
        vm.expectRevert();
        (success,) = address(userSmartWallet).call(abi.encodeWithSignature("withdrawEther(uint256)", 0.5 ether));
        require(success, "Failed to withdraw money");
    }
    
}
