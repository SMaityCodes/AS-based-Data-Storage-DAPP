
pragma solidity ^0.8.0;

contract SmartWallet {
    address public owner;
    string public description;

    constructor(string memory _desc) {
        owner = msg.sender;
        description = _desc;
    }

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    
    function setDescription(string memory _desc) public onlyOwner {
        description = _desc;
    }

    
    receive() external payable {}

    
    function withdraw(uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    // Check balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}
