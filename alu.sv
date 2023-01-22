module Alu(CtlBus ctlbus, SysBus sysbus, Registers registers);
    `include "control_sig.h"
    `include "opcodes.h"

    always_comb begin
        if (ctlbus.dev == `ALU) case(ctlbus.opaddr)
            `ADD: registers.ACC += sysbus.data;
            `SUB: registers.ACC -= sysbus.data;
            `AND: registers.ACC &= sysbus.data;
            `ORR: registers.ACC |= sysbus.data;
            `EOR: registers.ACC ^= sysbus.data;
            `MVN: registers.ACC ~= sysbus.data;
            `LSL: registers.ACC = registers.ACC << sysbus.data;
            `LSR: registers.ACC = registers.ACC >> sysbus.data;

            default: registers.ACC = 0;
        endcase
    end
endmodule : Alu