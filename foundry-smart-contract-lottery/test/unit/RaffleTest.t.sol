// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfigScript} from "../../script/HelperConfigScript.s.sol";
import {RaffleScript} from "../../script/RaffleScript.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfigScript public helperConfigScript;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        RaffleScript raffleScript = new RaffleScript();
        (raffle, helperConfigScript) = raffleScript.run();
        vm.deal(PLAYER, STARTING_USER_BALANCE);

        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfigScript.activeNetworkConfig();
    }

    function testRaffleInitialzesInOpenState() public view {
        assertEq(
            uint256(Raffle.RaffleState.OPEN),
            uint256(raffle.getRaffleState())
        );
    }
}
