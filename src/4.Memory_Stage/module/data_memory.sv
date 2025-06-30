`timescale 1ns / 1ps

import defines::*;

module data_memory (
  input logic clk,
  input logic MEM_MemWrite_en,
  input logic MEM_MemRead_en,
  input logic WB_MemWrite_en,
  input logic [2:0] MEM_funct3_i,
  input logic [DATA_WIDTH-1:0] MEM_addr_i,
  input logic [DATA_WIDTH-1:0] WB_addr_i,
  input logic [DATA_WIDTH-1:0] MEM_wr_data_i,
  input logic [DATA_WIDTH-1:0] WB_wr_data_i,

  output logic [DATA_WIDTH-1:0] rd_data_o
);

  // Use "reg" for memory inside a procedural block, which is more conventional.
  (* ram_style = "block" *) logic [DATA_WIDTH-1:0] memory [0:DATA_MEM_DEPTH-1];

  logic [DATA_MEM_ADDR_WIDTH-1:0] MEM_word_addr_w, WB_word_addr_w;

  assign MEM_word_addr_w = MEM_addr_i[DATA_MEM_ADDR_WIDTH+1:2];
  assign WB_word_addr_w = WB_addr_i[DATA_MEM_ADDR_WIDTH+1:2];

  always_ff @(posedge clk) begin
    // --- Read Logic ---
    if (MEM_MemRead_en) begin
      if (WB_MemWrite_en && (WB_word_addr_w == MEM_word_addr_w)) begin
        rd_data_o <= WB_wr_data_i;
      end else begin
        rd_data_o <= memory[MEM_word_addr_w];
      end
    end

    // --- Write Logic ---
    if (MEM_MemWrite_en) begin
      unique case (MEM_funct3_i)
        FUNCT3_SW: begin
          memory[MEM_word_addr_w] <= MEM_wr_data_i;
        end

        FUNCT3_SH: begin
          if (MEM_addr_i[1] == 1'b0) begin 
            memory[MEM_word_addr_w][15:0] <= MEM_wr_data_i[15:0];
          end else begin
            memory[MEM_word_addr_w][31:16] <= MEM_wr_data_i[15:0];
          end
        end

        // Store Byte (SB)
        FUNCT3_SB: begin
          unique case (MEM_addr_i[1:0])
            2'b00: memory[MEM_word_addr_w][7:0]   <= MEM_wr_data_i[7:0];
            2'b01: memory[MEM_word_addr_w][15:8]  <= MEM_wr_data_i[7:0];
            2'b10: memory[MEM_word_addr_w][23:16] <= MEM_wr_data_i[7:0];
            2'b11: memory[MEM_word_addr_w][31:24] <= MEM_wr_data_i[7:0];
          endcase
        end
        
        default: ;
      endcase
    end
  end

endmodule
