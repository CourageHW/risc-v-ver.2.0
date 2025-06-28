`timescale 1ns / 1ps

import defines::*;

module execute_stage (
  input logic [DATA_WIDTH-1:0] EX_alu_operand1_i,
  input logic [DATA_WIDTH-1:0] EX_alu_operand2_i,
  input logic [2:0] EX_alu_ctrl_funct3_i,
  input logic EX_alu_ctrl_funct7_i,
  input alu_op_e EX_ALUOp_i,

  output logic [DATA_WIDTH-1:0] EX_alu_result_o,
  output logic EX_alu_zeroFlag_o
  );

  alu_sel_e EX_ALUSel_w;

  alu_control_unit alu_ctrl_inst (
    .alu_ctrl_funct3_i(EX_alu_ctrl_funct3_i),
    .alu_ctrl_funct7_i(EX_alu_ctrl_funct7_i),
    .ALUOp_i(EX_ALUOp_i),
    .ALUSel_o(EX_ALUSel_w)
  );

  alu alu_inst (
    .alu_operand1_i(EX_alu_operand1_i),
    .alu_operand2_i(EX_alu_operand2_i),
    .ALUSel_i(EX_ALUSel_w),
    .alu_result_o(EX_alu_result_o),
    .alu_zeroFlag_o(EX_alu_zeroFlag_o)
  );
endmodule
