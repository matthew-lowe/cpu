module Sequencer (CtlBus ctlbus, SysBus sysbus, Registers registers);
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
        if (!ctlbus.n_reset)
            state <= S0;
        else
            state <= n_state;
    end

    always_comb begin
        ctlbus.dev = 2'b00;
        ctlbus.opaddr = 4'b0000; // TODO: MAR as default address bus contents
        ctlbus.ldstr = 0;
        sysbus.data = 'z;
        unique case(state)
        // FETCH
        S0: begin
            ctlbus.dev =

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
        // ALU Operations
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
        // Unconditional Branch
        S6: begin
            registers.PC = op0(registers.IR) - 1;
            n_state = S0;
        end
        // Branch equal
        S7: begin
            sysbus.data = op0(registers.IR);
            ctlbus.opaddr = `EOR;
            ctlbus.ldstr = `LDR;
            n_state = S8;
        end
        S8: begin
            if (registers.ACC == 0)
                registers.PC = op0(registers.IR) - 1;
            n_state = S0;
        end
        // Branch not equal
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
        // Load op
        S11: begin
            registers.MAR = op0(registers.IR);
            ctlbus.opaddr = registers.MAR;
            if (addr(`DIR))
                n_state = S12;
            else if(addr(`ROM))
                n_state = S14;
        end
        // RAM Load
        S12: begin
            ctlbus.dev = `RAM;
            ctlbus.opaddr = op0(registers.IR);
            ctlbus.ldstr = 0;
            registers.MDR = sysbus.data;
            n_state = S14;
        end
        // ROM Load
        S13: begin
            ctlbus.dev = `Rom;
            ctlbus.opaddr = op0(registers.IR);
            registers.MDR = sysbus.data;
            n_state = S14;
        end
        // Load MDR into register
        S14: begin
            registers.R[op1(registers.IR)] = registers.MDR;
            n_state = S0;
        end
        // Store
        S15: begin
            registers.MDR = op0(registers.IR);
            registers.MAR = op1(registers.IR);
            ctlbus.dev = `RAM;
            ctlbus.opaddr = registers.MAR;
            sysbus.data = registers.MDR;
            n_state = S16;
        end
        S16: begin
            ctlbus.dev = `RAM;
            ctlbus.opaddr = registers.MAR;
            sysbus.data = registers.MDR;
            ctlbus.ldstr = `STR;
            n_state = S0;
        end

        default: n_state <= S0;
    endcase
end

endmodule : Sequencer
