// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {Date} from "../utils/DateTime.sol";

library NFTIMEMetadata {
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
