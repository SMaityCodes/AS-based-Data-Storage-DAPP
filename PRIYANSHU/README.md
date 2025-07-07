# Circom_Verifier.sol-With-FrontEnd.



## 🧮 Step 1: Circuit Definition

The circuit is `sum.circom`. It takes two inputs `a` and `b`, and outputs their sum.



## ⚙️ Step 2: Compile the Circuit

Run the following command:

```bash
circom sum.circom --r1cs --wasm --sym
```



## 🧾 Step 3: Generate the Witness

Create an `input.json` file with the input values for `a` and `b`, then run:

```bash
node sum_js/generate_witness.js sum_js/sum.wasm input.json witness.wtns
```



## ✅ Step 4: Generate the ZK Proof

Run the following to generate the proof and public signals:

```bash
snarkjs groth16 prove sum_final.zkey witness.wtns proof.json public.json
```


## 🧾 Step 5: Generate the Solidity Verifier

Generate the smart contract using:

```bash
snarkjs zkey export solidityverifier sum_final.zkey verifier.sol
```


## 🚀 Step 6: Deploy `verifier.sol` on Remix

1. Open [Remix IDE](https://remix.ethereum.org)
2. Paste/upload the `verifier.sol` file.
3. Compile it using the correct Solidity version.
4. Go to "Deploy & Run Transactions".
5. Select **Injected Provider - MetaMask** as the environment.
6. Deploy the contract and confirm the transaction.

After deployment:

* Copy the contract address.
* Use the ℹ️ icon next to the deployed contract to copy the ABI.



## 🌐 Step 7: Create the Frontend in VS Code

Create a frontend using `index.html` and `app.js`:

* Input fields for:

  * `A`: 2 values
  * `B`: 2x2 values
  * `C`: 2 values
  * Public Inputs: 1 value (`sum`)

Use VS Code’s **Live Server** to run the frontend locally in your browser.



## 🔐 Step 8: Use `snarkjs generatecall`

Run:

```bash
snarkjs generatecall
```

This returns the proof components (`a`, `b`, `c`) and the public `input[]` formatted for Solidity.

Paste these values into your frontend fields.



## ✅ Output

* If inputs and proof are valid: ✅ **Valid Proof**
* If not: ❌ **Invalid Proof**


