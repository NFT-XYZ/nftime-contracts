// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import {Date, DateTime} from "./utils/DateTime.sol";

/**
 *     c00l         ,k0d.  c0000000000000000d.  c000000000000000d.
 *     oMMO:;'      :XM0'  dMMXkxkxxxxxxxxxkl.  ;kkxxxONMWKxxxxxl.
 *     dMMMWM0'     :XM0'  dMMx.                      .OMNc
 *     dMM0l:codl.  :XM0'  dMMd.                      .OMN:
 *     dMMx. .xXKc..cNM0'  dMMx..........             .OMN:
 *     dMMd   ..'o00XWM0'  dMMNK000000000l            .OMN:
 *     dMMd.     ;xx0WM0'  dMMXkxkxxxxxxk:            .OMN:
 *     dMMd.        :XM0'  dMMx.                      .OMN:
 *     dMMd         :XM0'  dMMd                       .OMN:
 *     dMMd         :XM0'  dMMd                       .OMN:
 *     dMMd         :XM0'  dMMd                       .OMN:
 *     ;xx:         'dkl.  ;xx:                       .lkd'
 *
 *      ...............     ..             .     ...............
 *     c000000000000000d.  c00c          ,k0d.  c000000000000000d.
 *     ;xxxkxONMWKxkxxkl.  dMMO:,'    .;,dNM0'  dMMXkxxxxxxkkxxkl.
 *           .OMNc         oMMMWM0'   dWMMMM0'  dMMx.
 *           .OMN:         dMM0l:codoolccxNM0'  dMMd
 *           .OMN:         dMMd. .xNXK;  :NM0'  dMMx.........
 *           .OMN:         dMMx.  ....   :NM0'  dMMNK00000000c
 *           .OMN:         dMMx.         :NM0'  dMMXkxxxxxxxx:
 *           .OMN:         dMMx.         :NM0'  dMMx.
 *           .OMN:         dMMx.         :NM0'  dMMd.
 *      .....,0MNl.....    dMMd          :XM0'  dMMx............
 *     c00000KWMMX00000d.  dMMd          :XM0'  dMMNK00000000000d.
 *     ;xxxxxxxxxxkkxxkl.  ;xk:          'dkl.  ;xxxxxxxxxxxxxxkl.
 *
 */

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
    error NFTIME__NotEnoughEtherSent();

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    error NFTIME__TimeAlreadyMinted();

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    error NFTIME__WithdrawError();

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    Counters.Counter private s_tokenIds;

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    string private s_contractUri = "ipfs://QmU5vDC1JkEASspnn3zF5WKRraXhtmrKPvWQL2Uwh6X1Wb";

    /// @dev Thrown if the sent amount of ethers isn't equal to price
    DateTime private immutable i_dateTimeUtil = new DateTime();

    /// @dev Mapps TokenId to the associated minted Timestamp (e.g. 1 -> 946681200)
    mapping(uint256 tokenId => uint256 timestamp) private s_tokenIdToTimeStamp;

    /// @dev Mapps the minted formatted Date to minted (e.g. 01.JAN 2030 12:00 -> true / false)
    mapping(string date => bool minted) private s_mintedTimes;

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

    /// @dev Mint Regular NFTIME
    /// @param _time Timestamp for minted NFTIME
    /// @param _tokenUri Timestamp for minted NFTIME
    function mint(uint256 _time, string memory _tokenUri) external payable whenNotPaused {
        if (msg.value != 0.01 ether) {
            revert NFTIME__NotEnoughEtherSent();
        }

        s_tokenIds.increment();
        uint256 newItemId = s_tokenIds.current();

        Date memory ts = i_dateTimeUtil.timestampToDateTime(_time);
        string memory date = i_dateTimeUtil.formatDate(ts);

        if (s_mintedTimes[date] == true) {
            revert NFTIME__TimeAlreadyMinted();
        }

        _mint(msg.sender, newItemId);

        s_mintedTimes[date] = true;
        s_tokenIdToTimeStamp[newItemId] = _time;

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
