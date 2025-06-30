`timescale 1ns / 1ps

import defines::*;

module tb_instruction_memory;

  // Testbench signals
  logic [INST_MEM_ADDR_WIDTH-1:0] rd_addr_i;
  logic [DATA_WIDTH-1:0] rd_data_o;

  // Instantiate the DUT
  instruction_memory dut (
    .rd_addr_i(rd_addr_i),
    .rd_data_o(rd_data_o)
  );

  // Test sequence
  initial begin
    $display("Starting instruction_memory Testbench...");

    // Test 1: Read from address 0
    rd_addr_i = 0;
    #1; // Allow combinational logic to settle
    if (rd_data_o === 32'h00000001) begin
      $display("  [PASS] Test 1 (addr 0) successful. Expected: %h, Got: %h", 32'h00000001, rd_data_o);
    end else begin
      $error("  [FAIL] Test 1 (addr 0) failed. Expected: %h, Got: %h", 32'h00000001, rd_data_o);
    end

    // Test 2: Read from address 5
    rd_addr_i = 5;
    #1;
    if (rd_data_o === 32'h00000006) begin
      $display("  [PASS] Test 2 (addr 5) successful. Expected: %h, Got: %h", 32'h00000006, rd_data_o);
    end else begin
      $error("  [FAIL] Test 2 (addr 5) failed. Expected: %h, Got: %h", 32'h00000006, rd_data_o);
    end

    // Test 3: Read from address 15
    rd_addr_i = 15;
    #1;
    if (rd_data_o === 32'h00000010) begin
      $display("  [PASS] Test 3 (addr 15) successful. Expected: %h, Got: %h", 32'h00000010, rd_data_o);
    end else begin
      $error("  [FAIL] Test 3 (addr 15) failed. Expected: %h, Got: %h", 32'h00000010, rd_data_o);
    end

    // Test 4: Read from an address beyond the initial program.mem size (should be 0 or 'x depending on simulator)
    // Assuming memory is initialized to 0 beyond the loaded data
    rd_addr_i = 100;
    #1;
    if (rd_data_o === 32'h0) begin // xxxxxxxx <= correct
      $display("  [PASS] Test 4 (addr 100) successful. Expected: %h, Got: %h", 32'h0, rd_data_o);
    end else begin
      $error("  [FAIL] Test 4 (addr 100) failed. Expected: %h, Got: %h", 32'h0, rd_data_o);
    end

    $display("\nAll instruction_memory tests finished.");
    $finish;
  end

endmodule
