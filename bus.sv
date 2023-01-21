interface CtlBus #(parameter BUS_W = 8)
    (input logic clock, n_reset);

    wire [1:0] dev;
    wire [3:0] opaddr;
    wire       ldstr;

    modport seq (
        input dev, opaddr, ldstr,
        output clock, n_reset);

    modport tmb (output dev, opaddr, ldstr, clock,n_reset);
endinterface : sysbus

interface SysBus #(parameter WORD_W = 16);
    wire [WORD_W-1:0] data;

    modport seq (
        inout data,
        output clock, n_reset);

    modport rom (
        input clock,
        output data, n_reset);

    modport registers (
        input clock,
        inout data, n_reset);
endinterface : sysbys

// Fetch:
// S0       PC -> MAR, PC + 1
// S1       MAR -> CTLBUS, READ ROM
// S2       SYSBUS -> MDR, MDR -> IR
// Execute:
//          ALU Op:
// S3            OP0 -> ACC
// S4            OP1 -(op)> ACC (with operation applied)
//          Branch Op:
// S5            PC = OP0
//          Conditional Branch Op:
//               BEQ:
// S6                OP0 -(^)> ACC
// S7                OP1 -> PC IF ACC == '0
//               BNE:
// S8                OP0 -(^)> ACC
// S9                OP1 -> PC IF ACC != '0
//               BGT and BLT:
//                   (unconditional for now
//          Load Op:
//               RAM:
// S10               OP0 -> MAR, MAR -> CTLBUS
// S11               READ RAM, SYSBUS -> MDR
// S12               MDR -> OP1
//               ROM:
// S10               OP0 -> MAR, MAR -> CTLBUS
// S13               READ ROM, SYSBUS -> MDR
// S12               MDR -> OP1
//           Store Op:
//               RAM:
// S14               OP0 -> MAR, OP1 -> MDR, MAR -> CTLBUS, MDR -> SYSBUS
// S15               WRITE RAM
