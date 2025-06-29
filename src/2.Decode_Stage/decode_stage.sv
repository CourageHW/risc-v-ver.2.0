`timescale 1ns / 1ps

import defines::*;

module decode_stage (
  input logic clk,
  input logic rst_n,
  input logic [DATA_WIDTH-1:0] ID_instruction_i,

  input logic WB_we_i,                  // 레지스터 쓰기 활성화 신호
  input logic [ADDR_WIDTH-1:0] WB_wr_addr_i, // 쓸 레지스터 주소
  input logic [DATA_WIDTH-1:0] WB_wr_data_i, // 쓸 데이터

  output wb_sel_e ID_WBSel_o,
  output logic ID_MemRead_o,
  output logic ID_MemWrite_o,
  output logic ID_Jump_o,
  output logic ID_Branch_o,
  output logic ID_RegWrite_o,
  output alu_op_e ID_ALUOp_o,
  output logic ID_ALUOpSrc1_o,
  output logic ID_ALUOpSrc2_o,

  output logic [DATA_WIDTH-1:0] ID_instruction_o,
  output logic [DATA_WIDTH-1:0] ID_rd_data1_o,
  output logic [DATA_WIDTH-1:0] ID_rd_data2_o,
  output logic [DATA_WIDTH-1:0] ID_imm_o
  );

  imm_sel_e ID_ImmSel_w;

  logic [DATA_WIDTH-1:0] ID_imm_i_w; 
  logic [DATA_WIDTH-1:0] ID_imm_s_w;
  logic [DATA_WIDTH-1:0] ID_imm_b_w;
  logic [DATA_WIDTH-1:0] ID_imm_u_w;
  logic [DATA_WIDTH-1:0] ID_imm_j_w;

  logic [6:0] ID_opcode_w;
  logic [4:0] ID_rd_addr1_w;
  logic [4:0] ID_rd_addr2_w;

  always_comb begin
    ID_opcode_w = ID_instruction_i[6:0];
    ID_rd_addr1_w = ID_instruction_i[19:15];
    ID_rd_addr2_w = ID_instruction_i[24:20];
    ID_instruction_o = ID_instruction_i;
  end

  main_control_unit main_ctrl_inst (
    .opcode_i(ID_opcode_w),
    .WBSel_o(ID_WBSel_o),
    .MemRead_o(ID_MemRead_o),
    .MemWrite_o(ID_MemWrite_o),
    .Jump_o(ID_Jump_o),
    .Branch_o(ID_Branch_o),
    .RegWrite_o(ID_RegWrite_o),
    .ALUOp_o(ID_ALUOp_o),
    .ALUSrc1_o(ID_ALUOpSrc1_o),
    .ALUSrc2_o(ID_ALUOpSrc2_o),
    .ImmSel_o(ID_ImmSel_w)
    );

  register_file register_file_inst (
    .clk(clk),
    .rst_n(rst_n),
    .we_i(WB_we_i), // write back
    .wr_addr_i(WB_wr_addr_i), // write back
    .wr_data_i(WB_wr_data_i), // write back
    .rd_addr1_i(ID_rd_addr1_w),
    .rd_addr2_i(ID_rd_addr2_w),
    .rd_data1_o(ID_rd_data1_o),
    .rd_data2_o(ID_rd_data2_o)
    );

  immediate_generator imm_gen_inst (
    .instruction_i(ID_instruction_i),
    .imm_i_o(ID_imm_i_w),
    .imm_s_o(ID_imm_s_w),
    .imm_b_o(ID_imm_b_w),
    .imm_u_o(ID_imm_u_w),
    .imm_j_o(ID_imm_j_w)
    );

  immediate_sel imm_sel_inst (
    .ImmSel_i(ID_ImmSel_w),
    .imm_i_i(ID_imm_i_w),
    .imm_s_i(ID_imm_s_w),
    .imm_b_i(ID_imm_b_w),
    .imm_u_i(ID_imm_u_w),
    .imm_j_i(ID_imm_j_w),
    .ImmSel_o(ID_imm_o)
    );

endmodule
