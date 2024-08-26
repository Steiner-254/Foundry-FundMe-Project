// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract addresses across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// This ('contract HelperConfig is Script {') is inheritance
contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks
    // Otherwise grab the existing addresses from the live networks

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

        constructor(){
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }

    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    // Since below we are using "vm" keyword, we eliminate pure for ('function getAnvilEthConfig() public returns (NetworkConfig memory){') below
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // Price Feeds

        // 1. Deploy the mocks
        // 2. Return the mock addresses
        // Note: A mock contract is just like a dummy contract
        vm.startBroadcast(); // Deploy the mock contract to the anvil blockchain that we are actually working with
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, 
            INITIAL_PRICE
            );
        vm.stopBroadcast();

         NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;

    }
}
