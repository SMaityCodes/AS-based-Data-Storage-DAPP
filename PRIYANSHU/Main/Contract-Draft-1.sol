// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PoseidonDataStorage {
    struct DataCommitment {
        address uploader;
        uint256 poseidonHash;
        string ipfsCID; // Optional: link to the actual data
        uint256 timestamp;
    }

    DataCommitment[] public storedData;

    event DataStored(address indexed uploader, uint256 poseidonHash, string ipfsCID, uint256 timestamp);

    function storeData(uint256 _poseidonHash, string memory _ipfsCID) external {
        DataCommitment memory newData = DataCommitment({
            uploader: msg.sender,
            poseidonHash: _poseidonHash,
            ipfsCID: _ipfsCID,
            timestamp: block.timestamp
        });

        storedData.push(newData);

        emit DataStored(msg.sender, _poseidonHash, _ipfsCID, block.timestamp);
    }

    function getAllStoredData() external view returns (DataCommitment[] memory) {
        return storedData;
    }
}
