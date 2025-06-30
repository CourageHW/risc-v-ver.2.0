`timescale 1ns / 1ps

import defines::*;

module tb_memory_stage;

  // Testbench signals
  logic clk;
  logic MEM_MemWrite_i;
  logic MEM_MemRead_i;
  logic WB_MemWrite_i;
  logic [DATA_WIDTH-1:0] MEM_instruction_i;
  logic [DATA_WIDTH-1:0] MEM_addr_i;
  logic [DATA_WIDTH-1:0] MEM_wr_data_i;
  logic [DATA_WIDTH-1:0] WB_addr_i;
  logic [DATA_WIDTH-1:0] WB_wr_data_i;

  logic [DATA_WIDTH-1:0] MEM_rd_data_o;

  // Instantiate the DUT
  memory_stage dut (
    .clk(clk),
    .MEM_MemWrite_i(MEM_MemWrite_i),
    .MEM_MemRead_i(MEM_MemRead_i),
    .WB_MemWrite_i(WB_MemWrite_i),
    .MEM_instruction_i(MEM_instruction_i),
    .MEM_addr_i(MEM_addr_i),
    .MEM_wr_data_i(MEM_wr_data_i),
    .WB_addr_i(WB_addr_i),
    .WB_wr_data_i(WB_wr_data_i),
    .MEM_rd_data_o(MEM_rd_data_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period, 100MHz clock
  end

  // Test sequence
  initial begin
    $display("Starting memory_stage Testbench...");

    // 1. Initialize inputs
    MEM_MemWrite_i    = 0;
    MEM_MemRead_i     = 0;
    WB_MemWrite_i     = 0;
    MEM_instruction_i = '0;
    MEM_addr_i        = '0;
    MEM_wr_data_i     = '0;
    WB_addr_i         = '0;
    WB_wr_data_i      = '0;

    // Wait for a few cycles to stabilize
    repeat(2) @(posedge clk);

    // TEST 1: Store Word (SW) and Load Word (LW)
    $display("\nTest 1: SW -> LW");
    @(posedge clk);
    MEM_MemWrite_i    <= 1;
    MEM_MemRead_i     <= 0;
    MEM_instruction_i <= {29'b0, FUNCT3_SW, 3'b0}; // Instruction with FUNCT3_SW
    MEM_addr_i        <= 32'h0000_0100; // Address 256
    MEM_wr_data_i     <= 32'hDEADBEEF;
    @(posedge clk);
    MEM_MemWrite_i    <= 0; // De-assert write enable

    // Read back the data
    MEM_MemRead_i     <= 1;
    MEM_instruction_i <= {29'b0, FUNCT3_LW, 3'b0}; // Instruction with FUNCT3_LW (funct3 doesn't matter for read)
    MEM_addr_i        <= 32'h0000_0100;
    @(posedge clk);
    MEM_MemRead_i     <= 0; // De-assert read enable after one cycle
    
    @(posedge clk); 
    if (MEM_rd_data_o === 32'hDEADBEEF) begin
      $display("  [PASS] SW/LW test passed. Read: %h", MEM_rd_data_o);
    end else begin
      $error("  [FAIL] SW/LW test failed. Expected: %h, Got: %h", 32'hDEADBEEF, MEM_rd_data_o);
    end
    
    repeat(2) @(posedge clk);

    // TEST 2: Store Half-word (SH) and Load Word (LW)
    $display("\nTest 2: SH -> LW");
    // First, write a known value to the word
    @(posedge clk);
    MEM_MemWrite_i    <= 1;
    MEM_instruction_i <= {29'b0, FUNCT3_SW, 3'b0};
    MEM_addr_i        <= 32'h0000_0200; // Address 512
    MEM_wr_data_i     <= 32'hAAAAAAAA;
    @(posedge clk);
    
    // Write to the lower half-word (address 512)
    MEM_instruction_i <= {29'b0, FUNCT3_SH, 3'b0}; // Instruction with FUNCT3_SH
    MEM_addr_i        <= 32'h0000_0200;
    MEM_wr_data_i     <= 32'hXXXXCAFE; // Lower 16 bits are 'CAFE'
    @(posedge clk);

    // Write to the upper half-word (address 514)
    MEM_addr_i        <= 32'h0000_0202;
    MEM_wr_data_i     <= 32'hXXXXBEEF; // Lower 16 bits are 'BEEF'
    @(posedge clk);
    MEM_MemWrite_i    <= 0;

    // Read back the full word and check
    MEM_MemRead_i     <= 1;
    MEM_instruction_i <= {29'b0, FUNCT3_LW, 3'b0};
    MEM_addr_i        <= 32'h0000_0200;
    @(posedge clk);
    MEM_MemRead_i     <= 0;
    @(posedge clk);
    if (MEM_rd_data_o === 32'hBEEFCAFE) begin
      $display("  [PASS] SH/LW test passed. Read: %h", MEM_rd_data_o);
    end else begin
      $error("  [FAIL] SH/LW test failed. Expected: %h, Got: %h", 32'hBEEFCAFE, MEM_rd_data_o);
    end

    repeat(2) @(posedge clk);

    // TEST 3: Store Byte (SB) and Load Word (LW)
    $display("\nTest 3: SB -> LW");
    @(posedge clk);
    MEM_MemWrite_i    <= 1;
    MEM_instruction_i <= {29'b0, FUNCT3_SW, 3'b0};
    MEM_addr_i        <= 32'h0000_0300; // Address 768
    MEM_wr_data_i     <= 32'hFFFFFFFF;
    @(posedge clk);

    // Write individual bytes
    MEM_instruction_i <= {29'b0, FUNCT3_SB, 3'b0}; // Instruction with FUNCT3_SB
    MEM_addr_i        <= 32'h0000_0300; // Byte 0
    MEM_wr_data_i     <= 32'hXXXXXX11;
    @(posedge clk);
    MEM_addr_i        <= 32'h0000_0301; // Byte 1
    MEM_wr_data_i     <= 32'hXXXXXX22;
    @(posedge clk);
    MEM_addr_i        <= 32'h0000_0302; // Byte 2
    MEM_wr_data_i     <= 32'hXXXXXX33;
    @(posedge clk);
    MEM_addr_i        <= 32'h0000_0303; // Byte 3
    MEM_wr_data_i     <= 32'hXXXXXX44;
    @(posedge clk);
    MEM_MemWrite_i    <= 0;

    // Read back the full word
    MEM_MemRead_i     <= 1;
    MEM_instruction_i <= {29'b0, FUNCT3_LW, 3'b0};
    MEM_addr_i        <= 32'h0000_0300;
    @(posedge clk);
    MEM_MemRead_i     <= 0;
    @(posedge clk);
    if (MEM_rd_data_o === 32'h44332211) begin
      $display("  [PASS] SB/LW test passed. Read: %h", MEM_rd_data_o);
    end else begin
      $error("  [FAIL] SB/LW test failed. Expected: %h, Got: %h", 32'h44332211, MEM_rd_data_o);
    end
    
    repeat(2) @(posedge clk);

    // TEST 4: Write-Back Forwarding
    $display("\nTest 4: Write-Back Forwarding");
    // Write an initial value to memory (via MEM stage)
    @(posedge clk);
    MEM_MemWrite_i    <= 1;
    MEM_instruction_i <= {29'b0, FUNCT3_SW, 3'b0};
    MEM_addr_i        <= 32'h0000_0400; // Address 1024
    MEM_wr_data_i     <= 32'h11111111;
    @(posedge clk);
    MEM_MemWrite_i    <= 0;
    @(posedge clk);

    // Now, read from the address while a WB is pending for the same address
    MEM_MemRead_i     <= 1;
    MEM_instruction_i <= {29'b0, FUNCT3_LW, 3'b0};
    MEM_addr_i        <= 32'h0000_0400;
    WB_MemWrite_i     <= 1;
    WB_addr_i         <= 32'h0000_0400;
    WB_wr_data_i      <= 32'hFFFFFFFF; // This value should be forwarded
    @(posedge clk);
    MEM_MemRead_i     <= 0;
    WB_MemWrite_i     <= 0;
    @(posedge clk);
    if (MEM_rd_data_o === 32'hFFFFFFFF) begin
      $display("  [PASS] Forwarding test passed. Read: %h", MEM_rd_data_o);
    end else begin
      $error("  [FAIL] Forwarding test failed. Expected: %h, Got: %h", 32'hFFFFFFFF, MEM_rd_data_o);
    end

    $display("\nAll memory_stage tests finished.");
    #100;
    $stop;
  end

endmodule
