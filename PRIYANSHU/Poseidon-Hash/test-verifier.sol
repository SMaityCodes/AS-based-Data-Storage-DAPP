// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PoseidonT3.sol";

contract TestVerifier {
    function verify(uint256 a, uint256 b, uint256 expectedHash) public pure returns (bool) {
        uint256[2] memory input = [a, b];
        uint256 hash = PoseidonT3.poseidon(input);
        return hash == expectedHash;
    }
}
