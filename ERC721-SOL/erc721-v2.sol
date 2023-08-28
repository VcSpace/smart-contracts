// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract SCWLT2 is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256 MAX_SUPPLY = 15;
    string public baseTokenURI;
    uint256 public currentTokenId = 1;

    constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
        baseTokenURI = baseURI;
    }

    function safeMint(address to) public {
        require(_tokenIdCounter.current() <= MAX_SUPPLY, "Mint error, has been max_supply.");
        uint256 tokenId = _tokenIdCounter.current() + 1;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        string memory token_id = Strings.toString(tokenId);
        string memory token_uri = string(abi.encodePacked(baseTokenURI, token_id, ".json"));
        _setTokenURI(tokenId, token_uri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) onlyOwner {
        super._burn(tokenId);
    }

    // function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    //     return super.tokenURI(tokenId);
    // }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function tokenURI(uint256 tokenid) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        // 拼接基本令牌URI和tokenid，返回完整的元数据URL
        string memory token_id = Strings.toString(tokenid);
        return string(abi.encodePacked(baseTokenURI, token_id, ".json"));
    }
}