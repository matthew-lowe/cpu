// Opcodes
`define LDR 4'b0000
`define STR 4'b0001
`define ADD 4'b0010
`define SUB 4'b0011
`define MOV 4'b0100
`define B   4'b0101
`define BEQ 4'b0110
`define BNE 4'b0111
`define BGT 4'b1000
`define BLT 4'b1001
`define AND 4'b1010
`define ORR 4'b1011
`define EOR 4'b1100
`define MVN 4'b1101
`define LSL 4'b1110
`define LSR 4'b1111

// Addressing modes
`define DIR 2'b00
`define PCR 2'b01
`define REG 2'b10
`define IMM 2'b11

// Misc
`define NON 4'b0000
