// Location select
`define ALU 2'b00
`define REG 2'b01
`define RAM 2'b10
`define ROM 2'b11


// Register select (n = Rn if not here)
`define FLG = 4'b1010
`define ACC = 4'b1011
`define PC  = 4'b1100
`define IR  = 4'b1101
`define MAR = 4'b1110
`define MDR = 4'b1111

// ALU Operations
`define ADD = 4'b0000
`define SUB = 4'b0001
`define MOV = 4'b0010
`define AND = 4'b0011
`define ORR = 4'b0100
`define EOR = 4'b0101
`define MVN = 4'b0110
`define LSL = 4'b0111
`define LSR = 4'b1000


// Register/RAM/ROM operation
`define LDR = 1'b0
`define STR = 1'b1