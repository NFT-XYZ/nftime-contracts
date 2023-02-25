// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Renderer} from "../src/utils/Renderer.sol";
import {NFTIME} from "../src/NFTIME.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Renderer renderer = new Renderer();
        new NFTIME(address(renderer), msg.sender);

        vm.stopBroadcast();
    }
}
