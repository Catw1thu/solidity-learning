// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {BasicNFT} from "../src/BasicNFT.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract MintBasicNFT is Script {
    string public constant TOKENURI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function run() external {
        address mostRecentDevelopment = DevOpsTools.get_most_recent_deployment(
            "BasicNFT",
            block.chainid
        );
        mintNFTOnMostRecnetDevelopment(mostRecentDevelopment);
    }

    function mintNFTOnMostRecnetDevelopment(address contractAddress) public {
        vm.startBroadcast();
        BasicNFT(contractAddress).mintNFT(TOKENURI);
        vm.stopBroadcast();
    }
}
