// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Script } from "@std/Script.sol";
import { NFTIME } from "../src/NFTIME.sol";

contract DeployScript is Script {
    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new NFTIME(0x94B2ceA71F9bA7A6e55c40bE320033D1151145B6);

        // nftime.mint{value: 0.01 ether}(
        //     1893495600,
        //     "ipfs://QmW5FZv7nrpBMqF2HTPt2CGcea87FdcEPbpo9dwZpUCg1b"
        // );

        vm.stopBroadcast();
    }
}
