// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LPToken} from "../src/LPToken.sol";
import {AchievementBadge} from "../src/AchievementBadge.sol";
import {StakingContract} from "../src/StakingContract.sol";
import {StakingToken} from "../src/StakingToken.sol";

import "forge-std/Script.sol";

// import "../lib/forge-std/src/Vm.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();

        // Deploy the ERC20 token contract
        LPToken LPToken = new LPToken();

        // Log the ERC20 token address
        console.log("LPToken Address:", address(LPToken));

        vm.stopBroadcast();

        vm.startBroadcast();

        // Deploy the ERC20 token contract
        StakingToken StakingToken = new StakingToken();

        // Log the ERC20 token address
        console.log("StakingToken Address:", address(StakingToken));

        vm.stopBroadcast();

        vm.startBroadcast();

        // Deploy the ERC20 token contract
        AchievementBadge AchievementBadge = new AchievementBadge();

        // Log the ERC20 token address
        console.log("AchievementBadge Address:", address(AchievementBadge));

        vm.stopBroadcast();

        vm.startBroadcast();

        // Deploy the Wallet contract and pass the ERC20 token address to the constructor
        StakingContract StakingContract =
            new StakingContract(address(StakingToken), address(LPToken), address(AchievementBadge));

        // Log the Wallet contract address
        console.log("StakingContract Address:", address(StakingContract));

        vm.stopBroadcast();
    }
}
