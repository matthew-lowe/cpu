module Ram #(parameter WORD_S = 16)
    (CtlBus ctlbus, SysBus sysbus);

    bit [WORD_S-1:0][WORD_S-1:0] mem;

    always_comb begin
        if (ctlbus.dev == `RAM)
            if (ctlbus.ldtr == `LDR) sysbus.data = mem[ctlbus.opaddr];
            else mem[ctlbus.opaddr] = sysbus.data;
    end
endmodule : Ram
