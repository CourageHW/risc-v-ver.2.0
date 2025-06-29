`timescale 1ns / 1ps

import defines::*;

module decode_stage (
  input logic clk,
  input logic rst_n,
  input logic [DATA_WIDTH-1:0] ID_instruction_i,
  input logic [DATA_WIDTH-1:0] ID_pc_i,

  input logic WB_we_i,                  // 레지스터 쓰기 활성화 신호
  input logic [ADDR_WIDTH-1:0] WB_wr_addr_i, // 쓸 레지스터 주소
  input logic [DATA_WIDTH-1:0] WB_wr_data_i, // 쓸 데이터

  output wb_sel_e ID_WBSel_o,
  output logic ID_PCSrc_o,
  output logic ID_MemRead_o,
  output logic ID_MemWrite_o,
  output logic ID_RegWrite_o,
  output alu_op_e ID_ALUOp_o,
  output logic ID_ALUOpSrc1_o,
  output logic ID_ALUOpSrc2_o,

  output logic [DATA_WIDTH-1:0] ID_branch_target_addr_o,
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
  logic [DATA_WIDTH-1:0] ID_imm_w;

  logic [DATA_WIDTH-1:0] ID_rd_data1_w;
  logic [DATA_WIDTH-1:0] ID_rd_data2_w;

  logic [DATA_WIDTH-1:0] ID_branch_target_addr_w;

  logic [6:0] ID_opcode_w;
  logic [4:0] ID_rd_addr1_w;
  logic [2:0] ID_funct3_w;
  logic [4:0] ID_rd_addr2_w;

  logic ID_BranchTaken_w;
  logic ID_BrEq_w, ID_BrLT_w, ID_BrLTU_w;
  logic ID_Branch_w, ID_Jump_w;

  always_comb begin
    ID_opcode_w = ID_instruction_i[6:0];
    ID_funct3_w = ID_instruction_i[14:12];
    ID_rd_addr1_w = ID_instruction_i[19:15];
    ID_rd_addr2_w = ID_instruction_i[24:20];
  end

  assign ID_PCSrc_o = (ID_BranchTaken_w | ID_Jump_w);

  main_control_unit main_ctrl_inst (
    .opcode_i(ID_opcode_w),
    .WBSel_o(ID_WBSel_o),
    .MemRead_o(ID_MemRead_o),
    .MemWrite_o(ID_MemWrite_o),
    .Jump_o(ID_Jump_w),
    .Branch_o(ID_Branch_w),
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
    .rd_data1_o(ID_rd_data1_w),
    .rd_data2_o(ID_rd_data2_w)
    );

  branch_comparator branch_comp_inst (
    .rd_data1_i(ID_rd_data1_w),
    .rd_data2_i(ID_rd_data2_w),
    .BrEq(ID_BrEq_w),
    .BrLT(ID_BrLT_w),
    .BrLTU(ID_BrLTU_w)
    );

  branch_determination branch_det_inst (
    .BrEq_i(ID_BrEq_w),
    .BrLT_i(ID_BrLT_w),
    .BrLTU_i(ID_BrLTU_w),
    .Branch_i(ID_Branch_w),
    .funct3_i(ID_funct3_w),
    .BranchTaken_o(ID_BranchTaken_w)
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
    .ImmSel_o(ID_imm_w)
    );

    target_address_adder target_addr_add (
      .pc_i(ID_pc_i),
      .immediate_result_i(ID_imm_w),
      .branch_target_addr_o(ID_branch_target_addr_w)
      );

    assign ID_rd_data1_o = ID_rd_data1_w;
    assign ID_rd_data2_o = ID_rd_data2_w;
    assign ID_imm_o      = ID_imm_w;
    assign ID_branch_target_addr_o = ID_branch_target_addr_w;

endmodule
