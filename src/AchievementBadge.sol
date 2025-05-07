// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract AchievementBadge is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address public stakingContract;

    // Define tier names and descriptions
    mapping(uint256 => string) public tierNames;
    mapping(uint256 => string) public tierDescriptions;
    mapping(uint256 => string) public tierColors;

    event BadgeMinted(address indexed to, uint256 indexed tokenId, uint256 tier);

    constructor() ERC721("Achievement Badge", "BADGE") Ownable(msg.sender) {
        // Initialize tiers
        tierNames[1] = "Bronze";
        tierNames[2] = "Silver";
        tierNames[3] = "Gold";

        tierDescriptions[1] = "Staked at least 1,000 tokens";
        tierDescriptions[2] = "Staked at least 5,000 tokens";
        tierDescriptions[3] = "Staked at least 10,000 tokens";

        tierColors[1] = "#CD7F32"; // Bronze
        tierColors[2] = "#C0C0C0"; // Silver
        tierColors[3] = "#FFD700"; // Gold
    }

    function setStakingContract(address _stakingContract) external onlyOwner {
        require(_stakingContract != address(0), "Invalid staking contract address");
        stakingContract = _stakingContract;
    }

    modifier onlyStakingContract() {
        require(msg.sender == stakingContract, "Only staking contract can call this function");
        _;
    }

    function mintBadge(address to, uint256 tier) external onlyStakingContract returns (uint256) {
        require(tier > 0 && tier <= 3, "Invalid tier");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        // Set token URI based on tier
        _setTokenURI(tokenId, generateTokenURI(tokenId, tier));

        emit BadgeMinted(to, tokenId, tier);

        return tokenId;
    }

    function generateTokenURI(uint256 tokenId, uint256 tier) internal view returns (string memory) {
        string memory json = string(
            abi.encodePacked(
                '{"name":"',
                tierNames[tier],
                " Badge #",
                Strings.toString(tokenId),
                '","description":"',
                tierDescriptions[tier],
                '","image":"data:image/svg+xml;base64,',
                generateSVGImage(tokenId, tier),
                '","attributes":[',
                '{"trait_type":"Tier","value":"',
                tierNames[tier],
                '"},',
                '{"trait_type":"Tier Level","value":"',
                Strings.toString(tier),
                '"}',
                "]}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function generateSVGImage(uint256 tokenId, uint256 tier) internal view returns (string memory) {
        // Generate a basic badge SVG image based on tier
        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350" viewBox="0 0 350 350">',
                '<polygon points="175,50 220,150 325,150 240,220 265,320 175,260 85,320 110,220 25,150 130,150" fill="',
                tierColors[tier],
                '" stroke="black" stroke-width="2"/>',
                '<text x="175" y="190" font-family="Arial" font-size="24" font-weight="bold" text-anchor="middle">',
                tierNames[tier],
                "</text>",
                '<text x="175" y="215" font-family="Arial" font-size="16" text-anchor="middle">Badge #',
                Strings.toString(tokenId),
                "</text>",
                "</svg>"
            )
        );

        return Base64.encode(bytes(svg));
    }
}
