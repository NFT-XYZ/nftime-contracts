// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Test } from "@std/Test.sol";
import { NFTIME } from "../src/NFTIME.sol";

import { Constants } from "../helpers/Constants.sol";
import { AccessControlHelper } from "../helpers/AccessControlHelper.s.sol";
import { AddressesHelper } from "../helpers/AddressesHelper.s.sol";

import { DateTime, Date } from "../src/libraries/DateTime.sol";

/// @title NFTIME
/// @author https://nftxyz.art/ (Olivier Winkler)
/// @notice MINT YOUR MINUTE
/// @custom:security-contact abc@nftxyz.art
contract NFTIMETest is Test, AccessControlHelper, Constants {
    /*//////////////////////////////////////////////////////////////
                              CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    uint256 private constant TIMESTAMP = 1_893_495_600;

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
                             MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Explain to a developer any extra details
    modifier paused() {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        s_Nftime.pauseTransactions();
        _;
    }

    /// @dev Explain to a developer any extra details
    modifier unpaused() {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        s_Nftime.resumeTransactions();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               SETUP
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function setUp() public {
        s_Nftime = new NFTIME(DEFAULT_ADMIN_ADDRESS);
    }

    /*//////////////////////////////////////////////////////////////
                            function mint()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintMinuteIncorrectValueSent() public {
        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", 0 ether));
        s_Nftime.mint{ value: 0 ether }(TIMESTAMP, NFTIME.Type.Minute);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", NFTIME_DAY_PRICE));
        s_Nftime.mint{ value: NFTIME_DAY_PRICE }(TIMESTAMP, NFTIME.Type.Minute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintMinutePaused() public paused {
        vm.expectRevert("Pausable: paused");
        s_Nftime.mint{ value: NFTIME_MINUTE_PRICE }(TIMESTAMP, NFTIME.Type.Minute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintMinuteIfDateAlreadyMinted() public {
        s_Nftime.mint{ value: NFTIME_MINUTE_PRICE }(TIMESTAMP, NFTIME.Type.Minute);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__TimeAlreadyMinted()"));
        s_Nftime.mint{ value: NFTIME_MINUTE_PRICE }(TIMESTAMP, NFTIME.Type.Minute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_MintMinute() public {
        uint256 _tokenId = s_Nftime.mint{ value: NFTIME_MINUTE_PRICE }(TIMESTAMP, NFTIME.Type.Minute);
        assertEq(_tokenId, s_Nftime.totalSupply());
        s_Nftime.tokenURI(_tokenId);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintDayIncorrectValueSent() public {
        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", 0 ether));
        s_Nftime.mint{ value: 0 ether }(TIMESTAMP, NFTIME.Type.Day);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__NotEnoughEtherSent(uint256)", NFTIME_MINUTE_PRICE));
        s_Nftime.mint{ value: NFTIME_MINUTE_PRICE }(TIMESTAMP, NFTIME.Type.Day);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintDayPaused() public paused {
        vm.expectRevert("Pausable: paused");
        s_Nftime.mint{ value: NFTIME_DAY_PRICE }(TIMESTAMP, NFTIME.Type.Minute);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RevertMintDayIfDateAlreadyMinted() public {
        s_Nftime.mint{ value: NFTIME_DAY_PRICE }(TIMESTAMP, NFTIME.Type.Day);

        vm.expectRevert(abi.encodeWithSignature("NFTIME__TimeAlreadyMinted()"));
        s_Nftime.mint{ value: NFTIME_DAY_PRICE }(TIMESTAMP, NFTIME.Type.Day);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_MintDay() public {
        uint256 _tokenId = s_Nftime.mint{ value: NFTIME_DAY_PRICE }(TIMESTAMP, NFTIME.Type.Day);
        assertEq(_tokenId, s_Nftime.totalSupply());
        s_Nftime.tokenURI(_tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                         function mintRarity()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertWrongCallerMintRarity() public {
        vm.prank(SENDER_ADDRESS);
        vm.expectRevert(getAccessControlRevertMessage(SENDER_ADDRESS, DEFAULT_ADMIN_ROLE));
        s_Nftime.mintRarity("");
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_FuzzShouldRevertWrongCallerMintRarity(address _sender) public {
        vm.prank(_sender);
        vm.expectRevert(getAccessControlRevertMessage(_sender, DEFAULT_ADMIN_ROLE));
        s_Nftime.mintRarity("");
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertWhenPausedMintRarity() public paused {
        vm.expectRevert("Pausable: paused");
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        s_Nftime.mintRarity("");
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_MintRarity() public {
        string memory _rarityTokenUri = "https://rarity.nftime.site";

        vm.prank(DEFAULT_ADMIN_ADDRESS);
        uint256 _tokenId = s_Nftime.mintRarity(_rarityTokenUri);
        s_Nftime.tokenURI(_tokenId);

        assertEq(true, s_Nftime.getTokenStructByTokenId(_tokenId).rarity);
        assertEq(_rarityTokenUri, s_Nftime.tokenURI(_tokenId));
    }

    /*//////////////////////////////////////////////////////////////
                         function withdraw()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertWithdraw() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_Withdraw() public { }

    /*//////////////////////////////////////////////////////////////
                         function setDefaultAdminRole()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertSetDefaultAdminRole() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_SetDefaultAdminRole() public { }

    /*//////////////////////////////////////////////////////////////
                         function updateContractUri()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertUpdateContractUri() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_UpdateContractUri() public { }

    /*//////////////////////////////////////////////////////////////
                         function updateNftMetadata()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertUpdateNftMetadata() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_UpdateNftMetadata() public { }

    /*//////////////////////////////////////////////////////////////
                         function pauseTransactions()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertPauseTransactions() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_PauseTransactions() public { }

    /*//////////////////////////////////////////////////////////////
                         function resumeTransactions()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ShouldRevertUnpauseTransactions() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_UnpauseTransactions() public { }

    /*//////////////////////////////////////////////////////////////
                         function contractURI()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_ContractURI() public { }

    /*//////////////////////////////////////////////////////////////
                    function getTokenStructByTokenId()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_GetTokenStructByTokenId() public { }

    /*//////////////////////////////////////////////////////////////
                            function tokenURI()
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_MinuteNftTokenURI() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_DayNftTokenURI() public { }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    function test_RarityNftTokenURI() public { }
}
