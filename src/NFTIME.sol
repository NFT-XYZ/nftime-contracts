// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "./utils/DateTime.sol";
import "./utils/Renderer.sol";

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
@author NFTXYZ.ch (Olivier Winkler)
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

    Renderer public renderer;

    /// @notice Minting events
    event Mint(address indexed _address, uint256 _tokenId);
    event RarityMint(address indexed _address, uint256 _tokenId);

    /// @notice 01.JAN 2030 12:00 -> true / false
    mapping(string => bool) public mintedTimes;

    /// @notice 1 -> 01.JAN 2030 12:00
    mapping(uint256 => string) public tokenIdToTime;

    /// @notice 1 -> [year:'2030',month:'JAN',day:'01',hour:'11',minute:'00']
    mapping(uint256 => Date) public tokenIdToTimeStruct;

    /// @notice tokenId -> is rarity?
    mapping(uint256 => Date) public tokenIdToRarityTimeStruct;

    /// @dev Initialize NFTIME Contract, grant DEFAULT_ADMIN_ROLE & set {Renderer}.
    constructor(address _renderer, address _multisig) ERC721("NFTIME", "TIME") {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
        renderer = Renderer(_renderer);
    }

    /// @dev Mint Regular NFTIME
    /// @param _time Timestamp for minted NFTIME
    function mint(
        uint256 _time
    ) public payable whenNotPaused returns (uint256) {
        require(msg.value == 0.01 ether, "Not enough ETH sent, check price");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        Date memory ts = dateTimeUtil.timestampToDateTime(_time);

        string memory date = dateTimeUtil.formatDate(ts);

        require(mintedTimes[date] == false, "Time has already been minted!");

        _mint(msg.sender, newItemId);

        mintedTimes[date] = true;
        tokenIdToTime[newItemId] = date;
        tokenIdToTimeStruct[newItemId] = ts;

        _setTokenURI(newItemId, _tokenURI(newItemId));

        emit Mint(msg.sender, newItemId);

        return newItemId;
    }

    /// @dev Mint Rarity NFTIME
    /// @param _tokenUri TokenURI to special rarity NFTIME
    function rarityMint(
        string memory _tokenUri,
        string memory name,
        Date memory date
    ) public onlyRole(DEFAULT_ADMIN_ROLE) whenNotPaused returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);

        tokenIdToRarityTimeStruct[newItemId] = date;

        _setTokenURI(newItemId, _rarityTokenURI(newItemId, _tokenUri, name));

        emit RarityMint(msg.sender, newItemId);

        return newItemId;
    }

    /// @dev Render the JSON Metadata for a given NFTIME.
    /// @param _tokenId The id of the token to render.
    function _tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory name = tokenIdToTime[_tokenId];
        Date memory date = tokenIdToTimeStruct[_tokenId];

        return
            string(
                abi.encodePacked(
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"Collect your favourite Time. Set your time. Mint your minute!.", ',
                                '"attributes": ',
                                getAttributes(date),
                                ', "image":"',
                                svgToImageURI(renderer.render(date)),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    /// @dev Render the JSON Metadata for a given rarity NFTIME.
    /// @param _tokenId The id of the token to render.
    /// @param _ipfsURI Custom ipfs uri.
    function _rarityTokenURI(
        uint256 _tokenId,
        string memory _ipfsURI,
        string memory _name,
    ) public view returns (string memory) {
        Date memory date = tokenIdToRarityTimeStruct[_tokenId];

        return
            string(
                abi.encodePacked(
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                _name,
                                '", "description":"Collect your favourite Time. Set your time. Mint your minute!.", ',
                                '"attributes": ',
                                getAttributes(date),
                                ', "image":"',
                                _ipfsURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    /// @dev IPFS Link to Opensea Collection Metadata.
    function contractURI() public pure returns (string memory) {
        return "ipfs://QmU5vDC1JkEASspnn3zF5WKRraXhtmrKPvWQL2Uwh6X1Wb";
    }

    /// @dev Base URI for Metadata.
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /// @dev Concat all the date attributes.
    /// @param date The used datestruct {Datetime}.
    function getAttributes(
        Date memory date
    ) internal pure returns (string memory) {
        return
            string.concat(
                "[",
                concatAttribute("year", Strings.toString(date.year)),
                ",",
                concatAttribute("month", date.month),
                ",",
                concatAttribute("day", date.day),
                ",",
                concatAttribute("hour", date.hour),
                ",",
                concatAttribute("minute", date.minute),
                "]"
            );
    }

    /// @dev Concat metadata attribute.
    /// @param label Label of the attribute.
    /// @param attribute Value of the attribute.
    function concatAttribute(
        string memory label,
        string memory attribute
    ) internal pure returns (string memory) {
        return
            string.concat(
                "{",
                '"trait_type": "',
                label,
                '", "value": "',
                attribute,
                '"}'
            );
    }

    /// @dev Encodes svg into base64.
    /// @param _svg SVG code.
    function svgToImageURI(
        string memory _svg
    ) internal pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(_svg)))
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    /// @dev Set a new Renderer Contract.
    /// @param _renderer New Renderer Address.
    function setRenderer(
        Renderer _renderer
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        renderer = _renderer;
    }

    /// @dev Update DEFAULT_ADMIN_ROLE.
    /// @param _multisig New multisig address.
    function setDefaultAdminRole(
        address _multisig
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
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

    /// @dev Overrides of required Methods
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
