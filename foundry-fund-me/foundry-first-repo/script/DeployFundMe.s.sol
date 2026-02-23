// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig(); //This is outside vm.startBroadcst to avoid paying gas for creating a new mock contract
        address ethUsdPrice = helperConfig.activeConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPrice); //The fundMe takes an address at deployment through the constructor
        vm.stopBroadcast();

        return fundMe;
    }
}
