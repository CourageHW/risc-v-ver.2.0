`timescale 1ns / 1ps

import defines::*;

module data_memory (
  input logic clk,
  input logic MemWrite_en,
  input logic MemRead_en,
  input logic [2:0] MEM_funct3_i,
  input logic [DATA_WIDTH-1:0] rd_addr_i,
  input logic [DATA_WIDTH-1:0] wr_data_i,

  output logic [DATA_WIDTH-1:0] rd_data_o
);

  // Use "reg" for memory inside a procedural block, which is more conventional.
  (* ram_style = "block" *) reg [DATA_WIDTH-1:0] memory [0:DATA_MEM_DEPTH-1];

  logic [DATA_MEM_ADDR_WIDTH-1:0] word_addr_w;

  assign word_addr_w = rd_addr_i[DATA_MEM_ADDR_WIDTH+1:2];

  always_ff @(posedge clk) begin
    // --- Read Logic ---
    if (MemRead_en) begin
      rd_data_o <= memory[word_addr_w];
    end

    // --- Write Logic ---
    if (MemWrite_en) begin
      unique case (MEM_funct3_i)
        FUNCT3_SW: begin
          memory[word_addr_w] <= wr_data_i;
        end

        FUNCT3_SH: begin
          if (rd_addr_i[1] == 1'b0) begin 
            memory[word_addr_w][15:0] <= wr_data_i[15:0];
          end else begin 
            memory[word_addr_w][31:16] <= wr_data_i[15:0]; 
          end
        end

        // Store Byte (SB)
        FUNCT3_SB: begin
          unique case (rd_addr_i[1:0])
            2'b00: memory[word_addr_w][7:0]   <= wr_data_i[7:0];
            2'b01: memory[word_addr_w][15:8]  <= wr_data_i[7:0];
            2'b10: memory[word_addr_w][23:16] <= wr_data_i[7:0];
            2'b11: memory[word_addr_w][31:24] <= wr_data_i[7:0];
          endcase
        end
        
        default: ;
      endcase
    end
  end

endmodule
