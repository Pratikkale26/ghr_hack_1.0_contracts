// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DataNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct License {
        uint256 validUntil;
        string terms;
    }

    mapping(uint256 => License) public licenses;

    constructor() ERC721("DataNFT", "DNFT") Ownable(msg.sender) {}


    function mintNFT(
        address recipient, 
        string memory tokenURI_, 
        uint256 validityPeriod, 
        string memory terms
    ) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI_);

        licenses[newItemId] = License({
            validUntil: block.timestamp + validityPeriod,
            terms: terms
        });

        // emit Transfer event so frontend can detect minting
        emit Transfer(address(0), recipient, newItemId);

        return newItemId;
    }

    function transferNFT(address to, uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        _transfer(msg.sender, to, tokenId);

        // Emit Transfer event for frontend to track ownership changes
        emit Transfer(msg.sender, to, tokenId);
    }

    
}
