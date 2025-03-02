//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";

contract HelperConfigScript {
    struct NetworkConfig {
        address priceFeed;
    }
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }
    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {}
    NetworkConfig public activeNetworkConfig;
    constructor() {
        if (block.chainid == 11155111)
            activeNetworkConfig = getSepoliaEthConfig();
        else activeNetworkConfig = getAnvilEthConfig();
    }
}
