`timescale 1ns / 1ps

import defines::*;

module tb_writeback_stage;

  // Testbench signals
  wb_sel_e WB_WBSel_i;
  logic [DATA_WIDTH-1:0] WB_alu_result_i;
  logic [DATA_WIDTH-1:0] WB_rd_data_i;
  logic [DATA_WIDTH-1:0] WB_pc_plus4_i;

  logic [DATA_WIDTH-1:0] WB_writeback_data_o;

  // Instantiate the DUT
  writeback_stage dut (
    .WB_WBSel_i(WB_WBSel_i),
    .WB_alu_result_i(WB_alu_result_i),
    .WB_rd_data_i(WB_rd_data_i),
    .WB_pc_plus4_i(WB_pc_plus4_i),
    .WB_writeback_data_o(WB_writeback_data_o)
  );

  // Test task
  task automatic test_case(
    input wb_sel_e sel_type,
    input logic [DATA_WIDTH-1:0] alu_res,
    input logic [DATA_WIDTH-1:0] rd_dat,
    input logic [DATA_WIDTH-1:0] pc4,
    input logic [DATA_WIDTH-1:0] expected_output,
    input string test_name
  );
    begin
      WB_WBSel_i = sel_type;
      WB_alu_result_i = alu_res;
      WB_rd_data_i = rd_dat;
      WB_pc_plus4_i = pc4;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  Inputs: WBSel=%s, ALU_Result=0x%h, RD_Data=0x%h, PC_Plus4=0x%h",
               WB_WBSel_i.name(), WB_alu_result_i, WB_rd_data_i, WB_pc_plus4_i);
      $display("  Output: Expected 0x%h, Got 0x%h", expected_output, WB_writeback_data_o);

      if (WB_writeback_data_o === expected_output) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting writeback_stage Testbench...");

    // Initialize inputs
    WB_alu_result_i = 32'hAAAA_AAAA;
    WB_rd_data_i    = 32'hBBBB_BBBB;
    WB_pc_plus4_i   = 32'hCCCC_CCCC;

    // Test 1: Select WB_ALU
    test_case(WB_ALU, WB_alu_result_i, WB_rd_data_i, WB_pc_plus4_i, WB_alu_result_i, "Select WB_ALU");

    // Test 2: Select WB_MEM
    test_case(WB_MEM, WB_alu_result_i, WB_rd_data_i, WB_pc_plus4_i, WB_rd_data_i, "Select WB_MEM");

    // Test 3: Select WB_PC4
    test_case(WB_PC4, WB_alu_result_i, WB_rd_data_i, WB_pc_plus4_i, WB_pc_plus4_i, "Select WB_PC4");

    // Test 4: Select WB_NONE (default case, should output 0)
    test_case(WB_NONE, WB_alu_result_i, WB_rd_data_i, WB_pc_plus4_i, 32'h0, "Select WB_NONE");

    // Test 5: Test with different values
    test_case(WB_ALU, 32'h1234_5678, 32'h9ABC_DEF0, 32'h1020_3040, 32'h1234_5678, "Select WB_ALU with new values");
    test_case(WB_MEM, 32'h1234_5678, 32'h9ABC_DEF0, 32'h1020_3040, 32'h9ABC_DEF0, "Select WB_MEM with new values");

    $display("\nAll writeback_stage tests finished.");
    $finish;
  end

endmodule
