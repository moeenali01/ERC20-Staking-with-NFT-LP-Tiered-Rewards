# 🚀  ERC20 Staking with NFT LP & Tiered Rewards 

![Ethereum](https://img.shields.io/badge/Network-Holesky_Testnet-blue?style=flat-square&logo=ethereum)
![Foundry](https://img.shields.io/badge/Deployed_With-Foundry-orange?style=flat-square)
![Etherscan Verified](https://img.shields.io/badge/Contract_Verified-Yes-green?style=flat-square)

## 📜 Description

The **Staking Contract** allows users to stake tokens, earn LP tokens, and achieve tier-based badges. It integrates with the **LPToken** and **AchievementBadge** contracts for managing LP tokens and badges, respectively. This contract provides a time-weighted score for each staker and automatically tracks tier achievements based on the staked amount.

### **Key Features:**

- 🔒 **Token Staking**: Allows users to stake tokens and receive LP tokens in return.
- 💎 **Time-Weighted Score**: Users accumulate a time-weighted score based on their staked amount and time.
- 🏅 **Tier System**: Users can achieve various tiers (Bronze, Silver, Gold) based on the amount staked.
- 🏆 **Achievement Badges**: Badges are minted and awarded to users when they achieve a new tier.
- 🔄 **Restaking**: Users can simulate claiming and restaking rewards to continue earning time-weighted scores.
- 🎉 **LP Token Metadata Updates**: The LP token metadata is updated based on the staked amount, time-weighted score, and current tier.
  
---

## 📡 Deployment Details
- **Network:** Ethereum (Holesky Testnet)
- **Chain ID:** `17000` <!-- Add Chain ID if applicable -->
- **LPToken Contract Address:** [`0xDcAac05D866cD831b2dfBeF430407cfB5C67390d`](https://holesky.etherscan.io/address/0xDcAac05D866cD831b2dfBeF430407cfB5C67390d#code)
- **StakingToken Contract Address:** [`0xad5Bf8369807c38f7D2C75FcAbC1D52b235A0cF9`](https://holesky.etherscan.io/address/0xad5Bf8369807c38f7D2C75FcAbC1D52b235A0cF9#code)
- **AchievementBadge Contract Address:** [`0x3486758dfd2dC7C24E8c8Fef4A3943AE3bb806F5`](https://holesky.etherscan.io/address/0x3486758dfd2dC7C24E8c8Fef4A3943AE3bb806F5#code)
- **StakingContract Address:** [`0x7309D926452A989A94440e8E1C20B0573b69138f`](https://holesky.etherscan.io/address/0x7309D926452A989A94440e8E1C20B0573b69138f#code)
- **Etherscan Verification:** ✅ Verified
- **Explorer Link:** [View on Etherscan](https://holesky.etherscan.io/address/0x7309D926452A989A94440e8E1C20B0573b69138f#code)

---

## 🛠 Installation & Setup  
Follow these steps to interact with the contract using Foundry:

### **Clone the repository**
```sh
git clone https://github.com/your-repository/Staking-Contract.git
cd Staking-Contract
