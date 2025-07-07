
---

## ✅ Chainlink VRF v2.5 – Random Number Generation on Sepolia

### 📌 Goal: Generate a verifiable, on-chain random number using a `bytes32` (long) subscription ID

---

### 🔧 **Step 1: Setup Chainlink VRF Subscription**

* Created a Chainlink VRF **v2.5 subscription** on [https://vrf.chain.link/sepolia](https://vrf.chain.link/sepolia).
* Received a **77-digit (bytes32-style) subscription ID**.
* Funded the subscription with **10 LINK initially**.

---

### 🧱 **Step 2: Write & Deploy Smart Contract**

* Used a special contract compatible with **VRF v2.5** using:

  ```solidity
  import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
  import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
  import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
  ```
* Used the **long `uint256` subscription ID** directly.
* Selected `nativePayment: false` (pay in LINK).
* Deployed the contract on **Sepolia** using Remix and MetaMask.

---

### ➕ **Step 3: Add Contract as Consumer**

* Added the deployed contract address to the **consumer list** of the subscription via Chainlink's dashboard.
* This step was critical to allow the contract to request random words.

---

### 💰 **Step 4: Funded Contract with ETH (Optional)**

* Sent **0.01 ETH** to the deployed contract to support native gas payments (not strictly needed in LINK mode, but useful if switched to ETH).

---

### 📞 **Step 5: Requested Random Number**

* Called `requestRandomNumber()` from the contract.
* This submitted a request to the Chainlink VRF Coordinator.

---

### ⚠️ **Step 6: Debugged Fulfillment Failure**

* Saw success on the request transaction — but no random word appeared.
* Chainlink dashboard showed:
  ❗ **"You have pending transactions due to low balance"**
* Root cause: **10 LINK was not enough to cover fulfillment costs**.

---

### ✅ **Step 7: Funded Subscription With More LINK**

* Added **30 more LINK** (total \~40 LINK).
* Chainlink fulfilled the pending request shortly after.

---

### 🎉 **Step 8: Random Word Fulfilled**

* `fulfillRandomWords()` was called by Chainlink.
* `randomWord` in the contract updated with a **verifiable random number**.

---

### 📦 **Step 9: Stored and Used the Random Number**

* You can now use this random number for:

  * Algebraic signatures
  * Cryptographic commitments
  * Lottery/gaming logic
  * On-chain verification

---


| Task                       | Tip                                                           |
| -------------------------- | ------------------------------------------------------------- |
| Want simpler gas logic     | Use `nativePayment: true` and pay gas in ETH                  |
| Doing many requests        | Always keep LINK balance topped up (or switch to ETH payment) |
| Need on-chain verification | Store the random word and expose via public getter            |
| Want logs or UI feedback   | Emit `event RandomFulfilled(uint256 word)` in your callback   |

---
