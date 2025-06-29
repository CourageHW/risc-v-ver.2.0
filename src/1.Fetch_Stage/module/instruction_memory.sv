`timescale 1ns/1ps

import defines::*;

module instruction_memory (
    input  logic [INST_MEM_ADDR_WIDTH-1:0] rd_addr_i,
    output logic [DATA_WIDTH-1:0] rd_data_o
);

    (* ram_style = "block" *) logic [DATA_WIDTH-1:0] inst_mem [0:INST_MEM_DEPTH-1];

    initial begin
        $readmemh("program.mem", inst_mem);
    end

    always_comb begin
        rd_data_o = inst_mem[rd_addr_i];
    end
endmodule
