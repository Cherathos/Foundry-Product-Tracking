// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MyContract} from "../src/MyContract.sol";

contract DeployContract is Script {
    function run() external returns (MyContract) {
        vm.startBroadcast();
        MyContract myContract = new MyContract();
        vm.stopBroadcast();
        return myContract;
    }
}
