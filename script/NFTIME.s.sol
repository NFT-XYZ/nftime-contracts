// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Renderer} from "../src/utils/Renderer.sol";
import {NFTIME} from "../src/NFTIME.sol";
import "../src/utils/DateTime.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Renderer renderer = new Renderer();
        new NFTIME(
            address(renderer),
            0x94B2ceA71F9bA7A6e55c40bE320033D1151145B6
        );

        // nftime.mint{value: 0.01 ether}(1893495600);

        vm.stopBroadcast();
    }
}
