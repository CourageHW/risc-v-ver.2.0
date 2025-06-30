`timescale 1ns / 1ps

import defines::*;

module pc_add (
  input logic [DATA_WIDTH-1:0] pc_i,
  output logic [DATA_WIDTH-1:0] pc_o
  );

  assign pc_o = pc_i + 32'd4;

endmodule
