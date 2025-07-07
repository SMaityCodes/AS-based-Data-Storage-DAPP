// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.20;

import "./JubJub.sol";

contract EdDSA {
    using JubJub for uint256;

    uint256 private constant FIELD_MASK =
        1809251394333065553493296640760748560207343510400633813116524750123642650623;

    function _hashToFr(bytes memory data) private pure returns (uint256) {
        return uint256(sha256(data)) & FIELD_MASK;
    }

    function verify(
        uint256[2] calldata A,
        uint256 M,
        uint256[2] calldata R,
        uint256 s
    ) external view returns (bool ok) {
        (uint256 xL, uint256 yL) = JubJub.scalarMult(
            JubJub.GENERATOR_X(),
            JubJub.GENERATOR_Y(),
            s
        );

        uint256 t = _hashToFr(
            abi.encodePacked(R[0], R[1], A[0], A[1], M)
        );

        (uint256 xTA, uint256 yTA) = JubJub.scalarMult(A[0], A[1], t);
        (uint256 xR, uint256 yR) = JubJub.pointAdd(R[0], R[1], xTA, yTA);

        ok = (xL == xR) && (yL == yR);
    }
}
