`timescale 1ns / 1ps

import defines::*;

module fetch_stage (
  input logic clk,
  input logic rst_n,
  input logic [DATA_WIDTH-1:0] IF_branch_target_addr_i,

  input logic IF_PCSrc_i,
  
  output logic [DATA_WIDTH-1:0] IF_instruction_o,
  output logic [DATA_WIDTH-1:0] IF_pc_o,
  output logic [DATA_WIDTH-1:0] IF_pc_plus4_o
  );

  logic [DATA_WIDTH-1:0] IF_pc_w;
  logic [DATA_WIDTH-1:0] IF_pc_sel_w;
  logic [DATA_WIDTH-1:0] IF_pc_plus4_w;

  logic [DATA_WIDTH-1:0] IF_instruction_w;
  logic [INST_MEM_ADDR_WIDTH-1:0] IF_rd_addr_w;

  assign IF_rd_addr_w = IF_pc_w[INST_MEM_ADDR_WIDTH+1:2];

  pc_sel pc_sel_inst (
    .pc_plus4_i(IF_pc_plus4_w),
    .branch_target_addr_i(IF_branch_target_addr_i),
    .PCSrc_i(IF_PCSrc_i),
    .pc_sel_o(IF_pc_sel_w)
    );

  program_counter program_counter_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_en_i(),
    .pc_i(IF_pc_sel_w),
    .pc_o(IF_pc_w)
    );

  pc_add pc_add_inst (
    .pc_i(IF_pc_w),
    .pc_o(IF_pc_plus4_w)
  );

  instruction_memory instruction_memory_inst (
    .rd_addr_i(IF_rd_addr_w),
    .rd_data_o(IF_instruction_w)
  );

  assign IF_pc_plus4_o = IF_pc_plus4_w;
  assign IF_pc_o = IF_pc_w;
endmodule
