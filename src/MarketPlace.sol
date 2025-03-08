pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }
    
    mapping(address => mapping(uint256 => Listing)) public listings;
    uint256 public listingFee = 0.025 ether;
    address public feeRecipient;

    event Listed(address indexed nftContract, uint256 indexed tokenId, address seller, uint256 price);
    event Sold(address indexed nftContract, uint256 indexed tokenId, address buyer, uint256 price);

    constructor() {
        feeRecipient = msg.sender;
    }

    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external payable nonReentrant {
        require(msg.value == listingFee, "Incorrect listing fee");
        require(price > 0, "Price must be > 0");
        require(
            IERC721(nftContract).ownerOf(tokenId) == msg.sender,
            "Not NFT owner"
        );
        require(
            IERC721(nftContract).isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        listings[nftContract][tokenId] = Listing(msg.sender, price, true);
        emit Listed(nftContract, tokenId, msg.sender, price);
    }

    function buyNFT(address nftContract, uint256 tokenId) external payable nonReentrant {
        Listing memory listing = listings[nftContract][tokenId];
        require(listing.active, "Not for sale");
        require(msg.value >= listing.price, "Insufficient funds");

        delete listings[nftContract][tokenId];
        payable(listing.seller).transfer(listing.price);
        payable(feeRecipient).transfer(listingFee);
        IERC721(nftContract).safeTransferFrom(listing.seller, msg.sender, tokenId);
        
        emit Sold(nftContract, tokenId, msg.sender, listing.price);
    }
}
