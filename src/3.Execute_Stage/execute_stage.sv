`timescale 1ns / 1ps

import defines::*;

module execute_stage (
  input logic [DATA_WIDTH-1:0] EX_rd_data1_i,
  input logic [DATA_WIDTH-1:0] EX_rd_data2_i,
  input logic [DATA_WIDTH-1:0] MEM_alu_result_i,
  input logic [DATA_WIDTH-1:0] WB_alu_result_i,
  input logic [DATA_WIDTH-1:0] EX_imm_i,
  input logic [DATA_WIDTH-1:0] EX_pc_i,
  input logic [DATA_WIDTH-1:0] EX_instruction_i,

  input logic EX_ALUOpSrc1_i,
  input logic EX_ALUOpSrc2_i,
  input alu_op_e EX_ALUOp_i,
  input fw_sel_e EX_forwardA_i,
  input fw_sel_e EX_forwardB_i,

  output logic [DATA_WIDTH-1:0] EX_alu_result_o,
  output logic [DATA_WIDTH-1:0] EX_wr_data_o
  );

  alu_sel_e EX_ALUSel_w;

  logic [DATA_WIDTH-1:0] forwardA_result, forwardB_result;
  logic [DATA_WIDTH-1:0] EX_alu_operand1_w, EX_alu_operand2_w;
  
  logic [2:0] EX_alu_ctrl_funct3_w;
  logic       EX_alu_ctrl_funct7_w;

  MUX_3to1 forwardA_inst (
    .rd_data_i(EX_rd_data1_i),
    .MEM_ALU_i(MEM_alu_result_i),
    .WB_DATA_i(WB_alu_result_i),
    .sel(EX_forwardA_i),
    .out(forwardA_result)
  );

  MUX_3to1 forwardB_inst (
    .rd_data_i(EX_rd_data2_i),
    .MEM_ALU_i(MEM_alu_result_i),
    .WB_DATA_i(WB_alu_result_i),
    .sel(EX_forwardB_i),
    .out(forwardB_result)
  );

  // MUX 2to1
  assign EX_alu_operand1_w = (EX_ALUOpSrc1_i) ? EX_pc_i : forwardA_result;
  assign EX_alu_operand2_w = (EX_ALUOpSrc2_i) ? EX_imm_i : forwardB_result;

  assign EX_alu_ctrl_funct3_w = EX_instruction_i[14:12];
  assign EX_alu_ctrl_funct7_w = EX_instruction_i[30];

  alu_control_unit alu_ctrl_inst (
    .alu_ctrl_funct3_i(EX_alu_ctrl_funct3_w),
    .alu_ctrl_funct7_i(EX_alu_ctrl_funct7_w),
    .ALUOp_i(EX_ALUOp_i),
    .ALUSel_o(EX_ALUSel_w)
  );

  alu alu_inst (
    .alu_operand1_i(EX_alu_operand1_w),
    .alu_operand2_i(EX_alu_operand2_w),
    .ALUSel_i(EX_ALUSel_w),
    .alu_result_o(EX_alu_result_o)
  );

  assign EX_wr_data_o = EX_alu_operand2_w;
endmodule
