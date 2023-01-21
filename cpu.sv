module Cpu #(parameter WORD_W = 16, BUS_W = 8, OP_W = 4)
    (input logic clock, nrst);

    // Busses and clocks
    logic clock, n_reset;
    CtlBus cbus (clock, n_reset);
    SysBus sbus (clock, n_reset);

    // CPU Components
    Sequencer s1 (.ctlbus(cbus.seq), .sysbus(sbus.seq));
    Rom r1 (.ctlbus(cbus.tmb), .sysbus(sbus.rom));

endmodule : Cpu