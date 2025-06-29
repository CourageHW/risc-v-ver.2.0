`timescale 1ns / 1ps

import defines::*;

module pc_sel (
  input logic [DATA_WIDTH-1:0] pc_plus4_i,
  input logic [DATA_WIDTH-1:0] branch_target_addr_i,
  input logic PCSrc_i,
  output logic [DATA_WIDTH-1:0] pc_sel_o
  );

  assign pc_sel_o = (PCSrc_i) ? branch_target_addr_i : pc_plus4_i;
endmodule
