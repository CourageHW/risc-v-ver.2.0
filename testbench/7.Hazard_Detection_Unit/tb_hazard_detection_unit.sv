`timescale 1ns / 1ps

import defines::*;

module tb_hazard_detection_unit;

  // Testbench signals
  logic [4:0] ID_rs1_addr_i;
  logic [4:0] ID_rs2_addr_i;
  logic [4:0] EX_rd_addr_i;
  logic EX_MemRead_i;

  logic PCWrite_en_o;
  logic IF_ID_write_en_o;
  logic ID_EX_flush_o;

  // Instantiate the DUT
  hazard_detection_unit dut (
    .ID_rs1_addr_i(ID_rs1_addr_i),
    .ID_rs2_addr_i(ID_rs2_addr_i),
    .EX_rd_addr_i(EX_rd_addr_i),
    .EX_MemRead_i(EX_MemRead_i),
    .PCWrite_en_o(PCWrite_en_o),
    .IF_ID_write_en_o(IF_ID_write_en_o),
    .ID_EX_flush_o(ID_EX_flush_o)
  );

  // Test task
  task automatic test_case(
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] ex_rd_addr,
    input logic ex_mem_read,
    input logic expected_PCWrite_en,
    input logic expected_IF_ID_write_en,
    input logic expected_ID_EX_flush,
    input string test_name
  );
    begin
      ID_rs1_addr_i = rs1_addr;
      ID_rs2_addr_i = rs2_addr;
      EX_rd_addr_i = ex_rd_addr;
      EX_MemRead_i = ex_mem_read;
      #1; // Allow combinational logic to settle

      $display("\nTest Case: %s", test_name);
      $display("  Inputs: ID_rs1_addr=%0d, ID_rs2_addr=%0d, EX_rd_addr=%0d, EX_MemRead=%b",
               ID_rs1_addr_i, ID_rs2_addr_i, EX_rd_addr_i, EX_MemRead_i);
      $display("  Outputs: PCWrite_en: Exp %b, Got %b | IF_ID_write_en: Exp %b, Got %b | ID_EX_flush: Exp %b, Got %b",
               expected_PCWrite_en, PCWrite_en_o, expected_IF_ID_write_en, IF_ID_write_en_o, expected_ID_EX_flush, ID_EX_flush_o);

      if (PCWrite_en_o === expected_PCWrite_en &&
          IF_ID_write_en_o === expected_IF_ID_write_en &&
          ID_EX_flush_o === expected_ID_EX_flush) begin
        $display("  [PASS] %s", test_name);
      end else begin
        $error("  [FAIL] %s", test_name);
      end
    end
  endtask

  // Test sequence
  initial begin
    $display("Starting hazard_detection_unit Testbench...");

    // Test 1: No hazard (EX_MemRead_i = 0)
    test_case(5'd1, 5'd2, 5'd3, 0, 1, 1, 0, "No Hazard (EX_MemRead_i = 0)");

    // Test 2: No hazard (EX_rd_addr_i = 0)
    test_case(5'd1, 5'd2, 5'd0, 1, 1, 1, 0, "No Hazard (EX_rd_addr_i = 0)");

    // Test 3: No hazard (no address match)
    test_case(5'd1, 5'd2, 5'd3, 1, 1, 1, 0, "No Hazard (No Address Match)");

    // Test 4: Load-Use Hazard (EX_rd_addr_i matches ID_rs1_addr_i)
    test_case(5'd5, 5'd2, 5'd5, 1, 0, 0, 1, "Load-Use Hazard (rs1 match)");

    // Test 5: Load-Use Hazard (EX_rd_addr_i matches ID_rs2_addr_i)
    test_case(5'd1, 5'd5, 5'd5, 1, 0, 0, 1, "Load-Use Hazard (rs2 match)");

    // Test 6: Load-Use Hazard (EX_rd_addr_i matches both ID_rs1_addr_i and ID_rs2_addr_i)
    test_case(5'd5, 5'd5, 5'd5, 1, 0, 0, 1, "Load-Use Hazard (Both rs1 and rs2 match)");

    // Test 7: No hazard (EX_MemRead_i = 1, but EX_rd_addr_i is 0)
    test_case(5'd1, 5'd2, 5'd0, 1, 1, 1, 0, "No Hazard (EX_MemRead_i=1, EX_rd_addr=0)");

    $display("\nAll hazard_detection_unit tests finished.");
    $finish;
  end

endmodule
