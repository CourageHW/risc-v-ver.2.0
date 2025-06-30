`timescale 1ns / 1ps

import defines*;

module tb_MEM_to_WB;

  // Testbench signals
  logic clk;
  logic rst_n;
  
  wb_sel_e MEM_WBSel_i;
  logic MEM_RegWrite_i;
  logic MEM_MemWrite_i;
  
  logic [DATA_WIDTH-1:0] MEM_alu_result_i;
  logic [DATA_WIDTH-1:0] MEM_instruction_i;
  logic [DATA_WIDTH-1:0] MEM_rd_data_i;
  logic [DATA_WIDTH-1:0] MEM_pc_plus4_i;
  logic [DATA_WIDTH-1:0] MEM_addr_i;
  logic [DATA_WIDTH-1:0] MEM_wr_data_i;
  
  wb_sel_e WB_WBSel_o;
  logic WB_RegWrite_o;
  logic WB_MemWrite_o;
  
  logic [DATA_WIDTH-1:0] WB_alu_result_o;
  logic [DATA_WIDTH-1:0] WB_instruction_o;
  logic [DATA_WIDTH-1:0] WB_rd_data_o;
  logic [DATA_WIDTH-1:0] WB_pc_plus4_o;
  logic [DATA_WIDTH-1:0] WB_addr_o;
  logic [DATA_WIDTH-1:0] WB_wr_data_o;

  // Instantiate the DUT
  MEM_to_WB dut (
    .clk(clk),
    .rst_n(rst_n),
    .MEM_WBSel_i(MEM_WBSel_i),
    .MEM_RegWrite_i(MEM_RegWrite_i),
    .MEM_MemWrite_i(MEM_MemWrite_i),
    .MEM_alu_result_i(MEM_alu_result_i),
    .MEM_instruction_i(MEM_instruction_i),
    .MEM_rd_data_i(MEM_rd_data_i),
    .MEM_pc_plus4_i(MEM_pc_plus4_i),
    .MEM_addr_i(MEM_addr_i),
    .MEM_wr_data_i(MEM_wr_data_i),
    .WB_WBSel_o(WB_WBSel_o),
    .WB_RegWrite_o(WB_RegWrite_o),
    .WB_MemWrite_o(WB_MemWrite_o),
    .WB_alu_result_o(WB_alu_result_o),
    .WB_instruction_o(WB_instruction_o),
    .WB_rd_data_o(WB_rd_data_o),
    .WB_pc_plus4_o(WB_pc_plus4_o),
    .WB_addr_o(WB_addr_o),
    .WB_wr_data_o(WB_wr_data_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    $display("Starting MEM_to_WB Testbench...");

    // Initialize inputs
    MEM_WBSel_i       = WB_NONE;
    MEM_RegWrite_i    = 0;
    MEM_MemWrite_i    = 0;
    MEM_alu_result_i  = '0;
    MEM_instruction_i = '0;
    MEM_rd_data_i     = '0;
    MEM_pc_plus4_i    = '0;
    MEM_addr_i        = '0;
    MEM_wr_data_i     = '0;

    // Test 1: Reset
    $display("\nTest 1: Reset");
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if (WB_WBSel_o === WB_NONE && WB_RegWrite_o === 0 && WB_MemWrite_o === 0 &&
        WB_alu_result_o === '0 && WB_instruction_o === '0 && WB_rd_data_o === '0 &&
        WB_pc_plus4_o === '0 && WB_addr_o === '0 && WB_wr_data_o === '0') begin
      $display("  [PASS] Reset successful.");
    end else begin
      $error("  [FAIL] Reset failed.");
    end
    rst_n = 1'b1;
    @(posedge clk);

    // Test 2: Normal operation - all signals high/non-zero
    $display("\nTest 2: Normal operation");
    MEM_WBSel_i       = WB_ALU;
    MEM_RegWrite_i    = 1;
    MEM_MemWrite_i    = 1;
    MEM_alu_result_i  = 32'h12345678;
    MEM_instruction_i = 32'hABCDEF01;
    MEM_rd_data_i     = 32'hFEDCBA98;
    MEM_pc_plus4_i    = 32'h00001004;
    MEM_addr_i        = 32'h00002000;
    MEM_wr_data_i     = 32'hAABBCCDD;
    @(posedge clk);
    if (WB_WBSel_o === WB_ALU && WB_RegWrite_o === 1 && WB_MemWrite_o === 1 &&
        WB_alu_result_o === 32'h12345678 && WB_instruction_o === 32'hABCDEF01 && WB_rd_data_o === 32'hFEDCBA98 &&
        WB_pc_plus4_o === 32'h00001004 && WB_addr_o === 32'h00002000 && WB_wr_data_o === 32'hAABBCCDD) begin
      $display("  [PASS] Normal operation successful.");
    end else begin
      $error("  [FAIL] Normal operation failed.");
    end
    @(posedge clk);

    // Test 3: Different values and WB_MEM
    $display("\nTest 3: Different values and WB_MEM");
    MEM_WBSel_i       = WB_MEM;
    MEM_RegWrite_i    = 0;
    MEM_MemWrite_i    = 0;
    MEM_alu_result_i  = 32'h87654321;
    MEM_instruction_i = 32'h10FEDCBA;
    MEM_rd_data_i     = 32'h98765432;
    MEM_pc_plus4_i    = 32'h00002008;
    MEM_addr_i        = 32'h00003000;
    MEM_wr_data_i     = 32'hEEFF0011;
    @(posedge clk);
    if (WB_WBSel_o === WB_MEM && WB_RegWrite_o === 0 && WB_MemWrite_o === 0 &&
        WB_alu_result_o === 32'h87654321 && WB_instruction_o === 32'h10FEDCBA && WB_rd_data_o === 32'h98765432 &&
        WB_pc_plus4_o === 32'h00002008 && WB_addr_o === 32'h00003000 && WB_wr_data_o === 32'hEEFF0011) begin
      $display("  [PASS] Different values and WB_MEM test successful.");
    end else begin
      $error("  [FAIL] Different values and WB_MEM test failed.");
    end
    @(posedge clk);

    // Test 4: WB_PC4
    $display("\nTest 4: WB_PC4");
    MEM_WBSel_i       = WB_PC4;
    MEM_RegWrite_i    = 1;
    MEM_MemWrite_i    = 0;
    MEM_alu_result_i  = 32'h00000000;
    MEM_instruction_i = 32'h00000000;
    MEM_rd_data_i     = 32'h00000000;
    MEM_pc_plus4_i    = 32'h00004004;
    MEM_addr_i        = 32'h00000000;
    MEM_wr_data_i     = 32'h00000000;
    @(posedge clk);
    if (WB_WBSel_o === WB_PC4 && WB_RegWrite_o === 1 && WB_MemWrite_o === 0 &&
        WB_alu_result_o === 32'h00000000 && WB_instruction_o === 32'h00000000 && WB_rd_data_o === 32'h00000000 &&
        WB_pc_plus4_o === 32'h00004004 && WB_addr_o === 32'h00000000 && WB_wr_data_o === 32'h00000000) begin
      $display("  [PASS] WB_PC4 test successful.");
    end else begin
      $error("  [FAIL] WB_PC4 test failed.");
    end
    @(posedge clk);

    $display("\nAll MEM_to_WB tests finished.");
    $finish;
  end

endmodule
