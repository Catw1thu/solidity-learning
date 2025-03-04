// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "chainlink/src/v0.8/vrf/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfigScript is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 31337) {
            // 本地开发链
            activeNetworkConfig = getOrCreateAnvilConfig();
        } else {
            // 测试网配置
            activeNetworkConfig = getSepoliaConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 1 ether, // 修改为实际需要的金额
                interval: 30, // 30秒间隔
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, // Sepolia VRF地址
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // Sepolia gas lane
                subscriptionId: 56141012554353148234343856813611067341870393101562143357163220725013924150561, // 填入您的订阅ID
                callbackGasLimit: 500000 // 根据需求调整
            });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // 如果已经部署过mock合约则直接使用
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether; // 基础费用
        uint96 gasPriceLink = 1e9; // gas价格

        // 部署VRF模拟合约
        VRFCoordinatorV2Mock vrfCoordinator = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );

        // 创建订阅
        uint64 subId = vrfCoordinator.createSubscription();
        vrfCoordinator.fundSubscription(subId, 100 ether);

        return
            NetworkConfig({
                entranceFee: 1 ether, // 本地测试金额
                interval: 30, // 30秒间隔
                vrfCoordinator: address(vrfCoordinator),
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // 本地gas lane
                subscriptionId: subId, // 使用创建的订阅ID
                callbackGasLimit: 500000 // 本地测试限制
            });
    }
}
