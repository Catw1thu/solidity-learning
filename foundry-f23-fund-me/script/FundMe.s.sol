// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfigScript} from "./HelperConfig.s.sol";

contract FundMeScript is Script {
    function run() external returns (FundMe) {
        HelperConfigScript helperConfigScript = new HelperConfigScript();
        address ethUsdPriceFeed = helperConfigScript.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
