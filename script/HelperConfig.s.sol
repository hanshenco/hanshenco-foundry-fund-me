// SPDX-License-Identifier: MIT

//This file to :
//1. Deploy Mocks when we are on a local anvil chain or localhost foundry
//2. Keep Track of contract address across different chains
// example --> Sepolia ETH/USD and Mainnet ETH/USD is different address

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 5e18;

    //if we are on a local anvil, we deploy mocks
    //otherwise, grab the existing address from LIVE NETWORK

    struct NetworkConfig {
        address priceFeed; //<-- that we used now is ETH/USD Price Feed Address, priceFeed here only onetime set
    }

    //Every Blockchain or network has their own CHainID, ex, eth mainnet = 1, Arbitrum = 42161
    //And ChainID For SepoliaTestnet is 11155111
    constructor() {
        //if we are in sepolia chain which is the chain id is 11155111
        if (block.chainid == 11155111) {
            //.use sepolia config
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    //need to use memory because this is special object
    //with this code below we can get another Blockchain Price Feeds (get it from Chainlink Price Feeds)
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //to get Price Feed Address/vrs address/gas price, etc
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    //Get ETHEREUM MAINNET PRICE FEEDS
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //to get Price Feed Address/vrs address/gas price, etc
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }

    //Local Network which is Anvil
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //if priceFeed is not address 0 (already set the address) so, return
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //1. Deploy the Mocks -- deploy fake/dummy contract
        //2. Return the mock address

        //vm.startBroadcast is to deploy fake/Dummy Contract
        vm.startBroadcast();
        //didalam kurung di isi karena di MockV3Aggregator ada variable yg dilempar dari Constructor di file MockV3Aggregator
        //DECIMALS DAN INITIAL_PRICE adalah variable yg di deklarasi di atas agar readable code
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
