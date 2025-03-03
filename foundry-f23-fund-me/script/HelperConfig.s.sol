//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfigScript is Script {
    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    NetworkConfig public activeNetworkConfig;
    constructor() {
        if (block.chainid == 11155111)
            activeNetworkConfig = getSepoliaEthConfig();
        else activeNetworkConfig = getOrCreateAnvilEthConfig();
    }

    MockV3Aggregator mockPriceFeed;
    uint8 public constant DECIMALS = 8;
    int public constant INITIAL_PRICE = 2000e8;
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (address(mockPriceFeed) != address(0)) return activeNetworkConfig;
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        return NetworkConfig({priceFeed: address(mockV3Aggregator)});
    }
}
