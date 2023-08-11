// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

import {NFTIMEArt} from "./NFTIMEArt.sol";
import {Date, DateTime} from "./DateTime.sol";

///
///  ███╗   ██╗███████╗████████╗██╗███╗   ███╗███████╗
///  ████╗  ██║██╔════╝╚══██╔══╝██║████╗ ████║██╔════╝
///  ██╔██╗ ██║█████╗     ██║   ██║██╔████╔██║█████╗
///  ██║╚██╗██║██╔══╝     ██║   ██║██║╚██╔╝██║██╔══╝
///  ██║ ╚████║██║        ██║   ██║██║ ╚═╝ ██║███████╗
///  ╚═╝  ╚═══╝╚═╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝
///
/// @title NFTIME
/// @author https://nftxyz.art/ (Olivier Winkler)
/// @notice MINT YOUR MINUTE
/// @custom:security-contact abc@nftxyz.art
library NFTIMEMetadata {
    /*//////////////////////////////////////////////////////////////
                                PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Render the JSON Metadata for a given Checks token.
    /// @param _date The DB containing all checks.
    function generateTokenURI(Date memory _date, bool _isMinute) public pure returns (string memory) {
        bytes memory _svg = NFTIMEArt.generateSVG(_date, _isMinute);
        string memory _name = DateTime.formatDate(_date);

        /// forgefmt: disable-start
        bytes memory _metadata = abi.encodePacked(
            "{",
                '"name": "',
                _name,
                '",',
                '"description": "Collect your favourite Time. Set your time. Mint your minute!.",',
                '"image": ',
                    '"data:image/svg+xml;base64,',
                    Base64.encode(_svg),
                    '",',
                '"attributes": [', 
                    _getAttributes(_date, false),
                "]",
            "}"
        );
        /// forgefmt: disable-end

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(_metadata)));
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Render the JSON atributes for a given Checks token.
    /// @param _date The check to render.
    /// @param _isRarity The check to render.
    function _getAttributes(Date memory _date, bool _isRarity) internal pure returns (bytes memory) {
        return abi.encodePacked(
            _getTrait("Year", Strings.toString(_date.year), ","),
            _getTrait("Month", _date.month, ","),
            _getTrait("Day", _date.day, ","),
            _getTrait("Week Day", _date.dayOfWeek, ","),
            _getTrait("Hour", _date.hour, ","),
            _getTrait("Minute", _date.minute, ","),
            _getTrait("Rarity", _isRarity ? "true" : "false", "")
        );
    }

    /// @dev Generate the SVG snipped for a single attribute.
    /// @param traitType The `trait_type` for this trait.
    /// @param traitValue The `value` for this trait.
    /// @param append Helper to append a comma.
    function _getTrait(string memory traitType, string memory traitValue, string memory append)
        internal
        pure
        returns (string memory)
    {
        return
            string(abi.encodePacked("{", '"trait_type": "', traitType, '",' '"value": "', traitValue, '"' "}", append));
    }
}
