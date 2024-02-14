// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartWallet {
    address public owner;
    address public smartWalletFactory;

    event EtherSent(address indexed to, uint256 indexed amount);
    event EtherReceived(address indexed from, uint256 indexed amount);
    event SmartWalletDestroyed(address indexed owner, address indexed smartWallet);

    mapping(address => uint256) public balances;

    constructor(address _owner, address _smartWalletFactory) {
        owner = _owner;
        smartWalletFactory = _smartWalletFactory;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "SmartWallet: Only the owner can call this function");
        _;
    }

    modifier OwnerOrFactory() {
        require(
            msg.sender == owner || msg.sender == smartWalletFactory,
            "SmartWallet:Owner of the Factory can only call this function"
        );
        _;
    }

    //function to send ether from the smart wallet
    function sendEther(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0) && amount != 0, "SmartWallet: Invalid address");
        require(address(this).balance > amount, "SmartWallet: Insufficient balance");
        (bool success,) = to.call{value: amount}("");
        require(success, "SmartWallet: Failed to send ether");
        emit EtherSent(to, amount);
    }

    //function to receive ether to the smart wallet and store sender in the mapping
    function receiveEther() external payable {
        require(msg.value != 0, "SmartWallet: Invalid amount");
        balances[msg.sender] += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }

    //function to withdraw ether from the smart wallet
    function withdrawEther(uint256 amount) external onlyOwner {
        require(amount != 0, "SmartWallet: Invalid amount");
        require(address(this).balance > amount, "SmartWallet: Insufficient balance");
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "SmartWallet: Failed to withdraw ether");
    }

    // Function to delegate calls to other contracts
    function delegateCallToContract(address target, bytes memory data)
        external
        onlyOwner
        returns (bool, bytes memory)
    {
        // Using delegatecall to execute the target contract's function
        (bool success, bytes memory result) = target.delegatecall(data);

        // Revert if the delegatecall fails
        require(success, "SmartWallet: Delegate call to contract failed");

        return (success, result);
    }

    //function to check balances of the depositors
    function check_balance(address _depositor) public view returns (uint256) {
        require(_depositor != address(0));
        return balances[_depositor];
    }

    //function to destroy the smart wallet
    function destroySmartWallet() external OwnerOrFactory {
        selfdestruct(payable(owner));
        emit SmartWalletDestroyed(owner, address(this));
    }

    fallback() external payable {}

    receive() external payable {}
}
