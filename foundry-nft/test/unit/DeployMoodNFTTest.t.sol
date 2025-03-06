// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {MoodNFT} from "../../src/MoodNFT.sol";
import {DeployMoodNFT} from "../../script/DeployMoodNFT.s.sol";

contract DeployMoodNFTTest is Test {
    DeployMoodNFT public deployer;

    function setUp() external {
        deployer = new DeployMoodNFT();
    }

    function testConvertSvgToUri() public view {
        string
            memory expectedUri = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MDAiIGhlaWdodD0iNTAwIj4KICA8dGV4dCB4PSIyMDAiIHk9IjI1MCIgZmlsbD0iYmxhY2siPgogICAgSGkhIFlvdSBkZWNvZGVkIHRoaXMhCiAgPC90ZXh0Pgo8L3N2Zz4=";
        string
            memory svg = '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">\n  <text x="200" y="250" fill="black">\n    Hi! You decoded this!\n  </text>\n</svg>';

        string memory actualUri = deployer.svgToImageURI(svg);
        assertEq(actualUri, expectedUri);
    }
}
