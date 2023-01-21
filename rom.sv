module Rom (CtlBus ctlbus, SysBus sysbus)

    `include "opcodes.h"
    `include "control_sig.h"

    function logic [8:0] instr(
        logic [3:0] opcode,
        logic [1:0] addr,
        logic [3:0] op0, op1,
        ref SysBus bus);

        assign bus.data[13:10] = opcode;
        assign bus.data[9:8] = addr;
        assign bus.data[7:4] = op0;
        assign bus.data[3:0] = op1;

    endfunction : instr

    task write_out(logic [3:0] addr);
        unique case(addr)
            0: instr(`MOV, `REG, 4'b0000, 4'b1010);
            default : assign sysbus = 0;
        endcase
    endtask : write_out

    always_comb begin
        if (ctlbus.dev == 2'b11)
            write_out(ctlbus.opaddr);
        else
            assign sysbus.data = 'z;
    end

endmodule : Rom