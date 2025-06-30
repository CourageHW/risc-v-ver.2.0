`timescale 1ns/1ps

import defines::*;

module tb_immediate_generator;

    logic [DATA_WIDTH-1:0] instruction_i;
    logic [DATA_WIDTH-1:0] imm_i_o, imm_s_o, imm_b_o, imm_u_o, imm_j_o;

    logic error_flag = 0;

    // DUT
    immediate_generator uut (
        .instruction_i(instruction_i),
        .imm_i_o(imm_i_o),
        .imm_s_o(imm_s_o),
        .imm_b_o(imm_b_o),
        .imm_u_o(imm_u_o),
        .imm_j_o(imm_j_o)
    );

    initial begin
        $display("=== Immediate Generator Assertion Test ===");

        // 1. I-type
        instruction_i = 32'b111111111111_00010_010_00001_0000011;
        #1;
        $display("Checking I-type...");
        if (imm_i_o !== 32'hFFFFFfff) begin
            $error("❌ I-type immediate failed: got 0x%08x", imm_i_o);
            error_flag = 1;
        end

        // 2. S-type
        instruction_i = 32'b1111111_00001_00010_010_11110_0100011;
        #1;
        $display("Checking S-type...");
        if (imm_s_o !== 32'hFFFFFFFE) begin
            $error("❌ S-type immediate failed: got 0x%08x", imm_s_o);
            error_flag = 1;
        end

        // 3. B-type
        instruction_i = 32'b1_11110_00010_00001_000_1_1110_1100011;
        #1;
        $display("Checking B-type...");
        if (imm_b_o !== 32'h000007DE) begin
            $error("❌ B-type immediate failed: got 0x%08x", imm_b_o);
            error_flag = 1;
        end

        // 4. U-type
        instruction_i = 32'b11111111111111111111_00001_0110111;
        #1;
        $display("Checking U-type...");
        if (imm_u_o !== 32'hFFFFF000) begin
            $error("❌ U-type immediate failed: got 0x%08x", imm_u_o);
            error_flag = 1;
        end

        // 5. J-type
        instruction_i = 32'b1_11111111_1_1111111111_00001_1101111;
        #1;
        $display("Checking J-type...");
        if (imm_j_o !== 32'hFFFFFFFE) begin
            $error("❌ J-type immediate failed: got 0x%08x", imm_j_o);
            error_flag = 1;
        end

        #1;
        if (!error_flag)
            $display("✅ All immediate generator tests passed!");
        else
            $display("❗ Some immediate generator tests failed. Check errors above.");

        $fflush();
        $finish;
    end
endmodule
