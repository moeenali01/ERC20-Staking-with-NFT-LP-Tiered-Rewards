// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract LPToken is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    address public stakingContract;

    // Mapping to store token metadata
    mapping(uint256 => StakerInfo) public stakerInfo;

    struct StakerInfo {
        uint256 totalStaked;
        uint256 timeWeightedScore;
        uint256 currentTier;
    }

    event MetadataUpdated(uint256 indexed tokenId, uint256 totalStaked, uint256 timeWeightedScore, uint256 currentTier);

    constructor() ERC721("LP Token", "LPT") Ownable(msg.sender) {}

    function setStakingContract(address _stakingContract) external onlyOwner {
        require(_stakingContract != address(0), "Invalid staking contract address");
        stakingContract = _stakingContract;
    }

    modifier onlyStakingContract() {
        require(msg.sender == stakingContract, "Only staking contract can call this function");
        _;
    }

    function mintToken(address to) external onlyStakingContract returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        // Initialize staker info
        stakerInfo[tokenId] = StakerInfo({totalStaked: 0, timeWeightedScore: 0, currentTier: 0});

        // Set initial token URI
        _setTokenURI(tokenId, generateTokenURI(tokenId));

        return tokenId;
    }

    function updateTokenMetadata(uint256 tokenId, uint256 totalStaked, uint256 timeWeightedScore, uint256 currentTier)
        external
        onlyStakingContract
    {
        // Replace _exists(tokenId) with a check to see if the token has an owner
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        stakerInfo[tokenId].totalStaked = totalStaked;
        stakerInfo[tokenId].timeWeightedScore = timeWeightedScore;
        stakerInfo[tokenId].currentTier = currentTier;

        // Update token URI
        _setTokenURI(tokenId, generateTokenURI(tokenId));

        emit MetadataUpdated(tokenId, totalStaked, timeWeightedScore, currentTier);
    }

    function generateTokenURI(uint256 tokenId) internal view returns (string memory) {
        StakerInfo memory info = stakerInfo[tokenId];

        string memory tierName;
        if (info.currentTier == 0) {
            tierName = "None";
        } else if (info.currentTier == 1) {
            tierName = "Bronze";
        } else if (info.currentTier == 2) {
            tierName = "Silver";
        } else if (info.currentTier == 3) {
            tierName = "Gold";
        }

        string memory json = string(
            abi.encodePacked(
                '{"name":"LP Token #',
                Strings.toString(tokenId),
                '","description":"Staking LP Token","image":"data:image/svg+xml;base64,',
                generateSVGImage(tokenId, info),
                '","attributes":[',
                '{"trait_type":"Total Staked","value":"',
                Strings.toString(info.totalStaked / 1e18),
                '"},',
                '{"trait_type":"Time-Weighted Score","value":"',
                Strings.toString(info.timeWeightedScore / 1e18),
                '"},',
                '{"trait_type":"Current Tier","value":"',
                tierName,
                '"}',
                "]}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    function generateSVGImage(uint256 tokenId, StakerInfo memory info) internal pure returns (string memory) {
        // Generate a basic SVG image based on tier and staking info
        string memory tierColor;
        if (info.currentTier == 0) {
            tierColor = "#CCCCCC"; // Gray
        } else if (info.currentTier == 1) {
            tierColor = "#CD7F32"; // Bronze
        } else if (info.currentTier == 2) {
            tierColor = "#C0C0C0"; // Silver
        } else if (info.currentTier == 3) {
            tierColor = "#FFD700"; // Gold
        }

        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350" viewBox="0 0 350 350">',
                '<rect width="100%" height="100%" fill="',
                tierColor,
                '" />',
                '<circle cx="175" cy="175" r="120" fill="white" stroke="black" stroke-width="2"/>',
                '<text x="175" y="125" font-family="Arial" font-size="24" text-anchor="middle">LP Token #',
                Strings.toString(tokenId),
                "</text>",
                '<text x="175" y="175" font-family="Arial" font-size="16" text-anchor="middle">Total Staked: ',
                Strings.toString(info.totalStaked / 1e18),
                "</text>",
                '<text x="175" y="205" font-family="Arial" font-size="16" text-anchor="middle">Score: ',
                Strings.toString(info.timeWeightedScore / 1e18),
                "</text>",
                "</svg>"
            )
        );

        return Base64.encode(bytes(svg));
    }
}
