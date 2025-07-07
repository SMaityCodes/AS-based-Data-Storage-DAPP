
pragma solidity ^0.8.20;

// Interface of Storage contract
interface IStorage {
    function set(uint _value) external;
    function get() external view returns (uint);
}

contract StorageCaller {
    IStorage public storageContract;

    constructor(address _storageAddress) {
        storageContract = IStorage(_storageAddress);
    }

    function callSet(uint _val) public {
        storageContract.set(_val);
    }

    function callGet() public view returns (uint) {
        return storageContract.get();
    }
}
