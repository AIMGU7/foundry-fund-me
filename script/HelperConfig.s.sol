//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggegator.sol";


contract HelperConfig is Script{
    //If we are in Anvil we deploy ock addresses
    // If we are on another testnet we pick the actual info of that testnet

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIALPRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig{
        address priceFeed; //ETH-USD price feed address
    }

    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory){

        NetworkConfig memory sepoliaConfig=NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){


        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIALPRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(address(mockPriceFeed));
        return anvilConfig;


    }

}