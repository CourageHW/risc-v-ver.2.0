`timescale 1ns / 1ps

// Import the definitions package
import defines::*;

module tb_data_memory;

  // Testbench signals
  logic clk;
  logic MemWrite_en;
  logic MemRead_en;
  logic [2:0] MEM_funct3_i;
  logic [DATA_WIDTH-1:0] rd_addr_i;
  logic [DATA_WIDTH-1:0] wr_data_i;
  logic [DATA_WIDTH-1:0] rd_data_o;

  // Instantiate the Device Under Test (DUT)
  data_memory dut (
    .clk(clk),
    .MemWrite_en(MemWrite_en),
    .MemRead_en(MemRead_en),
    .MEM_funct3_i(MEM_funct3_i),
    .rd_addr_i(rd_addr_i),
    .wr_data_i(wr_data_i),
    .rd_data_o(rd_data_o)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period, 100MHz clock
  end

  // Test sequence
  initial begin
    $display("Starting Data Memory Testbench...");
    // 1. Initialize inputs
    MemWrite_en = 0;
    MemRead_en = 0;
    MEM_funct3_i = 0;
    rd_addr_i = 0;
    wr_data_i = 0;

    // Wait for a few cycles to stabilize
    repeat(2) @(posedge clk);

    // TEST 1: Store Word (SW) and Load Word (LW)
    $display("Test 1: SW -> LW");
    @(posedge clk);
    MemWrite_en  <= 1;
    MemRead_en   <= 0;
    MEM_funct3_i <= FUNCT3_SW;
    rd_addr_i    <= 32'h0000_0100; // Address 256
    wr_data_i    <= 32'hDEADBEEF;
    @(posedge clk);
    MemWrite_en  <= 0; // De-assert write enable

    // Read back the data
    MemRead_en   <= 1;
    rd_addr_i    <= 32'h0000_0100;
    @(posedge clk);
    MemRead_en   <= 0; // De-assert read enable after one cycle
    
    // The read data will be available on the next clock edge
    @(posedge clk); 
    if (rd_data_o === 32'hDEADBEEF) begin
      $display("  [PASS] SW/LW test passed. Read: %h", rd_data_o);
    end else begin
      $error("  [FAIL] SW/LW test failed. Expected: %h, Got: %h", 32'hDEADBEEF, rd_data_o);
    end
    
    repeat(2) @(posedge clk);

    // TEST 2: Store Half-word (SH) and Load Word (LW)
    $display("Test 2: SH -> LW");
    // First, write a known value to the word
    @(posedge clk);
    MemWrite_en  <= 1;
    MEM_funct3_i <= FUNCT3_SW;
    rd_addr_i    <= 32'h0000_0200; // Address 512
    wr_data_i    <= 32'hAAAAAAAA;
    @(posedge clk);
    
    // Write to the lower half-word (address 512)
    MEM_funct3_i <= FUNCT3_SH;
    rd_addr_i    <= 32'h0000_0200;
    wr_data_i    <= 32'hXXXXCAFE; // Lower 16 bits are 'CAFE'
    @(posedge clk);

    // Write to the upper half-word (address 514)
    rd_addr_i    <= 32'h0000_0202;
    wr_data_i    <= 32'hXXXXBEEF; // Lower 16 bits are 'BEEF'
    @(posedge clk);
    MemWrite_en  <= 0;

    // Read back the full word and check
    MemRead_en   <= 1;
    rd_addr_i    <= 32'h0000_0200;
    @(posedge clk);
    MemRead_en   <= 0;
    @(posedge clk);
    if (rd_data_o === 32'hBEEFCAFE) begin
      $display("  [PASS] SH/LW test passed. Read: %h", rd_data_o);
    end else begin
      $error("  [FAIL] SH/LW test failed. Expected: %h, Got: %h", 32'hBEEFCAFE, rd_data_o);
    end

    repeat(2) @(posedge clk);

    // TEST 3: Store Byte (SB) and Load Word (LW)
    $display("Test 3: SB -> LW");
    // Pre-fill the word
    @(posedge clk);
    MemWrite_en  <= 1;
    MEM_funct3_i <= FUNCT3_SW;
    rd_addr_i    <= 32'h0000_0300; // Address 768
    wr_data_i    <= 32'hFFFFFFFF;
    @(posedge clk);

    // Write individual bytes
    MEM_funct3_i <= FUNCT3_SB;
    rd_addr_i    <= 32'h0000_0300; // Byte 0
    wr_data_i    <= 32'hXXXXXX11;
    @(posedge clk);
    rd_addr_i    <= 32'h0000_0301; // Byte 1
    wr_data_i    <= 32'hXXXXXX22;
    @(posedge clk);
    rd_addr_i    <= 32'h0000_0302; // Byte 2
    wr_data_i    <= 32'hXXXXXX33;
    @(posedge clk);
    rd_addr_i    <= 32'h0000_0303; // Byte 3
    wr_data_i    <= 32'hXXXXXX44;
    @(posedge clk);
    MemWrite_en  <= 0;

    // Read back the full word
    MemRead_en   <= 1;
    rd_addr_i    <= 32'h0000_0300;
    @(posedge clk);
    MemRead_en   <= 0;
    @(posedge clk);
    if (rd_data_o === 32'h44332211) begin
      $display("  [PASS] SB/LW test passed. Read: %h", rd_data_o);
    end else begin
      $error("  [FAIL] SB/LW test failed. Expected: %h, Got: %h", 32'h44332211, rd_data_o);
    end
  
    $display("All tests finished.");

    repeat(100) @(posedge clk);
    $stop;
  end

endmodule
