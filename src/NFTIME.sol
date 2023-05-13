// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import "./utils/DateTime.sol";

/**                                        
    c00l         ,k0d.  c0000000000000000d.  c000000000000000d.
    oMMO:;'      :XM0'  dMMXkxkxxxxxxxxxkl.  ;kkxxxONMWKxxxxxl.
    dMMMWM0'     :XM0'  dMMx.                      .OMNc       
    dMM0l:codl.  :XM0'  dMMd.                      .OMN:       
    dMMx. .xXKc..cNM0'  dMMx..........             .OMN:       
    dMMd   ..'o00XWM0'  dMMNK000000000l            .OMN:       
    dMMd.     ;xx0WM0'  dMMXkxkxxxxxxk:            .OMN:       
    dMMd.        :XM0'  dMMx.                      .OMN:       
    dMMd         :XM0'  dMMd                       .OMN:       
    dMMd         :XM0'  dMMd                       .OMN:       
    dMMd         :XM0'  dMMd                       .OMN:       
    ;xx:         'dkl.  ;xx:                       .lkd'                                                      
                                                               
     ...............     ..             .     ...............  
    c000000000000000d.  c00c          ,k0d.  c000000000000000d.
    ;xxxkxONMWKxkxxkl.  dMMO:,'    .;,dNM0'  dMMXkxxxxxxkkxxkl.
          .OMNc         oMMMWM0'   dWMMMM0'  dMMx.             
          .OMN:         dMM0l:codoolccxNM0'  dMMd              
          .OMN:         dMMd. .xNXK;  :NM0'  dMMx.........     
          .OMN:         dMMx.  ....   :NM0'  dMMNK00000000c    
          .OMN:         dMMx.         :NM0'  dMMXkxxxxxxxx:    
          .OMN:         dMMx.         :NM0'  dMMx.             
          .OMN:         dMMx.         :NM0'  dMMd.             
     .....,0MNl.....    dMMd          :XM0'  dMMx............  
    c00000KWMMX00000d.  dMMd          :XM0'  dMMNK00000000000d.
    ;xxxxxxxxxxkkxxkl.  ;xk:          'dkl.  ;xxxxxxxxxxxxxxkl.

@title  NFTIME
@author https://nftxyz.art/ (Olivier Winkler)
@notice MINT YOUR MINUTE
*/
contract NFTIME is
    Ownable,
    AccessControl,
    ERC721URIStorage,
    ERC721Enumerable,
    ERC721Pausable,
    ERC721Burnable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    DateTime dateTimeUtil = new DateTime();

    string private contractUri =
        "ipfs://QmU5vDC1JkEASspnn3zF5WKRraXhtmrKPvWQL2Uwh6X1Wb";

    /// @notice Minting events
    event Mint(address indexed _address, uint256 _tokenId);
    event RarityMint(address indexed _address, uint256 _tokenId);

    /// @notice 1 -> 946681200
    mapping(uint256 => uint256) public tokenIdToTimeStamp;

    /// @notice 01.JAN 2030 12:00 -> true / false
    mapping(string => bool) public mintedTimes;

    /// @dev Initialize NFTIME Contract, grant DEFAULT_ADMIN_ROLE to multisig.
    constructor(address _multisig) ERC721("NFTIME", "TIME") {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
    }

    /// @dev Mint Regular NFTIME
    /// @param _time Timestamp for minted NFTIME
    function mint(
        uint256 _time,
        string memory _tokenUri
    ) public payable whenNotPaused returns (uint256) {
        require(msg.value == 0.01 ether, "Not enough ETH sent, check price");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        Date memory ts = dateTimeUtil.timestampToDateTime(_time);

        string memory date = dateTimeUtil.formatDate(ts);

        require(mintedTimes[date] == false, "Time has already been minted!");

        _mint(msg.sender, newItemId);

        mintedTimes[date] = true;
        tokenIdToTimeStamp[newItemId] = _time;

        _setTokenURI(newItemId, _tokenURI(newItemId, _tokenUri));

        emit Mint(msg.sender, newItemId);

        return newItemId;
    }

    /// @dev Render the JSON Metadata for a given NFTIME.
    /// @param _tokenId The id of the token to render.
    function _tokenURI(
        uint256 _tokenId,
        string memory _tokenUri
    ) public view returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return _tokenUri;
    }

    /// @dev IPFS Link to Opensea Collection Metadata.
    function contractURI() public view returns (string memory) {
        return contractUri;
    }

    /// @dev Update DEFAULT_ADMIN_ROLE.
    /// @param _multisig New multisig address.
    function setDefaultAdminRole(
        address _multisig
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
    }

    /// @dev Update contractURI.
    /// @param _contractUri New contract URI.
    function updateContractUri(
        string memory _contractUri
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        contractUri = _contractUri;
    }

    /// @dev Update metadata of nft.
    /// @param _tokenId Id of token.
    /// @param _tokenUri New token URI.
    function updateNftMetadata(
        uint256 _tokenId,
        string memory _tokenUri
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
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

    /// @dev Withdraw collected Funds
    function withdraw() public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Unable to withdraw");
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(
        uint256 _tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(_tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _burn(
        uint256 _tokenId
    ) internal override(ERC721, ERC721URIStorage) whenNotPaused {
        super._burn(_tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(AccessControl, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
