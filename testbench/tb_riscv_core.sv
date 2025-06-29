`timescale 1ns / 1ps
`include "../src/header/defines.sv"

module tb_riscv_core;

  // DUT signals
  logic clk;
  logic rst_n;
  logic [31:0] instruction_i;
  logic [31:0] pc_i;

  // Instantiate the DUT
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n),
    .instruction_i(instruction_i),
    .pc_i(pc_i)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  logic [31:0] result_x3;
  // Test sequence
  initial begin
    // 1. Reset the core
    rst_n = 0;
    pc_i = 0;
    instruction_i = 0;
    #10;
    rst_n = 1;
    #10;

    // 2. Start issuing instructions
    $display("--- Test Start ---");

    // ADDI x1, x0, 5  (0x00500093)
    issue_instruction(32'h0000, 32'h00500093);
    
    // ADDI x2, x0, 10 (0x00A00113)
    issue_instruction(32'h0004, 32'h00A00113);

    // To avoid data hazards without a forwarding unit,
    // we need to wait for the pipeline to clear.
    // Insert NOPs (addi x0, x0, 0)
    issue_instruction(32'h0008, 32'h00000013); // NOP
    issue_instruction(32'h000C, 32'h00000013); // NOP
    issue_instruction(32'h0010, 32'h00000013); // NOP
    issue_instruction(32'h0014, 32'h00000013); // NOP

    // ADD x3, x1, x2 (0x002081B3)
    issue_instruction(32'h0018, 32'h002081B3);
    
    // Let the last instruction propagate through the pipeline
    repeat (5) begin
        @(posedge clk);
    end

    // 3. Verification
    // We need to check the value of register x3.
    // We use a hierarchical name to access the register file inside the DUT.
    // NOTE: The instance names must match your design.
    // Path: dut.decode_stage_inst.register_file_inst.rf[register_index]
    
    result_x3 = dut.decode_stage_inst.register_file_inst.registers[3];

    if (result_x3 == 15) begin
      $display("SUCCESS: x3 = %0d", result_x3);
    end else begin
      $display("FAILURE: x3 = %0d, Expected = 15", result_x3);
    end

    $display("--- Test End ---");
    $finish;
  end

  // Task to issue a single instruction
  task issue_instruction(input [31:0] pc, input [31:0] instruction);
    @(posedge clk);
    pc_i = pc;
    instruction_i = instruction;
    $display("Cycle %0t: PC=%h, INST=%h", $time, pc, instruction);
  endtask

endmodule
