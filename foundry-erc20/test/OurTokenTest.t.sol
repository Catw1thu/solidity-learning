// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {Test} from "forge-std/Test.sol";

contract OurTokenTest is Test {
    DeployOurToken public deployOurToken;
    OurToken public ourToken;

    address addr1 = makeAddr("addr1");
    address addr2 = makeAddr("addr2");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();
    }

    function testTransfer() public {
        uint256 msgSenderStartingBalance = ourToken.balanceOf(msg.sender);
        uint256 addr1StartingBalance = ourToken.balanceOf(addr1);

        vm.prank(msg.sender);
        ourToken.transfer(addr1, 10 ether);

        assertEq(
            ourToken.balanceOf(msg.sender),
            msgSenderStartingBalance - 10 ether
        );
        assertEq(ourToken.balanceOf(addr1), addr1StartingBalance + 10 ether);
    }
}
