`timescale 1ns / 1ps

import defines::*;

module tb_alu;

  localparam CLK_PERIOD = 10; // 10ns

  logic clk;
  
  alu_sel_e ALUSel_i;
  logic [DATA_WIDTH-1:0] alu_operand1_i;
  logic [DATA_WIDTH-1:0] alu_operand2_i;
  logic [DATA_WIDTH-1:0] alu_result_o;

  alu dut (
    .ALUSel_i(ALUSel_i),
    .alu_operand1_i(alu_operand1_i),
    .alu_operand2_i(alu_operand2_i),
    .alu_result_o(alu_result_o)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  task automatic test(
    input alu_sel_e ALUSel_t,
    input logic [DATA_WIDTH-1:0] operand1_t,
    input logic [DATA_WIDTH-1:0] operand2_t,
    input logic [DATA_WIDTH-1:0] expected_result,
    input string operation_name
    );
    
    @(posedge clk);
    #1;
    ALUSel_i = ALUSel_t;
    alu_operand1_i = operand1_t;
    alu_operand2_i = operand2_t;

    @(posedge clk);
    #1;

    assert(alu_result_o == expected_result) 
      else $error("[Error] ALU result Mismatch for %s : expected result %0d, Got %0d at %0t",
        operation_name, expected_result, alu_result_o, $time);
    

    $display("[Pass] %s", operation_name);
  endtask

  initial begin
    ALUSel_i = ALU_ADD;
    alu_operand1_i = '0;  
    alu_operand2_i = '0;

    @(posedge clk);
    #1;

    $display("\n=================================");
    $display("    [Info] Validate alu result");
    $display("=================================\n");

    test(ALU_ADD, 32'd5,  32'd10, 32'd15, "ADD");
    test(ALU_SUB, 32'd10, 32'd10, 32'd0,  "SUB");
    test(ALU_AND, 32'd3,  32'd1,  32'd1,  "AND");
    test(ALU_XOR, 32'd4,  32'd3,  32'd7,  "XOR");
    test(ALU_OR,  32'd4,  32'd5,  32'd5,  "OR");
    test(ALU_SLL, 32'd4,  32'd1,  32'd8,  "SLL");
    test(ALU_SRL, 32'd4,  32'd2,  32'd1,  "SRA");
    test(ALU_SRA, 32'd10, 32'd2,  32'd2,  "SRA Positive");
    test(ALU_SRA, -32'sd8, 32'd2, -32'sd2,  "SRA Negative");
    test(ALU_SLT, -32'sd20, 32'sd10, 32'd1,  "SLT (True)");
    test(ALU_SLT, 32'sd10, -32'sd20, 32'd0,  "SLT (False)");
    test(ALU_SLTU, 32'd3, 32'd5, 32'd1,  "SLTU (True)");
    test(ALU_SLTU, 32'd5, 32'd3, 32'd0,  "SLTU (False)");
    test(ALU_PASS_B, 32'd10, 32'd3, 32'd3,  "PASS_B");

    $display("\n===============================================");
    $display("          [Success] Pass alu test");
    $display("===============================================");
    
    repeat(100) @(posedge clk);
    $finish;
  end


endmodule
