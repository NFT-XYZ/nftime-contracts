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

    event Mint(address indexed _address, uint256 _tokenId);

    // 01.JAN 2030 12:00 -> true / false
    mapping(string => bool) public mintedTimes;
    // 1 -> 01.JAN 2030 12:00
    mapping(uint256 => string) public tokenIdToTime;
    // 1 -> [year:'2030',month:'JAN',day:'01',hour:'11',minute:'00']
    mapping(uint256 => Date) public tokenIdToTimeStruct;

    constructor(address _renderer, address _multisig) ERC721("NFTIME", "TIME") {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
        renderer = Renderer(_renderer);
    }

    function mint(uint256 _time)
        public
        payable
        whenNotPaused
        returns (uint256)
    {
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

        _setTokenURI(newItemId, tokenURI(newItemId));

        emit Mint(msg.sender, newItemId);

        return newItemId;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory name = tokenIdToTime[_tokenId];
        Date memory date = tokenIdToTimeStruct[_tokenId];

        return
            string(
                abi.encodePacked(
                    _baseURI(),
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

    function contractURI() public pure returns (string memory) {
        return "ipfs://QmU5vDC1JkEASspnn3zF5WKRraXhtmrKPvWQL2Uwh6X1Wb";
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function getAttributes(Date memory date)
        internal
        pure
        returns (string memory)
    {
        return
            string.concat(
                "[",
                concatAttribute("year", date.year),
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

    function concatAttribute(string memory label, string memory attribute)
        internal
        pure
        returns (string memory)
    {
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

    function svgToImageURI(string memory _svg)
        internal
        pure
        returns (string memory)
    {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(_svg)))
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function setRenderer(Renderer _renderer)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        renderer = _renderer;
    }

    function setDefaultAdminRole(address _multisig)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, _multisig);
    }

    function pauseTransactions() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function resumeTransactions() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function withdraw() public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Unable to withdraw");
    }

    // Overrides of required Method
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _burn(uint256 _tokenId)
        internal
        override(ERC721, ERC721URIStorage)
        whenNotPaused
    {
        super._burn(_tokenId);
    }

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
