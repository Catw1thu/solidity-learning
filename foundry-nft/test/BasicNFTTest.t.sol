// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DeployBasicNFT} from "../script/DeployBasicNFT.s.sol";

contract BasicNFTTest is Test {
    DeployBasicNFT public deployer;
    BasicNFT public basicNFT;

    address public USER = makeAddr("user");
    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() external {
        deployer = new DeployBasicNFT();
        basicNFT = deployer.run();
    }

    function testName() public view {
        assertEq(basicNFT.name(), "Doggie");
    }

    function testMint() public {
        vm.startPrank(USER);
        basicNFT.mintNFT(PUG);
        assertEq(basicNFT.balanceOf(USER), 1);
        assertEq(basicNFT.tokenURI(0), PUG);
        assertEq(basicNFT.ownerOf(0), USER);
        vm.stopPrank();
    }
}
