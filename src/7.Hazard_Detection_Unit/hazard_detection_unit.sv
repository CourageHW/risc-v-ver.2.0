`timescale 1ns / 1ps

import defines::*;

module hazard_detection_unit (
  input logic [4:0] ID_rs1_addr_i,
  input logic [4:0] ID_rs2_addr_i,
  input logic [4:0] EX_rd_addr_i,
  input logic EX_MemRead_i,

  output logic PCWrite_en_o,
  output logic IF_ID_write_en_o,
  output logic ID_EX_flush_o
  );

  always_comb begin
    PCWrite_en_o = 1;
    IF_ID_write_en_o = 1;
    ID_EX_flush_o = 0;

    if (EX_MemRead_i && (EX_rd_addr_i != '0) && ((EX_rd_addr_i == ID_rs1_addr_i) || (EX_rd_addr_i == ID_rs2_addr_i))) begin
      PCWrite_en_o = 0;
      IF_ID_write_en_o = 0;
      ID_EX_flush_o = 1;
    end
  end
endmodule
