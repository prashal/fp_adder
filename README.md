# 32-bit Single Precision Floating Point Adder
Floating Point Adder in VHDL and Verification of result with matlab code

## Introduction
This project was done as an help assignment of a junior friend. The entire 32-bit Floating Point Adder will be designed in VHDL. The design follows a bottom-up approach i.e all the building blocks (Adders/Muxes, etc) will be designed first and then instantiated in the top module.

## Implementation Details:
The project uses the IEEE-754 Single Precision floating point format. The following table lists how the 32-bit floating number is divided into 3 parts viz. Mantissa, Exponent and the Sign bit of length 23, 8 and 1 bits accordingly.

Using the above format, the floating point number can be expressed as follows -

(-1)*sign 1.mantissa x 2 ^ exponent

In the IEEE-754 format the first bit of mantissa is assumed to be 1 and the remaining part is the fractional part.

## Block Diagram of the adder -
The diagram given below gives a simple architecture of the Floating-Point adder -

![Alt text](docs/block.png?raw=true "Floting Point Adder Block Diagram")

Source : “Computer Organization and Architecture 3rd Edition – Hennessy and Patterson”.
To simplify the implementation, we have ignored the use of rounding hardware at the end of the FP-Adder.

## Building Blocks:

1. ALU – The adder uses to ALU (small and big) one for the mantissa bits and the other for the exponent bits. The ALU is responsible for finding the bigger number such that the normalization can take place easily.

2. Shifters – The shifters are used to perform the normalization. Depending on the shift value generated by the Control unit, the Mantissa/Exponents are shifted accordingly.

3. Control Unit – The Control Unit uses inputs at various stages and generates the expected control values for shifters/ALUs.

-Prasanta Halder
