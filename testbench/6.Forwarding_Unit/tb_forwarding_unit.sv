`timescale 1ns / 1ps

import defines::*;

module tb_forwarding_unit;

  // Inputs
  logic [4:0] ID_rs1_addr_i;
  logic [4:0] ID_rs2_addr_i;
  logic [4:0] EX_rd_addr_i;
  logic [4:0] MEM_rd_addr_i;
  logic EX_RegWrite_i;
  logic MEM_RegWrite_i;

  // Outputs
  fw_sel_e forwardA;
  fw_sel_e forwardB;

  // Instantiate the Unit Under Test (UUT)
  forwarding_unit uut (
    .ID_rs1_addr_i(ID_rs1_addr_i),
    .ID_rs2_addr_i(ID_rs2_addr_i),
    .EX_rd_addr_i(EX_rd_addr_i),
    .MEM_rd_addr_i(MEM_rd_addr_i),
    .EX_RegWrite_i(EX_RegWrite_i),
    .MEM_RegWrite_i(MEM_RegWrite_i),
    .forwardA(forwardA),
    .forwardB(forwardB)
  );

  initial begin
    // Initialize Inputs
    ID_rs1_addr_i = 5'd0;
    ID_rs2_addr_i = 5'd0;
    EX_rd_addr_i = 5'd0;
    MEM_rd_addr_i = 5'd0;
    EX_RegWrite_i = 1'b0;
    MEM_RegWrite_i = 1'b0;

    // Test Case 1: No forwarding
    $display("Test Case 1: No forwarding");
    #10;
    if (forwardA == FW_NONE && forwardB == FW_NONE)
        $display("PASS");
    else
        $display("FAIL");

    // Test Case 2: EX -> ID forwarding for rs1
    $display("Test Case 2: EX -> ID forwarding for rs1");
    EX_RegWrite_i = 1'b1;
    EX_rd_addr_i = 5'd10;
    ID_rs1_addr_i = 5'd10;
    #10;
    if (forwardA == FW_MEM_ALU)
        $display("PASS");
    else
        $display("FAIL");

    // Test Case 3: EX -> ID forwarding for rs2
    $display("Test Case 3: EX -> ID forwarding for rs2");
    ID_rs1_addr_i = 5'd1;
    ID_rs2_addr_i = 5'd10;
    #10;
    if (forwardB == FW_MEM_ALU)
        $display("PASS");
    else
        $display("FAIL");
    
    EX_RegWrite_i = 1'b0;
    ID_rs2_addr_i = 5'd0;


    // Test Case 4: MEM -> ID forwarding for rs1
    $display("Test Case 4: MEM -> ID forwarding for rs1");
    MEM_RegWrite_i = 1'b1;
    MEM_rd_addr_i = 5'd20;
    ID_rs1_addr_i = 5'd20;
    #10;
    if (forwardA == FW_WB_DATA)
        $display("PASS");
    else
        $display("FAIL");

    // Test Case 5: MEM -> ID forwarding for rs2
    $display("Test Case 5: MEM -> ID forwarding for rs2");
    ID_rs1_addr_i = 5'd1;
    ID_rs2_addr_i = 5'd20;
    #10;
    if (forwardB == FW_WB_DATA)
        $display("PASS");
    else
        $display("FAIL");

    // Test Case 6: EX forwarding should have priority over MEM forwarding
    $display("Test Case 6: EX has priority");
    EX_RegWrite_i = 1'b1;
    EX_rd_addr_i = 5'd10;
    ID_rs1_addr_i = 5'd10;
    ID_rs2_addr_i = 5'd20;
    #10;
    if (forwardA == FW_MEM_ALU && forwardB == FW_WB_DATA)
        $display("PASS");
    else
        $display("FAIL");

    $finish;
  end

endmodule
