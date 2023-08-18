// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Ownable } from "@oz/access/Ownable.sol";
import { AccessControl } from "@oz/access/AccessControl.sol";
import { Counters } from "@oz/utils/Counters.sol";
import { ERC721 } from "@oz/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@oz/token/ERC721/extensions/ERC721URIStorage.sol";
import { ERC721Enumerable } from "@oz/token/ERC721/extensions/ERC721Enumerable.sol";
import { ERC721Pausable } from "@oz/token/ERC721/extensions/ERC721Pausable.sol";
import { ERC721Burnable } from "@oz/token/ERC721/extensions/ERC721Burnable.sol";
import { Base64 } from "@oz/utils/Base64.sol";
import { Strings } from "@oz/utils/Strings.sol";

import { Date, DateTime } from "./libraries/DateTime.sol";
import { NFTIMEMetadata } from "./libraries/NFTIMEMetadata.sol";

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
/// @notice MINT YOUR MINUTE & DAY
/// @custom:security-contact abc@nftxyz.art
contract NFTIME is Ownable, AccessControl, ERC721URIStorage, ERC721Enumerable, ERC721Pausable, ERC721Burnable {
    using Counters for Counters.Counter;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    /// @param _value Value sent
    error NFTIME__NotEnoughEtherSent(uint256 _value);

    /// @dev Thrown if time has already been minted
    error NFTIME__TimeAlreadyMinted();

    /// @dev Thrown if withdrawal has failed
    error NFTIME__WithdrawError();

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Price in Ether for a Minute
    uint256 private constant NFTIME_MINUTE_PRICE = 0.01 ether;

    /// @dev Price in Ether for a Day
    uint256 private constant NFTIME_DAY_PRICE = 0.1 ether;

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Struct that contains vital information
    ///      timestamp: Minted Timestamp
    ///      rarity: Token rarity
    ///      nftType: Token Type (Minute, Day or Rarity)
    struct TokenStruct {
        uint256 timestamp;
        bool rarity;
        Type nftType;
    }

    /*//////////////////////////////////////////////////////////////
                                ENUMS
    //////////////////////////////////////////////////////////////*/

    /// @dev Enum for Token Type
    enum Type {
        Minute,
        Day,
        Rarity
    }

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Tracker of tokenIds
    Counters.Counter private s_tokenIds;

    /// @dev IPFS Hash of Contract Medatadata
    string private s_contractUri = "ipfs://QmU5vDC1JkEASspnn3zF5WKRraXhtmrKPvWQL2Uwh6X1Wb";

    /// @dev Mapping TokenId => TokenStruct (timestamp, isRarity, nftType)
    mapping(uint256 tokenId => TokenStruct token) private s_tokens;

    /// @dev Mapps the minted formatted Date to minted (e.g. 01.JAN 2030 12:00 -> true / false)
    mapping(string date => bool minted) private s_mintedMinutes;

    /// @dev Mapps the minted formatted Date to minted (e.g. 01.JAN 2030 -> true / false)
    mapping(string date => bool minted) private s_mintedDays;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @dev Initialize NFTIME Contract, grant DEFAULT_ADMIN_ROLE to multisig.
    /// @param _multisig Mutlisig address
    constructor(address _multisig) ERC721("NFTIME", "TIME") {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
    }

    /*//////////////////////////////////////////////////////////////
                                EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev The received ETH stays in this contract address
    receive() external payable { }

    /// @notice Mint Regular NFTIME
    /// @param _time Timestamp for Token
    /// @param _type Type for Token (Minute or Day)
    /// @return Returns new tokenId
    function mint(uint256 _time, Type _type) external payable whenNotPaused returns (uint256) {
        bool _isMinute = _type == Type.Minute;

        uint256 _price = _isMinute ? NFTIME_MINUTE_PRICE : NFTIME_DAY_PRICE;

        if (msg.value != _price) {
            revert NFTIME__NotEnoughEtherSent(msg.value);
        }

        s_tokenIds.increment();
        uint256 _newItemId = s_tokenIds.current();

        Date memory _date = DateTime.timestampToDateTime(_time);
        string memory _dateString = DateTime.formatDate(_date, _isMinute);

        if (s_mintedMinutes[_dateString] == true || s_mintedDays[_dateString] == true) {
            revert NFTIME__TimeAlreadyMinted();
        }

        _mint(msg.sender, _newItemId);

        _isMinute ? s_mintedDays[_dateString] = true : s_mintedMinutes[_dateString] = true;

        s_tokens[_newItemId] = TokenStruct({ timestamp: _time, rarity: false, nftType: _type });

        return _newItemId;
    }

    /// @notice Mint Rarity NFTIME
    /// @param _tokenUri Custom IPFS Hash
    function mintRarity(string memory _tokenUri)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
        returns (uint256)
    {
        s_tokenIds.increment();
        uint256 _newItemId = s_tokenIds.current();

        _mint(msg.sender, _newItemId);

        s_tokens[_newItemId] = TokenStruct({ timestamp: 0, rarity: true, nftType: Type.Rarity });

        _setTokenURI(_newItemId, _tokenUri);

        return _newItemId;
    }

    /// @notice Withdraw collected funds
    function withdraw() external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success,) = payable(msg.sender).call{ value: address(this).balance }("");
        if (!success) {
            revert NFTIME__WithdrawError();
        }
    }

    /// @notice Update DEFAULT_ADMIN_ROLE.
    /// @param _multisig New multisig address.
    function setDefaultAdminRole(address _multisig) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, _multisig);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Update s_contractUri.
    /// @param _contractUri New contract URI.
    function updateContractUri(string memory _contractUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        s_contractUri = _contractUri;
    }

    /// @notice Stop Minting
    function pauseTransactions() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /// @notice Resume Minting
    function resumeTransactions() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @notice IPFS Link to Opensea Collection Metadata.
    /// @return Returns contractUri
    function getContractURI() external view returns (string memory) {
        return s_contractUri;
    }

    /*//////////////////////////////////////////////////////////////
                                PUBLIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Get TokenStruct by TokenId
    /// @param _tokenId TokenId
    function getTokenStructByTokenId(uint256 _tokenId) public view returns (TokenStruct memory) {
        return s_tokens[_tokenId];
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /// @dev Override of the tokenURI function
    /// @param _tokenId TokenId
    /// @return Returns base64 encoded metadata
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        TokenStruct memory _tokenStruct = getTokenStructByTokenId(_tokenId);

        if (!_tokenStruct.rarity) {
            Date memory _date = DateTime.timestampToDateTime(_tokenStruct.timestamp);

            return NFTIMEMetadata.generateTokenURI(_date, _tokenStruct.nftType == Type.Minute);
        } else {
            return super.tokenURI(_tokenId);
        }
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @dev See {ERC721-_beforeTokenTransfer}.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
    {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    /// @dev See {ERC721-_burn}.
    function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage) whenNotPaused {
        super._burn(_tokenId);
    }
}
