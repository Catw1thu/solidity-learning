// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {HelperConfigScript} from "./HelperConfigScript.s.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleScript is HelperConfigScript {
    function run() external returns (Raffle, HelperConfigScript) {
        HelperConfigScript helperConfigScript = new HelperConfigScript();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfigScript.activeNetworkConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
        return (raffle, helperConfigScript);
    }
}
