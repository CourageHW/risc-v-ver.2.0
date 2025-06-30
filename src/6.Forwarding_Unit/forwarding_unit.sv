`timescale 1ns / 1ps

import defines::*;

module forwarding_unit (
  input logic [4:0] ID_rs1_addr_i,
  input logic [4:0] ID_rs2_addr_i,

  input logic [4:0] EX_rd_addr_i,
  input logic [4:0] MEM_rd_addr_i,

  input logic EX_RegWrite_i,
  input logic MEM_RegWrite_i,

  output fw_sel_e forwardA,
  output fw_sel_e forwardB
  );

  always_comb begin
    forwardA = FW_NONE;
    forwardB = FW_NONE;
    
    if (EX_RegWrite_i && (EX_rd_addr_i != '0)) begin
      if (EX_rd_addr_i == ID_rs1_addr_i) begin
        forwardA = FW_MEM_ALU;
      end
      if (EX_rd_addr_i == ID_rs2_addr_i) begin
        forwardB = FW_MEM_ALU;
      end
    end

    if (MEM_RegWrite_i && (MEM_rd_addr_i != '0)) begin
      if (MEM_rd_addr_i == ID_rs1_addr_i) begin
        forwardA = FW_WB_DATA;
      end
      if (MEM_rd_addr_i == ID_rs2_addr_i) begin
        forwardB = FW_WB_DATA;
      end
    end
  end
endmodule
