`timescale 1ns/1ps

import defines::*;

module alu (
  input alu_sel_e ALUSel_i,
  input logic [DATA_WIDTH-1:0] alu_operand1_i,
  input logic [DATA_WIDTH-1:0] alu_operand2_i,

  output logic [DATA_WIDTH-1:0] alu_result_o,
  output logic alu_zeroFlag_o
);

  always_comb begin
    alu_result_o = '0;

    unique case (ALUSel_i)
      ALU_ADD    : alu_result_o = alu_operand1_i + alu_operand2_i;
      ALU_SUB    : alu_result_o = alu_operand1_i - alu_operand2_i; 
      ALU_AND    : alu_result_o = alu_operand1_i & alu_operand2_i;
      ALU_XOR    : alu_result_o = alu_operand1_i ^ alu_operand2_i;
      ALU_OR     : alu_result_o = alu_operand1_i | alu_operand2_i;
      ALU_SLL    : alu_result_o = alu_operand1_i << alu_operand2_i[4:0];
      ALU_SRL    : alu_result_o = alu_operand1_i >> alu_operand2_i[4:0];
      ALU_SRA    : alu_result_o = $signed(alu_operand1_i) >>> $signed(alu_operand2_i);
      ALU_SLT    : alu_result_o = ($signed(alu_operand1_i) < $signed(alu_operand2_i)) ? 32'd1 : 32'd0;
      ALU_SLTU   : alu_result_o = (alu_operand1_i < alu_operand2_i) ? 32'd1 : 32'd0;
      ALU_PASS_B : alu_result_o = alu_operand2_i;
      default : alu_result_o = 'x;
    endcase
  end

  assign alu_zeroFlag_o = (alu_result_o == '0);

endmodule
