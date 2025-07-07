// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library JubJub {
    uint256 internal constant A = 168700;
    uint256 internal constant D = 168696;
    uint256 internal constant Q =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    function GENERATOR_X() internal pure returns (uint256) {
        return 5299619240641551281634865583518297030282874472190772894086521144482721001553;
    }
    function GENERATOR_Y() internal pure returns (uint256) {
        return 16950150798460657717958625567821834550301663161624707787222815936182638968203;
    }

    function Generator() internal pure returns (uint256[2] memory) {
        return [GENERATOR_X(), GENERATOR_Y()];
    }

    function _submod(uint256 a, uint256 b) private pure returns (uint256) {
        return addmod(a >= b ? a - b : a + Q - b, 0, Q);
    }

    function _inverse(uint256 a) private view returns (uint256 inv) {
        inv = _expmod(a, Q - 2, Q);
    }

    function _expmod(uint256 b, uint256 e, uint256 m) private view returns (uint256 o) {
        assembly {
            let p := mload(0x40)
            mstore(p, 0x20)
            mstore(add(p, 0x20), 0x20)
            mstore(add(p, 0x40), 0x20)
            mstore(add(p, 0x60), b)
            mstore(add(p, 0x80), e)
            mstore(add(p, 0xa0), m)
            if iszero(staticcall(gas(), 0x05, p, 0xc0, p, 0x20)) { revert(0, 0) }
            o := mload(p)
        }
    }

    function pointAdd(uint256 x1, uint256 y1, uint256 x2, uint256 y2)
        internal view returns (uint256 x3, uint256 y3)
    {
        if (x1 == 0 && y1 == 0) return (x2, y2);
        if (x2 == 0 && y2 == 0) return (x1, y1);

        uint256 x1x2 = mulmod(x1, x2, Q);
        uint256 y1y2 = mulmod(y1, y2, Q);
        uint256 dx1x2y1y2 = mulmod(D, mulmod(x1x2, y1y2, Q), Q);

        uint256 xNum = addmod(mulmod(x1, y2, Q), mulmod(y1, x2, Q), Q);
        uint256 yNum = _submod(y1y2, mulmod(A, x1x2, Q));

        uint256 inv = _inverse(addmod(1, dx1x2y1y2, Q));
        uint256 inv2 = _inverse(_submod(1, dx1x2y1y2));

        x3 = mulmod(xNum, inv, Q);
        y3 = mulmod(yNum, inv2, Q);
    }

    function scalarMult(uint256 x, uint256 y, uint256 s)
        internal view returns (uint256 qx, uint256 qy)
    {
        uint256 px = x;
        uint256 py = y;
        uint256 ax = 0;
        uint256 ay = 0;
        uint256 k = s;

        while (k != 0) {
            if (k & 1 != 0) {
                (ax, ay) = pointAdd(ax, ay, px, py);
            }
            (px, py) = pointAdd(px, py, px, py);
            k >>= 1;
        }

        qx = ax;
        qy = ay;
    }
}
