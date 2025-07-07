// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Accept ETH deposits
    receive() external payable {}

    // Withdraw ETH
    function withdraw(uint amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(amount);
    }

    // Check balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
