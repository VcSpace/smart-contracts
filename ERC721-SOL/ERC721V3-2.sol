// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract SCWLT2 is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256 public MAX_MINT_PER_WALLET = 2;
    uint256 MAX_SUPPLY = 15;
    string public baseTokenURI;
    uint256 public MINT_PRICE = 1000000 gwei;
    mapping(address => uint) public mintCount;

    constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
        baseTokenURI = baseURI;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        MINT_PRICE = _mintPrice;
    }

    function safeMint(address to, uint256 amount) external payable whenNotPaused {
        require(_tokenIdCounter.current() + amount <= MAX_SUPPLY, "Mint error, max supply reached.");
        require(mintCount[to] + amount <= MAX_MINT_PER_WALLET, "Max mint per wallet reached");
        require(amount <= MAX_MINT_PER_WALLET, "Max mint per tx reached");
        require(msg.value == MINT_PRICE * amount, "Insufficient funds");

        uint256 tokenId = _tokenIdCounter.current() + 1;
        _tokenIdCounter.increment();
        mintCount[to] += amount;
        _safeMint(to, tokenId);

        string memory token_uri = tokenURI(tokenId);
        _setTokenURI(tokenId, token_uri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdraw(address payable to) public onlyOwner {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) = to.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function supportsInterface(bytes4 interfaceId) public
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