
const contractAddress = "0x7c3b52f2b552cFF00b07262A79A909799bdeFCF5"; // Replace this
const abi = [
	{
		"inputs": [
			{
				"internalType": "uint256[2]",
				"name": "_pA",
				"type": "uint256[2]"
			},
			{
				"internalType": "uint256[2][2]",
				"name": "_pB",
				"type": "uint256[2][2]"
			},
			{
				"internalType": "uint256[2]",
				"name": "_pC",
				"type": "uint256[2]"
			},
			{
				"internalType": "uint256[1]",
				"name": "_pubSignals",
				"type": "uint256[1]"
			}
		],
		"name": "verifyProof",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]; // Replace with your contract's ABI from Remix

async function verify() {
    if (window.ethereum) {
        const web3 = new Web3(window.ethereum);
        await window.ethereum.enable();

        const a = JSON.parse(document.getElementById("a").value);
        const b = JSON.parse(document.getElementById("b").value);
        const c = JSON.parse(document.getElementById("c").value);
        const input = JSON.parse(document.getElementById("input").value);

        const contract = new web3.eth.Contract(abi, contractAddress);
        const accounts = await web3.eth.getAccounts();

        try {
            const result = await contract.methods.verifyProof(a, b, c, input)
                .call({ from: accounts[0] });

            document.getElementById("result").innerText = result ? "✅ Valid Proof" : "❌ Invalid Proof";
        } catch (err) {
            console.error(err);
            document.getElementById("result").innerText = "❌ Error verifying proof. Check the input format.";
        }
    } else {
        alert("Please install MetaMask!");
    }
}
