// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

// Import previously created verifier contracts
import "./Verifier.sol";         // From snarkjs
import "./Poseidon2.sol";        // Optional if you hash inside Solidity
import "./CertificateVerifier.sol";

contract ASDataStorageChallenge is CertificateVerifier, VRFConsumerBaseV2, Verifier {
    // === Chainlink VRF ===
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    bytes32 keyHash;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    address vrfCoordinator;

    constructor(
        uint64 subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash,
        address _trustedCA
    ) VRFConsumerBaseV2(_vrfCoordinator) CertificateVerifier(_trustedCA) {
        s_subscriptionId = subscriptionId;
        keyHash = _keyHash;
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    }

    // === Poseidon Hashed Data ===
    struct DataCommitment {
        address uploader;
        uint256 poseidonHash;
        string ipfsCID;
        uint256 timestamp;
    }

    DataCommitment[] public storedData;

    function storeData(uint256 _poseidonHash, string memory _ipfsCID) external {
        require(certifiedSSPs[msg.sender].certifiedPubKey != 0, "Not certified");

        storedData.push(DataCommitment({
            uploader: msg.sender,
            poseidonHash: _poseidonHash,
            ipfsCID: _ipfsCID,
            timestamp: block.timestamp
        }));
    }

    function getPoseidonHashByIndex(uint256 index) internal view returns (uint256) {
        return storedData[index].poseidonHash;
    }

    function getUploaderForIndex(uint256 index) internal view returns (address) {
        return storedData[index].uploader;
    }

    // === Challenges ===
    struct Challenge {
        address ssp;
        uint256 poseidonHash;
        uint256 issuedAt;
        bool fulfilled;
    }

    mapping(bytes32 => Challenge) public challenges;
    event ChallengeIssued(bytes32 indexed challengeId, address ssp, uint256 hash);
    event ChallengeFulfilled(bytes32 indexed challengeId, address ssp, bool success);

    function issueChallenge(address ssp, uint256 poseidonHash) internal returns (bytes32) {
        bytes32 challengeId = keccak256(abi.encodePacked(ssp, poseidonHash, block.timestamp));

        challenges[challengeId] = Challenge({
            ssp: ssp,
            poseidonHash: poseidonHash,
            issuedAt: block.timestamp,
            fulfilled: false
        });

        emit ChallengeIssued(challengeId, ssp, poseidonHash);
        return challengeId;
    }

    // === Chainlink Randomness Request ===
    function requestRandomChallenge() public {
        require(storedData.length > 0, "No data stored yet");

        COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        uint256 index = randomWords[0] % storedData.length;
        uint256 poseidonHash = getPoseidonHashByIndex(index);
        address ssp = getUploaderForIndex(index);

        issueChallenge(ssp, poseidonHash);
    }

    // === ZK Proof + Signature Fulfillment ===
    struct Signature {
        uint256[2] sigma;
        uint256[2] publicKey;
        uint256[2] hashPoint;
    }

    function verifyASTuple(Signature memory sig) internal view returns (bool) {
        uint256[12] memory input = [
            sig.sigma[0], sig.sigma[1],
            0x1800deef121f1e7646d312f0aad1c7f1b5ab72f7f7f3a8e3083dc8a0a7e90c1e, // G2_x1
            0x198e9393920d483a7260bfb731fb5dcac3cc08e6aa6c2c5e9e09e7e62b6f5a52, // G2_y1
            sig.hashPoint[0], sig.hashPoint[1],
            sig.publicKey[0], sig.publicKey[1],
            0x1800deef121f1e7646d312f0aad1c7f1b5ab72f7f7f3a8e3083dc8a0a7e90c1e, // G2_x2
            0x198e9393920d483a7260bfb731fb5dcac3cc08e6aa6c2c5e9e09e7e62b6f5a52  // G2_y2
        ];

        uint256[1] memory out;
        assembly {
            if iszero(staticcall(gas(), 8, input, 384, out, 0x20)) {
                revert(0, 0)
            }
        }
        return out[0] == 1;
    }

    function fulfillChallenge(
        bytes32 challengeId,
        Proof memory proof,
        uint256[] memory pubSignals,
        Signature memory sig
    ) public {
        Challenge storage ch = challenges[challengeId];
        require(!ch.fulfilled, "Already fulfilled");
        require(ch.ssp == msg.sender, "Not authorized");

        require(verifyProof(proof, pubSignals), "ZK proof failed");
        require(verifyASTuple(sig), "AS verification failed");

        ch.fulfilled = true;
        emit ChallengeFulfilled(challengeId, msg.sender, true);
    }
}
