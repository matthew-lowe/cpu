module Registers #(parameter WORD_S = 16)
    (CtlBus ctlbus, SysBus sysbus);

    task clear;
        for(int i = 0; i < 10; i++)
            R[i] = 0;
        FLG = 0; ACC = 0; PC = 0; IR = 0; MAR = 0; MDR = 0;
    endtask : clear

    logic [WORD_S-1:0] FLG, ACC, PC, IR, MAR, MDR;
    logic [WORD_S-1:0] R [int];

    // Empty the GPRs
    initial clear();

endmodule : Registers