# SAG4Fun - An Open Source Sheep-And-Goats (SAG) and Inverse SAG Verilog IP

This core implements four bit manipulation instructions: SAG, ISG, EXT, DEP.
All of those instructions receive a data word in their first operand, and a bit
mask in the second operand.

The file [sag4fun.v](sag4fun.v) provides implementations for 32 and 64 bits:

| Verilog Module | Description                                  |
| -------------- | -------------------------------------------- |
| SAG4Fun32C     | 32-Bit combinatorial logic                   |
| SAG4Fun32S     | 32-Bit 5-step sequential core                |
| SAG4Fun64C     | 64-Bit combinatorial logic                   |
| SAG4Fun64S     | 64-Bit 6-step sequential core                |
| SAG4Fun64F     | 64-Bit 3-step sequential core                |

## Description of the SAG, ISG, EXT, and DEP Operation

Extract (EXT) and Deposit (DEP) are equivalent to the [x86 PEXT and PDEP
instructions](https://en.wikipedia.org/wiki/X86_Bit_manipulation_instruction_set#Parallel_bit_deposit_and_extract).
Hacker's Delight calls EXT "compress" and DEP "expand".

The EXT (or "compress") instructions takes the data bits selected by the 1 bits
in the mask operand, and places them in at the right (LSB) end of the output
word, filling the remaining MSB bits with zeros.

The DEP (or "expand") instruction performs the opposite operation: it takes as
many data bits from the LSB end of the data operand, and places them in the
locations selected by 1 bits in the mask operand. The remaining output bits are
set to zero.

The Sheep-And-Goats (SAG) instruction performs a similar operation as EXT, but
instead of leaving the MSB bits at zero, this instruction takes the remaining
data bits and places them in the MSB bits of the output, in reversed order.

The Inverse Sheep-And-Goats (ISG) instruction is the inverse of the SAG
instruction. It places the LSB data bits in the 1 positions in the mask,
and places the remaining data bits in the remaining output positions, in
reversed order.

## Variants without reversed order of "goat" bits

A variant of the Sheep-And-Goats (SAG) instruction that does not reverse the
order of the unmarked data bits in significantly harder to implement in hardware,
and is thus best emulated using the following sequence of three instructions:

```
sag rd, rs1, rs2
sag rt, rs2, rs2
sag rd, rd, rt
```

(`rs1` and `rs2` are the data and mask operand, `rd` is the destination register, and
`rt` is a temporary register.)

Similarly, the Inverse Sheep-And-Goats instruction without revsed order of the
unmarked data bits:

```
sag rd, rs2, rs2
sag rd, rs1, rd
isg rd, rd, rs2
```
