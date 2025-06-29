`timescale 1ns / 1ps

import defines::*;

module target_address_adder (
  input logic [DATA_WIDTH-1:0] pc_i,
  input logic [DATA_WIDTH-1:0] immediate_result_i,
  output logic [DATA_WIDTH-1:0] branch_target_addr_o
  );

  assign branch_target_addr_o = pc_i + immediate_result_i;
endmodule
