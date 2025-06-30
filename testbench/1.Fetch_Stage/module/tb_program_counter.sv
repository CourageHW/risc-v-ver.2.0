`timescale 1ns / 1ps

import defines::*;

module tb_program_counter;

  // Testbench signals
  logic clk;
  logic rst_n;
  logic pc_en_i;
  logic [DATA_WIDTH-1:0] pc_i;
  logic [DATA_WIDTH-1:0] pc_o;

  // Instantiate the DUT
  program_counter dut (
    .clk(clk),
    .rst_n(rst_n),
    .pc_en_i(pc_en_i),
    .pc_i(pc_i),
    .pc_o(pc_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period, 100MHz clock
  end

  // Test sequence
  initial begin
    $display("Starting program_counter Testbench...");

    // Initialize inputs
    pc_i    = '0;
    pc_en_i = 0;

    // Test 1: Reset
    $display("\nTest 1: Reset");
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    if (pc_o === '0) begin
      $display("  [PASS] Reset successful. pc_o = %h", pc_o);
    end else begin
      $error("  [FAIL] Reset failed. Expected: %h, Got: %h", '0, pc_o);
    end
    rst_n = 1'b1;
    @(posedge clk);

    // Test 2: PC Enable - Load initial value
    $display("\nTest 2: PC Enable - Load initial value");
    pc_i    = 32'h0000_0100;
    pc_en_i = 1;
    @(posedge clk);
    if (pc_o === 32'h0000_0100) begin
      $display("  [PASS] Initial load successful. pc_o = %h", pc_o);
    end else begin
      $error("  [FAIL] Initial load failed. Expected: %h, Got: %h", 32'h0000_0100, pc_o);
    end
    @(posedge clk);

    // Test 3: PC Hold - pc_en_i = 0
    $display("\nTest 3: PC Hold - pc_en_i = 0");
    pc_i    = 32'hFFFF_FFFF; // Change input, but output should hold
    pc_en_i = 0;
    @(posedge clk);
    if (pc_o === 32'h0000_0100) begin
      $display("  [PASS] PC hold successful. pc_o = %h", pc_o);
    end else begin
      $error("  [FAIL] PC hold failed. Expected: %h, Got: %h", 32'h0000_0100, pc_o);
    end
    @(posedge clk);

    // Test 4: PC Enable - Load new value
    $display("\nTest 4: PC Enable - Load new value");
    pc_i    = 32'h0000_0200;
    pc_en_i = 1;
    @(posedge clk);
    if (pc_o === 32'h0000_0200) begin
      $display("  [PASS] New value load successful. pc_o = %h", pc_o);
    end else begin
      $error("  [FAIL] New value load failed. Expected: %h, Got: %h", 32'h0000_0200, pc_o);
    end
    @(posedge clk);

    // Test 5: PC Enable - Load zero
    $display("\nTest 5: PC Enable - Load zero");
    pc_i    = '0;
    pc_en_i = 1;
    @(posedge clk);
    if (pc_o === '0) begin
      $display("  [PASS] Load zero successful. pc_o = %h", pc_o);
    end else begin
      $error("  [FAIL] Load zero failed. Expected: %h, Got: %h", '0, pc_o);
    end
    @(posedge clk);

    $display("\nAll program_counter tests finished.");
    $finish;
  end

endmodule
