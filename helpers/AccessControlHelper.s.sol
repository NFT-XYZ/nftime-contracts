// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "@std/Script.sol";
import {console} from "@std/console.sol";
import {Strings} from "@oz/utils/Strings.sol";

import {AddressesHelper} from "./AddressesHelper.s.sol";

/// @title DeployerHelper Helper
/// @author https://frigg.eco/
/// @notice Deployhelper Contract
/// @custom:security-contact dev@frigg.eco
contract AccessControlHelper is Script, AddressesHelper {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    string public constant DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";

    /*//////////////////////////////////////////////////////////////
                                PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _sender a parameter just like in doxygen (must be followed by parameter name)
    /// @param _role a parameter just like in doxygen (must be followed by parameter name)
    function getAccessControlRevertMessage(address _sender, string memory _role) public pure returns (bytes memory) {
        return bytes(string.concat("AccessControl: account ", Strings.toHexString(_sender), " is missing role ", _role));
    }
}
