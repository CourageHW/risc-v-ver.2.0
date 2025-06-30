`timescale 1ns / 1ps

import defines::*;

module memory_stage (
  input logic clk,
  input logic MEM_MemWrite_i,
  input logic MEM_MemRead_i,
  input logic WB_MemWrite_i,
  input logic [DATA_WIDTH-1:0] MEM_instruction_i,
  input logic [DATA_WIDTH-1:0] MEM_addr_i,
  input logic [DATA_WIDTH-1:0] MEM_wr_data_i,
  input logic [DATA_WIDTH-1:0] WB_addr_i,
  input logic [DATA_WIDTH-1:0] WB_wr_data_i,

  output logic [DATA_WIDTH-1:0] MEM_rd_data_o
  );

  logic [2:0] MEM_funct3_w;

  assign MEM_funct3_w = MEM_instruction_i[14:12];

  data_memory data_mem_inst (
    .clk(clk),
    .MEM_MemWrite_en(MEM_MemWrite_i),
    .MEM_MemRead_en(MEM_MemRead_i),
    .WB_MemWrite_en(WB_MemWrite_i),
    .MEM_funct3_i(MEM_funct3_w),
    .MEM_addr_i(MEM_addr_i),
    .WB_addr_i(WB_addr_i),
    .MEM_wr_data_i(MEM_wr_data_i),
    .WB_wr_data_i(WB_wr_data_i),
    .rd_data_o(MEM_rd_data_o)
    );

endmodule
