// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/* ───── Chainlink VRF v2.5 DEV imports ───── */
import {
    VRFConsumerBaseV2Plus
} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

import {
    IVRFCoordinatorV2Plus
} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";

import {
    VRFV2PlusClient
} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/* ───── Contract ───── */
contract SepoliaVRFv25_LongID is VRFConsumerBaseV2Plus {
    /* Sepolia v2.5 coordinator & key‑hash */
    address  constant COORDINATOR =
        0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32  constant KEY_HASH   =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    /* >>> paste your full 77‑digit ID here <<< */
    uint256 constant SUB_ID =
        47469147550388270543709374108490336712227361418594653089036256718466897939761;

    /* Request parameters */
    uint32  public callbackGasLimit   = 200000;
    uint16  public requestConfirmations = 3;
    uint32  public numWords           = 1;

    /* State */
    uint256 public randomWord;

    /* ───── Constructor ───── */
    constructor()
        VRFConsumerBaseV2Plus(COORDINATOR)
    {}

    /* Accept ETH so the callback has gas */
    receive() external payable {}

    /* ───── Make the request ───── */
    function requestRandomNumber() external returns (uint256 reqId) {
        /* build ExtraArgs (choose LINK payment) */
        VRFV2PlusClient.ExtraArgsV1 memory extra =
            VRFV2PlusClient.ExtraArgsV1({nativePayment: false});

        /* build request struct */
        VRFV2PlusClient.RandomWordsRequest memory req =
            VRFV2PlusClient.RandomWordsRequest({
                keyHash:            KEY_HASH,
                subId:              SUB_ID,
                requestConfirmations: requestConfirmations,
                callbackGasLimit:   callbackGasLimit,
                numWords:           numWords,
                extraArgs:          VRFV2PlusClient._argsToBytes(extra)
            });

        /* send it */
        reqId = IVRFCoordinatorV2Plus(COORDINATOR).requestRandomWords(req);
    }

    /* ───── Callback ───── */
    function fulfillRandomWords(
        uint256,                       /* requestId */
        uint256[] calldata words
    ) internal override {
        randomWord = words[0];
    }
}
