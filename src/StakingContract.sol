// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LPToken.sol";
import "./AchievementBadge.sol";

contract StakingContract is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // Staking token
    IERC20 public stakingToken;

    // LP Token and Achievement Badge contracts
    LPToken public lpToken;
    AchievementBadge public achievementBadge;

    // Staker info
    struct Staker {
        uint256 tokenId; // LP Token ID
        uint256 amount; // Total staked amount
        uint256 lastStakeTime; // Timestamp of last stake
        uint256 timeWeightedScore; // Time-weighted score
        uint256 currentTier; // Current tier level
        mapping(uint256 => bool) achievedTiers; // Tiers already achieved
    }

    // Mapping of staker address to staker info
    mapping(address => Staker) public stakers;

    // Tier thresholds (in tokens, will be multiplied by 1e18 in constructor)
    uint256[] public tierThresholds;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event LPTokenMinted(address indexed user, uint256 tokenId);
    event AchievementBadgeMinted(address indexed user, uint256 tokenId, uint256 tier);
    event MetadataUpdated(
        address indexed user, uint256 tokenId, uint256 totalStaked, uint256 timeWeightedScore, uint256 currentTier
    );

    constructor(address _stakingToken, address _lpToken, address _achievementBadge) Ownable(msg.sender) {
        require(_stakingToken != address(0), "Invalid staking token address");
        require(_lpToken != address(0), "Invalid LP token address");
        require(_achievementBadge != address(0), "Invalid achievement badge address");

        stakingToken = IERC20(_stakingToken);
        lpToken = LPToken(_lpToken);
        achievementBadge = AchievementBadge(_achievementBadge);

        // Initialize tier thresholds (in wei)
        tierThresholds.push(1000 * 1e18); // Bronze - 1,000 tokens
        tierThresholds.push(5000 * 1e18); // Silver - 5,000 tokens
        tierThresholds.push(10000 * 1e18); // Gold - 10,000 tokens
    }

    // Function to stake tokens
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0 tokens");

        Staker storage staker = stakers[msg.sender];

        // Update time-weighted score before changing state
        _updateTimeWeightedScore(msg.sender);

        // Transfer tokens from user to contract
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        // Mint LP Token if first time staking
        if (staker.tokenId == 0) {
            uint256 tokenId = lpToken.mintToken(msg.sender);
            staker.tokenId = tokenId;
            emit LPTokenMinted(msg.sender, tokenId);
        }

        // Update staker info
        staker.amount += amount;
        staker.lastStakeTime = block.timestamp;

        // Check if staker has crossed any tier thresholds
        _checkAndUpdateTiers(msg.sender);

        // Update LP Token metadata
        _updateLPTokenMetadata(msg.sender);

        emit Staked(msg.sender, amount);
    }

    // Function to withdraw tokens
    function withdraw(uint256 amount) external nonReentrant {
        Staker storage staker = stakers[msg.sender];
        require(staker.amount > 0, "No stake found");
        require(staker.amount >= amount, "Insufficient staked amount");

        // Update time-weighted score before changing state
        _updateTimeWeightedScore(msg.sender);

        // Update staker info
        staker.amount -= amount;
        staker.lastStakeTime = block.timestamp;

        // Transfer tokens from contract to user
        stakingToken.safeTransfer(msg.sender, amount);

        // Update LP Token metadata
        _updateLPTokenMetadata(msg.sender);

        emit Withdrawn(msg.sender, amount);
    }

    // Function to restake (simulate claiming and restaking rewards)
    function restake() external nonReentrant {
        Staker storage staker = stakers[msg.sender];
        require(staker.amount > 0, "No stake found");

        // Update time-weighted score before resetting time
        _updateTimeWeightedScore(msg.sender);

        // Reset last stake time to now (simulating restaking)
        staker.lastStakeTime = block.timestamp;

        // Update LP Token metadata
        _updateLPTokenMetadata(msg.sender);
    }

    // Internal function to update time-weighted score
    function _updateTimeWeightedScore(address user) internal {
        Staker storage staker = stakers[user];

        if (staker.amount > 0 && staker.lastStakeTime > 0) {
            uint256 timeElapsed = block.timestamp - staker.lastStakeTime;
            staker.timeWeightedScore += staker.amount * timeElapsed;
        }
    }

    // Internal function to check and update tiers
    function _checkAndUpdateTiers(address user) internal {
        Staker storage staker = stakers[user];

        // Find the highest tier threshold that the staker has surpassed
        uint256 newTier = 0;
        for (uint256 i = 0; i < tierThresholds.length; i++) {
            if (staker.amount >= tierThresholds[i]) {
                newTier = i + 1;
            } else {
                break;
            }
        }

        // If staker has reached a new tier, mint achievement badges for all new tiers
        if (newTier > staker.currentTier) {
            for (uint256 i = staker.currentTier + 1; i <= newTier; i++) {
                if (!staker.achievedTiers[i]) {
                    uint256 badgeId = achievementBadge.mintBadge(user, i);
                    staker.achievedTiers[i] = true;
                    emit AchievementBadgeMinted(user, badgeId, i);
                }
            }

            staker.currentTier = newTier;
        }
    }

    // Internal function to update LP Token metadata
    function _updateLPTokenMetadata(address user) internal {
        Staker storage staker = stakers[user];

        // Ensure the correct amount is passed, including restakes
        uint256 currentAmount = staker.amount;
        uint256 currentScore = staker.timeWeightedScore;
        uint256 currentTier = staker.currentTier;

        // Update the metadata of the LP token with the correct details
        lpToken.updateTokenMetadata(
            staker.tokenId,
            currentAmount, // Ensure updated stake amount is passed
            currentScore, // Ensure time-weighted score is passed
            currentTier // Ensure current tier is passed
        );

        // Emit event for metadata update (this is helpful for logging and UI updates)
        emit MetadataUpdated(user, staker.tokenId, currentAmount, currentScore, currentTier);
    }

    // View function to get staker info
    function getStakerInfo(address user)
        external
        view
        returns (uint256 tokenId, uint256 amount, uint256 lastStakeTime, uint256 timeWeightedScore, uint256 currentTier)
    {
        Staker storage staker = stakers[user];
        return (staker.tokenId, staker.amount, staker.lastStakeTime, staker.timeWeightedScore, staker.currentTier);
    }

    // View function to calculate current time-weighted score
    function getCurrentTimeWeightedScore(address user) external view returns (uint256) {
        Staker storage staker = stakers[user];

        if (staker.amount == 0 || staker.lastStakeTime == 0) {
            return staker.timeWeightedScore;
        }

        uint256 additionalScore = staker.amount * (block.timestamp - staker.lastStakeTime);
        return staker.timeWeightedScore + additionalScore;
    }

    // View function to check if staker has achieved a specific tier
    function hasTierBadge(address user, uint256 tier) external view returns (bool) {
        return stakers[user].achievedTiers[tier];
    }
}
