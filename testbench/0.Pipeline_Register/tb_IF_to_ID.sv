`timescale 1ns / 1ps

import defines::*;

module tb_IF_to_ID;

  // Testbench signals
  logic clk;
  logic rst_n;
  logic flush_i;
  logic IF_ID_write_en_i;

  logic [DATA_WIDTH-1:0] IF_instruction_i;
  logic [DATA_WIDTH-1:0] IF_pc_i;
  logic [DATA_WIDTH-1:0] IF_pc_plus4_i;
  
  logic [DATA_WIDTH-1:0] ID_instruction_o;
  logic [DATA_WIDTH-1:0] ID_pc_o;
  logic [DATA_WIDTH-1:0] ID_pc_plus4_o;

  // Instantiate the DUT
  IF_to_ID dut (
    .clk(clk),
    .rst_n(rst_n),
    .flush_i(flush_i),
    .IF_ID_write_en_i(IF_ID_write_en_i),
    .IF_instruction_i(IF_instruction_i),
    .IF_pc_i(IF_pc_i),
    .IF_pc_plus4_i(IF_pc_plus4_i),
    .ID_instruction_o(ID_instruction_o),
    .ID_pc_o(ID_pc_o),
    .ID_pc_plus4_o(ID_pc_plus4_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    $display("Starting IF_to_ID Testbench...");

    // Initialize inputs
    IF_instruction_i  = '0;
    IF_pc_i           = '0;
    IF_pc_plus4_i     = '0;
    flush_i           = 0;
    IF_ID_write_en_i  = 0;

    // Test 1: Reset
    $display("\nTest 1: Reset");
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if (ID_instruction_o === '0 && ID_pc_o === '0 && ID_pc_plus4_o === '0) begin
      $display("  [PASS] Reset successful.");
    end else begin
      $error("  [FAIL] Reset failed.");
    end
    rst_n = 1'b1;
    @(posedge clk);

    // Test 2: Normal operation - write enable high
    $display("\nTest 2: Normal operation (write enable high)");
    IF_ID_write_en_i  = 1;
    IF_instruction_i  = 32'hABCDEF01;
    IF_pc_i           = 32'h00001000;
    IF_pc_plus4_i     = 32'h00001004;
    @(posedge clk);
    if (ID_instruction_o === 32'hABCDEF01 && ID_pc_o === 32'h00001000 && ID_pc_plus4_o === 32'h00001004) begin
      $display("  [PASS] Normal operation successful.");
    end else begin
      $error("  [FAIL] Normal operation failed.");
    end
    @(posedge clk);

    // Test 3: No write operation - write enable low
    $display("\nTest 3: No write operation (write enable low)");
    IF_ID_write_en_i  = 0;
    IF_instruction_i  = 32'hFFFFFFFF; // Change inputs, but outputs should not change
    IF_pc_i           = 32'h00002000;
    IF_pc_plus4_i     = 32'h00002004;
    @(posedge clk);
    if (ID_instruction_o === 32'hABCDEF01 && ID_pc_o === 32'h00001000 && ID_pc_plus4_o === 32'h00001004) begin
      $display("  [PASS] No write operation successful.");
    end else begin
      $error("  [FAIL] No write operation failed.");
    end
    @(posedge clk);

    // Test 4: Flush operation
    $display("\nTest 4: Flush operation");
    flush_i           = 1;
    IF_ID_write_en_i  = 1; // Still try to write, but flush should override
    IF_instruction_i  = 32'h12345678;
    IF_pc_i           = 32'h00003000;
    IF_pc_plus4_i     = 32'h00003004;
    @(posedge clk);
    if (ID_instruction_o === '0 && ID_pc_o === '0 && ID_pc_plus4_o === '0) begin
      $display("  [PASS] Flush successful.");
    end else begin
      $error("  [FAIL] Flush failed.");
    end
    flush_i           = 0;
    @(posedge clk);

    // Test 5: Resume normal operation after flush
    $display("\nTest 5: Resume normal operation after flush");
    IF_ID_write_en_i  = 1;
    IF_instruction_i  = 32'hAABBCCDD;
    IF_pc_i           = 32'h00004000;
    IF_pc_plus4_i     = 32'h00004004;
    @(posedge clk);
    if (ID_instruction_o === 32'hAABBCCDD && ID_pc_o === 32'h00004000 && ID_pc_plus4_o === 32'h00004004) begin
      $display("  [PASS] Resume normal operation successful.");
    end else begin
      $error("  [FAIL] Resume normal operation failed.");
    end
    @(posedge clk);

    $display("\nAll IF_to_ID tests finished.");
    $finish;
  end

endmodule
