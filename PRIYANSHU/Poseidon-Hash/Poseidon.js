const circomlibjs = require("circomlibjs");

async function main() {
    const poseidon = await circomlibjs.buildPoseidon();
    
    const a = 123n;
    const b = 456n;

    const hash = poseidon([a, b]);

    // Get the output as a decimal string
    const hashStr = poseidon.F.toString(hash);
    
    console.log("Input A:", a.toString());
    console.log("Input B:", b.toString());
    console.log("Poseidon Hash:", hashStr);
}

main();
