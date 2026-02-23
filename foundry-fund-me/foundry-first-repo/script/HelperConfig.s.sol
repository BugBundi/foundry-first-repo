// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeConfig;// Variable to hold the respective config address
    MockV3Aggregator mockPriceFeed; //Variable to store the mockPrice feed for lical anvil
    //Magic numbers can  cause problems it's best to save them in vaiables for easy remebring

    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 200e8;

    struct NetworkConfig {
        address priceFeed;
    } //This struct holds the price feed address either sepolia, arbitrium sepolia or local anvil

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getSepoliaETHConfig();
        } else if (block.chainid == 421614) {
            activeConfig = getArbSepoliaETHConfig();
        } else {
            activeConfig = getorCreateAnvilETHConfig();
        }
    } //Thr constructor runs immediately the script is deplyed and it then selects which network to selct

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getorCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        if (activeConfig.priceFeed != address(0)) {
            /* The if statement checks if a pricefeed has already been set, then says if yes return the one that was set and don't create a new one */
            return activeConfig; //says return the already saved config
        }

        vm.startBroadcast();

        mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); /* iF THE ACTIVE CONFIG HAS NOT ALREADY BEEN SET(activeConfig.pricefeed == address(0)) it jumps to this line and creates a new one then returns it */
        vm.stopBroadcast();

        /* The condtional check prevents redeploying mocks on anvil
            Cheks if config is already set
            Implements laxy implementation */

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }

    function getArbSepoliaETHConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory ArBSepoliaConfig = NetworkConfig({
            priceFeed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165
        });

        return ArBSepoliaConfig;
    }
}

/*For the sepolia and arbitrium sepolia when the
constructor runs it calls either getSepoliaconfig or getArbitriuSepoliaConfig
the functions. If the network in use is sepolia the function getSepoliaConfig runs and the 
function crates a struct in memory with the priceFeed for sepolia
The function then returns the struct to be stroed in state as activeConfig through the constructor
*/
