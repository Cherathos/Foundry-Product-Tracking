// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {MyContract} from "../src/MyContract.sol";

contract CreateCreateProduct is Script {
    function createCreateProduct(address mostRecentlyDeployed) public {
        MyContract(payable(mostRecentlyDeployed)).createProduct("a", 1, 1);
        console.log("Urun olusturuldu %s");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MyContract",
            block.chainid
        );
        vm.startBroadcast();
        createCreateProduct(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract BuyBuyProduct is Script {
    function buyBuyProduct(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        MyContract(payable(mostRecentlyDeployed)).buyProducts{value: 2 ether}(
            1,
            "a",
            1
        );
        vm.stopBroadcast();
        console.log("Urun Satin Alindi %s");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MyContract",
            block.chainid
        );
        vm.startBroadcast();
        buyBuyProduct(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract FulfilDelivery is Script {}
