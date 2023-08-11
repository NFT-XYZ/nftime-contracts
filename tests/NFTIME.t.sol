// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {NFTIME} from "../src/NFTIME.sol";

import {DateTime, Date} from "../src/libraries/DateTime.sol";

/// @title NFTIME
/// @author https://nftxyz.art/ (Olivier Winkler)
/// @notice MINT YOUR MINUTE
/// @custom:security-contact abc@nftxyz.art
contract NFTIMETest is Test {
    /*//////////////////////////////////////////////////////////////
                              CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    uint256 private constant TIMESTAMP = 1893495600;

    /// @dev Price in ETHER for a Minute
    uint256 private constant NFTIME_MINUTE_PRICE = 0.01 ether;

    /// @dev Price in ETHER for a Day
    uint256 private constant NFTIME_DAY_PRICE = 0.1 ether;

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    NFTIME private s_Nftime;

    /*//////////////////////////////////////////////////////////////
                               SETUP
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        s_Nftime = new NFTIME(0x94B2ceA71F9bA7A6e55c40bE320033D1151145B6);

        vm.stopBroadcast();
    }

    /*//////////////////////////////////////////////////////////////
                            function mint()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintMinuteIncorrectValueSent() public {
        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", 0 ether));
        s_Nftime.mint{value: 0 ether}(TIMESTAMP, NFTIME.Type.Minute);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", NFTIME_DAY_PRICE));
        s_Nftime.mint{value: NFTIME_DAY_PRICE}(TIMESTAMP, NFTIME.Type.Minute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintMinuteIfDateAlreadyMinted() public {
        s_Nftime.mint{value: NFTIME_MINUTE_PRICE}(TIMESTAMP, NFTIME.Type.Minute);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__TimeAlreadyMinted()"));
        s_Nftime.mint{value: NFTIME_MINUTE_PRICE}(TIMESTAMP, NFTIME.Type.Minute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_MintMinute() public {
        uint256 _tokenId = s_Nftime.mint{value: NFTIME_MINUTE_PRICE}(TIMESTAMP, NFTIME.Type.Minute);
        assertEq(_tokenId, s_Nftime.totalSupply());
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintDayIncorrectValueSent() public {
        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", 0 ether));
        s_Nftime.mint{value: 0 ether}(TIMESTAMP, NFTIME.Type.Day);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", NFTIME_MINUTE_PRICE));
        s_Nftime.mint{value: NFTIME_MINUTE_PRICE}(TIMESTAMP, NFTIME.Type.Day);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintDayIfDateAlreadyMinted() public {
        s_Nftime.mint{value: NFTIME_DAY_PRICE}(TIMESTAMP, NFTIME.Type.Day);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__TimeAlreadyMinted()"));
        s_Nftime.mint{value: NFTIME_DAY_PRICE}(TIMESTAMP, NFTIME.Type.Day);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_MintDay() public {
        uint256 _tokenId = s_Nftime.mint{value: NFTIME_DAY_PRICE}(TIMESTAMP, NFTIME.Type.Day);
        assertEq(_tokenId, s_Nftime.totalSupply());
    }
}
