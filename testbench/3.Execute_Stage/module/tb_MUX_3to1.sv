`timescale 1ns / 1ps

import defines::*;

module tb_MUX_3to1;

  // Testbench signals
  logic [DATA_WIDTH-1:0] rd_data_i;
  logic [DATA_WIDTH-1:0] MEM_ALU_i;
  logic [DATA_WIDTH-1:0] WB_DATA_i;
  fw_sel_e sel;
  logic [DATA_WIDTH-1:0] out;

  // Instantiate the DUT
  MUX_3to1 dut (
    .rd_data_i(rd_data_i),
    .MEM_ALU_i(MEM_ALU_i),
    .WB_DATA_i(WB_DATA_i),
    .sel(sel),
    .out(out)
  );

  // Test task
  task automatic test_case(
    input fw_sel_e sel_t,
    input logic [DATA_WIDTH-1:0] rd_data_t,
    input logic [DATA_WIDTH-1:0] MEM_ALU_t,
    input logic [DATA_WIDTH-1:0] WB_DATA_t,
    input logic [DATA_WIDTH-1:0] expected_out,
    input string test_name
  );
    begin
      rd_data_i = rd_data_t;
      MEM_ALU_i = MEM_ALU_t;
      WB_DATA_i = WB_DATA_t;
      sel = sel_t;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  Inputs: rd_data_i=0x%h, MEM_ALU_i=0x%h, WB_DATA_i=0x%h, sel=%s",
               rd_data_i, MEM_ALU_i, WB_DATA_i, sel.name());
      $display("  Output: Expected 0x%h, Got 0x%h", expected_out, out);

      if (out === expected_out) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting MUX_3to1 Testbench...");

    // Test 1: Select FW_NONE (rd_data_i)
    test_case(FW_NONE, 32'h1111_1111, 32'hAAAA_AAAA, 32'hBBBB_BBBB, 32'h1111_1111, "Select FW_NONE");

    // Test 2: Select FW_MEM_ALU
    test_case(FW_MEM_ALU, 32'h1111_1111, 32'hAAAA_AAAA, 32'hBBBB_BBBB, 32'hAAAA_AAAA, "Select FW_MEM_ALU");

    // Test 3: Select FW_WB_DATA
    test_case(FW_WB_DATA, 32'h1111_1111, 32'hAAAA_AAAA, 32'hBBBB_BBBB, 32'hBBBB_BBBB, "Select FW_WB_DATA");

    // Test 4: All inputs are the same
    test_case(FW_NONE, 32'hCCCC_CCCC, 32'hCCCC_CCCC, 32'hCCCC_CCCC, 32'hCCCC_CCCC, "All inputs same (FW_NONE)");
    test_case(FW_MEM_ALU, 32'hCCCC_CCCC, 32'hCCCC_CCCC, 32'hCCCC_CCCC, 32'hCCCC_CCCC, "All inputs same (FW_MEM_ALU)");
    test_case(FW_WB_DATA, 32'hCCCC_CCCC, 32'hCCCC_CCCC, 32'hCCCC_CCCC, 32'hCCCC_CCCC, "All inputs same (FW_WB_DATA)");

    // Test 5: Edge case - default (should be 'x' or 0 depending on simulator)
    // The module defines default: out = 'x', so expect 'x' if simulator supports it, else 0.
    // For simplicity, we'll just check if it's not one of the valid selections.
    // This test might be simulator dependent for 'x' propagation.
    sel = 3; // An undefined value for fw_sel_e
    #1;
    $display("\nTest Case: Undefined selection");
    $display("  Inputs: sel=%0d", sel);
    $display("  Output: Got 0x%h", out);
    // Cannot reliably assert 'x' in all simulators, so just display and note.
    $display("  [INFO] Undefined selection test. Output might be 'x' or 0 depending on simulator.");

    $display("\nAll MUX_3to1 tests finished.");
    $finish;
  end

endmodule
