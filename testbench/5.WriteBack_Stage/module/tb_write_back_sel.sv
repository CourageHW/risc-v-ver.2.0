`timescale 1ns / 1ps

import defines::*;

module tb_write_back_sel;

  // Testbench signals
  wb_sel_e WBSel_i;
  logic [DATA_WIDTH-1:0] alu_result_i;
  logic [DATA_WIDTH-1:0] rd_data_i;
  logic [DATA_WIDTH-1:0] pc_plus4_i;

  logic [DATA_WIDTH-1:0] writeback_data_o;

  // Instantiate the DUT
  write_back_sel dut (
    .WBSel_i(WBSel_i),
    .alu_result_i(alu_result_i),
    .rd_data_i(rd_data_i),
    .pc_plus4_i(pc_plus4_i),
    .writeback_data_o(writeback_data_o)
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
      WBSel_i = sel_type;
      alu_result_i = alu_res;
      rd_data_i = rd_dat;
      pc_plus4_i = pc4;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  Inputs: WBSel=%s, ALU_Result=0x%h, RD_Data=0x%h, PC_Plus4=0x%h",
               WBSel_i.name(), alu_result_i, rd_data_i, pc_plus4_i);
      $display("  Output: Expected 0x%h, Got 0x%h", expected_output, writeback_data_o);

      if (writeback_data_o === expected_output) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting write_back_sel Testbench...");

    // Initialize inputs
    alu_result_i = 32'hAAAA_AAAA;
    rd_data_i    = 32'hBBBB_BBBB;
    pc_plus4_i   = 32'hCCCC_CCCC;

    // Test 1: Select WB_ALU
    test_case(WB_ALU, alu_result_i, rd_data_i, pc_plus4_i, alu_result_i, "Select WB_ALU");

    // Test 2: Select WB_MEM
    test_case(WB_MEM, alu_result_i, rd_data_i, pc_plus4_i, rd_data_i, "Select WB_MEM");

    // Test 3: Select WB_PC4
    test_case(WB_PC4, alu_result_i, rd_data_i, pc_plus4_i, pc_plus4_i, "Select WB_PC4");

    // Test 4: Select WB_NONE (default case, should output 0)
    test_case(WB_NONE, alu_result_i, rd_data_i, pc_plus4_i, 32'h0, "Select WB_NONE");

    // Test 5: Test with different values
    test_case(WB_ALU, 32'h1234_5678, 32'h9ABC_DEF0, 32'h1020_3040, 32'h1234_5678, "Select WB_ALU with new values");
    test_case(WB_MEM, 32'h1234_5678, 32'h9ABC_DEF0, 32'h1020_3040, 32'h9ABC_DEF0, "Select WB_MEM with new values");

    $display("\nAll write_back_sel tests finished.");
    $finish;
  end

endmodule
