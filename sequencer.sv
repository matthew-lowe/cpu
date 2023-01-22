module Sequencer (CtlBus ctlbus, SysBus sysbus, Registers registers);
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

    `include "control_sig.h"
    `include "opcodes.h"

    enum {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15} state, n_state;

    // Helper functions to get bits of the instructions we may want
    // Instruction layout likely to change
    function logic[3:0] opcode(logic [15:0] instr);
        return intr[13:10];
    endfunction : opcode

    function logic[1:0] addr(logic [15:0] instr);
        return intr[9:8];
    endfunction : addr

    function logic[3:0] op0(logic [15:0] instr);
        return intr[7:4];
    endfunction : op0

    function logic[3:0] addr(logic [15:0] instr);
        return intr[3:0];
    endfunction : addr

    always_ff @(posedge ctlbus.clock, negedge ctlbus.n_reset) begin
        ctlbus.dev = 2'b00;
        ctlbus.opaddr = 4'b0000; // TODO: MAR as default address bus contents
        ctlbus.ldstr = 0;

        if (!ctlbus.n_reset)
            state <= S0;
        else
            state <= n_state;
    end

    always_comb unique case(state)
        // FETCH
        S0: begin
            registers.MAR = registers.PC;
            registers.PC += 1;
            n_state = S1;
        end
        S1: begin
            ctlbus.dev = `ROM;
            ctlbus.opaddr = registers.MAR;
            n_state = S2;
        end
        S2: begin
            registers.MDR = sysbus.data;
            registers.IR = registers.MDR;
            // DECODE
            case (opcode(registers.IR)) inside
                // ALU Operations
                `ADD,`SUB,[`AND:`LSR]: n_state = S3;
                // Unconditional branch
                `B,`BGT,`BLT: n_state = S6;
                // Branch equal
                `BEQ: n_state = S7;
                // Branch not equal
                `BNE: n_state = S9;
                // Load
                `LDR: n_state = S11;
                // Store
                `STR: n_state = S15;
                default: n_state = S0;
            endcase
        end
        // EXECUTE
        S3: begin
            registers.ACC = op0(registers.IR);
            n_state = S4;
        end
        S4: begin
            sysbus.data = op1(registers.IR);
            ctlbus.dev = `ALU;
            ctlbus.opaddr = opcode(registers.IR);
            ctlbus.ldstr = `LDR;
            n_state = S5;
        end
        S5: begin
            op1(registers.IR) = registers.ACC;
            n_state = S0;
        end
        S6: begin
            registers.PC = op0(registers.IR) - 1;
            n_state = S0;
        end
        S7: begin
            sysbus.data = op0(registers.IR);
            ctlbus.dev = `ALU;
            ctlbus.opaddr = `EOR;
            ctlbus.ldstr = `LDR;
            n_state = S8;
        end
        S8: begin
            if (registers.ACC == 0)
                registers.PC = op0(registers.IR) - 1;
            n_state = S0;
        end
        S9: begin
            sysbus.data = op0(registers.IR);
            ctlbus.dev = `ALU;
            ctlbus.opaddr = `EOR;
            ctlbus.ldstr = `LDR;
            n_state = S10;
        end
        S10: begin
            if (registers.ACC != 0)
                registers.PC = op0(registers.IR) - 1;
            n_state = S0;
        end
        S11: begin

        end

        default: n_state <= S0;
    endcase

endmodule : Sequencer
