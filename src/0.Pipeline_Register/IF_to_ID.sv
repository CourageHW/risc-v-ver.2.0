`timescale 1ns / 1ps

import defines::*;

module IF_to_ID (
  input logic clk,
  input logic rst_n,

  input logic [DATA_WIDTH-1:0] IF_instruction_i,
  input logic [DATA_WIDTH-1:0] IF_pc_i,
  input logic [DATA_WIDTH-1:0] IF_pc_plus4_i,
  
  output logic [DATA_WIDTH-1:0] ID_instruction_o,
  output logic [DATA_WIDTH-1:0] ID_pc_o,
  output logic [DATA_WIDTH-1:0] ID_pc_plus4_o
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      ID_instruction_o <= '0;
      ID_pc_o <= '0;
      ID_pc_plus4_o <= '0;
    end else begin
      ID_instruction_o <= IF_instruction_i;
      ID_pc_o <= IF_pc_i;
      ID_pc_plus4_o <= IF_pc_plus4_i;
    end
  end

endmodule
