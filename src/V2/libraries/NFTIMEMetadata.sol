// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {Date} from "./DateTime.sol";
import {NFTIMEArt} from "./NFTIMEArt.sol";

library NFTIMEMetadata {
    /// @dev Render the JSON Metadata for a given Checks token.
    /// @param _date The DB containing all checks.
    function generateTokenURI(Date memory _date) public pure returns (string memory) {
        bytes memory svg = NFTIMEArt.generateSVG(_date);

        /// forgefmt: disable-start
        bytes memory metadata = abi.encodePacked(
            "{",
                '"name": "Checks"',
                '"description": "This artwork may or may not be notable.",',
                '"image": ',
                    '"data:image/svg+xml;base64,',
                    Base64.encode(svg),
                    '",',
                '"attributes": [', 
                    getAttributes(_date, false),
                "]",
            "}"
        );
        /// forgefmt: disable-end

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(metadata)));
    }

    /// @dev Render the JSON atributes for a given Checks token.
    /// @param _date The check to render.
    /// @param _isRarity The check to render.
    function getAttributes(Date memory _date, bool _isRarity) public pure returns (bytes memory) {
        return abi.encodePacked(
            getTrait("Year", Strings.toString(_date.year), ","),
            getTrait("Month", _date.month, ","),
            getTrait("Day", _date.day, ","),
            getTrait("Week Day", _date.dayOfWeek, ","),
            getTrait("Hour", _date.hour, ","),
            getTrait("Minute", _date.minute, ","),
            getTrait("Rarity", _isRarity ? "true" : "false", "")
        );
    }

    /// @dev Generate the SVG snipped for a single attribute.
    /// @param traitType The `trait_type` for this trait.
    /// @param traitValue The `value` for this trait.
    /// @param append Helper to append a comma.
    function getTrait(string memory traitType, string memory traitValue, string memory append)
        public
        pure
        returns (string memory)
    {
        return
            string(abi.encodePacked("{", '"trait_type": "', traitType, '",' '"value": "', traitValue, '"' "}", append));
    }
}
