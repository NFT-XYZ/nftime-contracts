// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {NFTIME} from "../src/NFTIME.sol";

import {DateTime, Date} from "../src/libraries/DateTime.sol";

contract NFTIMETest is Test {
    NFTIME nftime;

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        nftime = new NFTIME(0x94B2ceA71F9bA7A6e55c40bE320033D1151145B6);

        vm.stopBroadcast();
    }
}
