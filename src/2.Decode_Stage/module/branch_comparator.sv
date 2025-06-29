`timescale 1ns / 1ps

import defines::*;

module branch_comparator (
  input logic [DATA_WIDTH-1:0] rd_data1_i,
  input logic [DATA_WIDTH-1:0] rd_data2_i,
  output logic BrEq,
  output logic BrLT,
  output logic BrLTU
  );


  always_comb begin
    BrEq = (rd_data1_i == rd_data2_i);
    BrLT = ($signed(rd_data1_i) < $signed(rd_data2_i));
    BrLTU = (rd_data1_i < rd_data2_i);
  end


endmodule
