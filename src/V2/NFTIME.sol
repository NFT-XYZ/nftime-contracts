// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {Date, DateTime} from "./libraries/DateTime.sol";
import {NFTIMEArt} from "./libraries/NFTIMEArt.sol";

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
contract NFTIME is Ownable, AccessControl, ERC721URIStorage, ERC721Enumerable, ERC721Pausable, ERC721Burnable {
    using Counters for Counters.Counter;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    /// @param _value Value sent
    error NFTIME__NotEnoughEtherSent(uint256 _value);

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    error NFTIME__TimeAlreadyMinted();

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    error NFTIME__WithdrawError();

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Price in ETHER for a Minute
    uint256 private constant NFTIME_MINUTE_PRICE = 0.01 ether;

    /// @dev Price in ETHER for a Day
    uint256 private constant NFTIME_DAY_PRICE = 0.1 ether;

    /*//////////////////////////////////////////////////////////////
                                ENUMS
    //////////////////////////////////////////////////////////////*/

    enum Type {
        Minute,
        Day
    }

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    Counters.Counter private s_tokenIds;

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    string private s_contractUri = "ipfs://QmU5vDC1JkEASspnn3zF5WKRraXhtmrKPvWQL2Uwh6X1Wb";

    /// @dev Mapps TokenId to the associated minted Timestamp (e.g. 1 -> 946681200)
    mapping(uint256 tokenId => uint256 timestamp) private s_tokenIdToTimeStamp;

    /// @dev Mapps TokenId to rarity (true / false)
    mapping(uint256 tokenId => bool rarity) private s_rarities;

    /// @dev Mapps the minted formatted Date to minted (e.g. 01.JAN 2030 12:00 -> true / false)
    mapping(string date => bool minted) private s_mintedMinutes;

    /// @dev Mapps the minted formatted Date to minted (e.g. 01.JAN 2030 -> true / false)
    mapping(string date => bool minted) private s_mintedDays;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @dev Initialize NFTIME Contract, grant DEFAULT_ADMIN_ROLE to multisig.
    /// @notice Initialize GreenLoan Contract
    /// @dev Function can be only called once
    /// @param _multisig Name for ERC20
    constructor(address _multisig) ERC721("NFTIME", "TIME") {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev The received ETH stays in this contract address
    receive() external payable {}

    /// @dev Mint Regular NFTIME
    /// @param _time Timestamp for minted NFTIME
    /// @param _type Timestamp for minted NFTIME
    function mint(uint256 _time, Type _type) external payable whenNotPaused {
        uint256 _price = _type == Type.Day ? NFTIME_DAY_PRICE : NFTIME_MINUTE_PRICE;

        if (msg.value != _price) {
            revert NFTIME__NotEnoughEtherSent(msg.value);
        }

        s_tokenIds.increment();
        uint256 newItemId = s_tokenIds.current();

        Date memory _date = DateTime.timestampToDateTime(_time);
        string memory _dateString = DateTime.formatDate(_date);

        if (s_mintedMinutes[_dateString] == true || s_mintedDays[_dateString] == true) {
            revert NFTIME__TimeAlreadyMinted();
        }

        _mint(msg.sender, newItemId);

        if (_type == Type.Day) {
            s_mintedDays[_dateString] = true;
        } else {
            s_mintedMinutes[_dateString] = true;
        }

        s_tokenIdToTimeStamp[newItemId] = _time;

        string memory _tokenUri = _generateTokenURI(_date);

        _setTokenURI(newItemId, _tokenUri);
    }

    /// @dev Mint Rarity NFTIME
    /// @param _tokenUri Timestamp for minted NFTIME
    function mintRarity(string memory _tokenUri) external onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused {
        s_tokenIds.increment();
        uint256 newItemId = s_tokenIds.current();

        _mint(msg.sender, newItemId);

        s_rarities[newItemId] = true;

        _setTokenURI(newItemId, _tokenUri);
    }

    /// @dev Withdraw collected Funds
    function withdraw() external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) {
            revert NFTIME__WithdrawError();
        }
    }

    /// @dev Update DEFAULT_ADMIN_ROLE.
    /// @param _multisig New multisig address.
    function setDefaultAdminRole(address _multisig) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
    }

    /// @dev Update s_contractUri.
    /// @param _contractUri New contract URI.
    function updateContractUri(string memory _contractUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        s_contractUri = _contractUri;
    }

    /// @dev Update metadata of nft.
    /// @param _tokenId Id of token.
    /// @param _tokenUri New token URI.
    function updateNftMetadata(uint256 _tokenId, string memory _tokenUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTokenURI(_tokenId, _tokenUri);
    }

    /// @dev Stop Minting
    function pauseTransactions() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /// @dev Resume Minting
    function resumeTransactions() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @dev IPFS Link to Opensea Collection Metadata.
    /// @return Returns contractUri
    function contractURI() external view returns (string memory) {
        return s_contractUri;
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev Render the JSON Metadata for a given Checks token.
    /// @param _date The DB containing all checks.
    function _generateTokenURI(Date memory _date) internal pure returns (string memory) {
        bytes memory svg = NFTIMEArt.generateSVG(_date);

        /// forgefmt: disable-start
        bytes memory metadata = abi.encodePacked(
            "{",
                '"name": "Checks",',
                '"description": "This artwork may or may not be notable.",',
                '"image": ',
                    '"data:image/svg+xml;base64,',
                    Base64.encode(svg),
                    '",',
                '"attributes": [', 
                    _getAttributes(_date, false),
                "]",
            "}"
        );
        /// forgefmt: disable-end

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(metadata)));
    }

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

    /*//////////////////////////////////////////////////////////////
                            INTERNAL OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /// @notice Function to be invoked before every token transfer (mint, burn, ...)
    /// @dev Function can only be when Contract is not paused
    /// @param _tokenId Sender's Address
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(_tokenId);
    }

    /// @notice Function to be invoked before every token transfer (mint, burn, ...)
    /// @dev Function can only be when Contract is not paused
    /// @param from Sender's Address
    /// @param to Recipient's Address
    /// @param firstTokenId Token ID
    /// @param batchSize Size of Batch
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
    {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    /// @notice Function to be invoked before every token transfer (mint, burn, ...)
    /// @dev Function can only be when Contract is not paused
    /// @param _tokenId Sender's Address
    function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage) whenNotPaused {
        super._burn(_tokenId);
    }

    /// @notice Function to be invoked before every token transfer (mint, burn, ...)
    /// @dev Function can only be when Contract is not paused
    /// @param interfaceId Sender's Address
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
