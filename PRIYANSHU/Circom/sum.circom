pragma circom 2.0.0;

template Sum() {
    signal input a;
    signal input b;
    signal output sum;

    sum <== a + b;
}

component main = Sum();
