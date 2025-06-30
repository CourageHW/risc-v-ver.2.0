`timescale 1ns / 1ps

import defines::*;

module tb_EX_to_MEM;

  // Testbench signals
  logic clk;
  logic rst_n;

  logic EX_alu_zeroFlag_i;
  wb_sel_e EX_WBSel_i;
  logic EX_MemRead_i;
  logic EX_MemWrite_i;
  logic EX_RegWrite_i;
  
  logic [DATA_WIDTH-1:0] EX_alu_result_i;
  logic [DATA_WIDTH-1:0] EX_instruction_i;
  logic [DATA_WIDTH-1:0] EX_wr_data_i;
  logic [DATA_WIDTH-1:0] EX_pc_plus4_i;

  logic MEM_alu_zeroFlag_o;
  wb_sel_e MEM_WBSel_o;
  logic MEM_MemRead_o;
  logic MEM_MemWrite_o;
  logic MEM_RegWrite_o;
  
  logic [DATA_WIDTH-1:0] MEM_alu_result_o;
  logic [DATA_WIDTH-1:0] MEM_instruction_o;
  logic [DATA_WIDTH-1:0] MEM_wr_data_o;
  logic [DATA_WIDTH-1:0] MEM_pc_plus4_o;

  // Instantiate the DUT
  EX_to_MEM dut (
    .clk(clk),
    .rst_n(rst_n),
    .EX_alu_zeroFlag_i(EX_alu_zeroFlag_i),
    .EX_WBSel_i(EX_WBSel_i),
    .EX_MemRead_i(EX_MemRead_i),
    .EX_MemWrite_i(EX_MemWrite_i),
    .EX_RegWrite_i(EX_RegWrite_i),
    .EX_alu_result_i(EX_alu_result_i),
    .EX_instruction_i(EX_instruction_i),
    .EX_wr_data_i(EX_wr_data_i),
    .EX_pc_plus4_i(EX_pc_plus4_i),
    .MEM_alu_zeroFlag_o(MEM_alu_zeroFlag_o),
    .MEM_WBSel_o(MEM_WBSel_o),
    .MEM_MemRead_o(MEM_MemRead_o),
    .MEM_MemWrite_o(MEM_MemWrite_o),
    .MEM_RegWrite_o(MEM_RegWrite_o),
    .MEM_alu_result_o(MEM_alu_result_o),
    .MEM_instruction_o(MEM_instruction_o),
    .MEM_wr_data_o(MEM_wr_data_o),
    .MEM_pc_plus4_o(MEM_pc_plus4_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    $display("Starting EX_to_MEM Testbench...");

    // Initialize inputs
    EX_alu_zeroFlag_i = 0;
    EX_WBSel_i        = WB_NONE;
    EX_MemRead_i      = 0;
    EX_MemWrite_i     = 0;
    EX_RegWrite_i     = 0;
    EX_alu_result_i   = '0;
    EX_instruction_i  = '0;
    EX_wr_data_i      = '0;
    EX_pc_plus4_i     = '0;

    // Test 1: Reset
    $display("\nTest 1: Reset");
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if (MEM_alu_zeroFlag_o === 0 && MEM_WBSel_o === WB_NONE && MEM_MemRead_o === 0 &&
        MEM_MemWrite_o === 0 && MEM_RegWrite_o === 0 && MEM_alu_result_o === '0 &&
        MEM_instruction_o === '0 && MEM_wr_data_o === '0 && MEM_pc_plus4_o === '0) begin
      $display("  [PASS] Reset successful.");
    end else begin
      $error("  [FAIL] Reset failed.");
    end
    rst_n = 1'b1;
    @(posedge clk);

    // Test 2: Normal operation - all signals high/non-zero
    $display("\nTest 2: Normal operation - all signals high/non-zero");
    EX_alu_zeroFlag_i = 1;
    EX_WBSel_i        = WB_ALU;
    EX_MemRead_i      = 1;
    EX_MemWrite_i     = 1;
    EX_RegWrite_i     = 1;
    EX_alu_result_i   = 32'h12345678;
    EX_instruction_i  = 32'hABCDEF01;
    EX_wr_data_i      = 32'hFEDCBA98;
    EX_pc_plus4_i     = 32'h00001004;
    @(posedge clk);
    if (MEM_alu_zeroFlag_o === 1 && MEM_WBSel_o === WB_ALU && MEM_MemRead_o === 1 &&
        MEM_MemWrite_o === 1 && MEM_RegWrite_o === 1 && MEM_alu_result_o === 32'h12345678 &&
        MEM_instruction_o === 32'hABCDEF01 && MEM_wr_data_o === 32'hFEDCBA98 && MEM_pc_plus4_o === 32'h00001004) begin
      $display("  [PASS] Normal operation successful.");
    end else begin
      $error("  [FAIL] Normal operation failed.\nExpected: %h, %s, %b, %b, %b, %h, %h, %h, %h\nGot:      %h, %s, %b, %b, %b, %h, %h, %h, %h",
             32'h12345678, WB_ALU.name(), 1, 1, 1, 32'h12345678, 32'hABCDEF01, 32'hFEDCBA98, 32'h00001004,
             MEM_alu_result_o, MEM_WBSel_o.name(), MEM_MemRead_o, MEM_MemWrite_o, MEM_RegWrite_o, MEM_alu_result_o, MEM_instruction_o, MEM_wr_data_o, MEM_pc_plus4_o);
    end
    @(posedge clk);

    // Test 3: Different values
    $display("\nTest 3: Different values");
    EX_alu_zeroFlag_i = 0;
    EX_WBSel_i        = WB_MEM;
    EX_MemRead_i      = 0;
    EX_MemWrite_i     = 0;
    EX_RegWrite_i     = 0;
    EX_alu_result_i   = 32'h87654321;
    EX_instruction_i  = 32'h10FEDCBA;
    EX_wr_data_i      = 32'h98765432;
    EX_pc_plus4_i     = 32'h00002008;
    @(posedge clk);
    if (MEM_alu_zeroFlag_o === 0 && MEM_WBSel_o === WB_MEM && MEM_MemRead_o === 0 &&
        MEM_MemWrite_o === 0 && MEM_RegWrite_o === 0 && MEM_alu_result_o === 32'h87654321 &&
        MEM_instruction_o === 32'h10FEDCBA && MEM_wr_data_o === 32'h98765432 && MEM_pc_plus4_o === 32'h00002008) begin
      $display("  [PASS] Different values test successful.");
    end else begin
      $error("  [FAIL] Different values test failed.");
    end
    @(posedge clk);

    $display("\nAll EX_to_MEM tests finished.");
    $finish;
  end

endmodule
