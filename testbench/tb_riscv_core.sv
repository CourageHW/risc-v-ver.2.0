`timescale 1ns / 1ps

module tb_riscv_core;

  // --- Parameters ---
  localparam CLK_PERIOD = 10; // 10ns = 100MHz

  // --- Testbench Signals ---
  logic clk;
  logic rst_n;

  // --- Instantiate the DUT (Device Under Test) ---
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // --- Clock Generation ---
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // --- Test Sequence ---
  initial begin
    $display("===============================================");
    $display("= Starting RISC-V Core Testbench Simulation =");
    $display("= (Hazard-Free Version for No-Forwarding CPU) =");
    $display("===============================================");

    // 1. Apply reset
    rst_n = 1'b0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    $display("[%0t] Reset released.", $time);

    // 2. Run simulation for a fixed number of cycles
    repeat (25) @(posedge clk);

    // 3. Check final register values
    $display("\n-----------------------------------------------");
    $display("--- Final Register State Verification ---");
    $display("-----------------------------------------------");
    
    // Check if the values match the expected results from the new assembly program.
    // The path to the register file might need adjustment based on your exact hierarchy.
    // e.g., dut.decode_stage_inst.register_file_inst.rf[1]
    verify_register("x1 (10)", dut.decode_stage_inst.register_file_inst.registers[1], 32'd10);
    verify_register("x2 (10)", dut.decode_stage_inst.register_file_inst.registers[2], 32'd10);
    verify_register("x4 (should be 0)", dut.decode_stage_inst.register_file_inst.registers[4], 32'd0);
    verify_register("x5 (100)", dut.decode_stage_inst.register_file_inst.registers[5], 32'd100);

    $display("\n===============================================");
    $display("= Simulation Finished =");
    $display("===============================================");
    repeat(100) @(posedge clk);
    $finish;
  end

  // --- Verification Task ---
  task verify_register(string name, logic [31:0] value, logic [31:0] expected);
    if (value === expected) begin
      $display("[PASS] %s: Expected 0x%h, Got 0x%h", name, expected, value);
    end else begin
      $error("[FAIL] %s: Expected 0x%h, Got 0x%h", name, expected, value);
    end
  endtask
endmodule
