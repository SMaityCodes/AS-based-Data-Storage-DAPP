// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CertificateVerifier {
    address public trustedCA;

    struct SSP {
        address sspAddress;
        bytes32 certifiedPubKey; // Hash of SSP’s public key (or actual compressed pubkey)
    }

    mapping(address => SSP) public certifiedSSPs;

    constructor(address _trustedCA) {
        trustedCA = _trustedCA; // Only this address can sign SSP certificates
    }

    /// @notice Register an SSP by submitting their public key and CA signature
    function registerSSP(bytes32 pubKey, bytes memory signature) public {
        require(verifyCA(pubKey, signature), "Invalid certificate");

        certifiedSSPs[msg.sender] = SSP({
            sspAddress: msg.sender,
            certifiedPubKey: pubKey
        });
    }

    /// @notice Verify that a given public key was signed by the CA
    function verifyCA(bytes32 pubKey, bytes memory signature) internal view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(pubKey));
        bytes32 ethSignedMessageHash = toEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == trustedCA;
    }

    /// @notice Standard Ethereum message prefixing
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /// @notice Extracts r, s, v from a 65-byte signature and recovers the signer
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
}

