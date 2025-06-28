`timescale 1ns / 1ps 

import defines::*;

module register_file (
  input logic clk,
  input logic rst_n,
  input logic we_i,
  input logic [ADDR_WIDTH-1:0] wr_addr_i,
  input logic [DATA_WIDTH-1:0] wr_data_i,
  input logic [ADDR_WIDTH-1:0] rd_addr1_i,
  input logic [ADDR_WIDTH-1:0] rd_addr2_i,

  output logic [DATA_WIDTH-1:0] rd_data1_o,
  output logic [DATA_WIDTH-1:0] rd_data2_o
  );

  logic [DATA_WIDTH-1:0] registers [0:REG_COUNT-1];

  // write
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      for (int i = 0; i < REG_COUNT; i++) begin
        registers[i] <= '0;
      end
    end else if (we_i && wr_addr_i != '0) begin
      registers[wr_addr_i] <= wr_data_i;
    end
  end

  // read
  // 아직 forwarding 구현 x
  always_comb begin
    rd_data1_o = registers[rd_addr1_i];
    rd_data2_o = registers[rd_addr2_i];
  end

endmodule
