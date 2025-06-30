`timescale 1ns / 1ps

import defines::*;

module tb_branch_comparator;

  // Testbench signals
  logic [DATA_WIDTH-1:0] rd_data1_i;
  logic [DATA_WIDTH-1:0] rd_data2_i;
  logic BrEq;
  logic BrLT;
  logic BrLTU;

  // Instantiate the DUT
  branch_comparator dut (
    .rd_data1_i(rd_data1_i),
    .rd_data2_i(rd_data2_i),
    .BrEq(BrEq),
    .BrLT(BrLT),
    .BrLTU(BrLTU)
  );

  // Test task
  task automatic test_case(
    input logic [DATA_WIDTH-1:0] data1,
    input logic [DATA_WIDTH-1:0] data2,
    input logic expected_BrEq,
    input logic expected_BrLT,
    input logic expected_BrLTU,
    input string test_name
  );
    begin
      rd_data1_i = data1;
      rd_data2_i = data2;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  rd_data1_i = %0d (0x%h), rd_data2_i = %0d (0x%h)", rd_data1_i, rd_data1_i, rd_data2_i, rd_data2_i);
      $display("  BrEq: Expected %b, Got %b", expected_BrEq, BrEq);
      $display("  BrLT: Expected %b, Got %b", expected_BrLT, BrLT);
      $display("  BrLTU: Expected %b, Got %b", expected_BrLTU, BrLTU);

      if (BrEq === expected_BrEq && BrLT === expected_BrLT && BrLTU === expected_BrLTU) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting branch_comparator Testbench...");

    // Test 1: Equal values
    test_case(10, 10, 1, 0, 0, "Equal values (10 == 10)");

    // Test 2: rd_data1_i < rd_data2_i (signed and unsigned)
    test_case(5, 10, 0, 1, 1, "rd_data1 < rd_data2 (5 < 10)");

    // Test 3: rd_data1_i > rd_data2_i (signed and unsigned)
    test_case(10, 5, 0, 0, 0, "rd_data1 > rd_data2 (10 > 5)");

    // Test 4: Signed comparison with negative numbers
    test_case(32'shFFFF_FFFF, 32'sh0000_0001, 0, 1, 0, "Signed: -1 < 1"); // -1 < 1
    test_case(32'sh0000_0001, 32'shFFFF_FFFF, 0, 0, 1, "Signed: 1 > -1 (unsigned: 1 > MAX_UINT)"); // 1 > -1 (unsigned: 1 > 0xFFFFFFFF)
    test_case(32'shFFFF_FFFE, 32'shFFFF_FFFF, 0, 1, 1, "Signed: -2 < -1 (unsigned: MAX_UINT-1 < MAX_UINT)");

    // Test 5: Zero values
    test_case(0, 0, 1, 0, 0, "Zero values (0 == 0)");
    test_case(0, 1, 0, 1, 1, "Zero vs One (0 < 1)");

    // Test 6: Max unsigned value
    test_case(32'hFFFF_FFFF, 32'hFFFF_FFFF, 1, 0, 0, "Max unsigned value (equal)");
    test_case(32'hFFFF_FFFE, 32'hFFFF_FFFF, 0, 1, 1, "Max unsigned value (less than)");

    $display("\nAll branch_comparator tests finished.");
    $finish;
  end

endmodule
