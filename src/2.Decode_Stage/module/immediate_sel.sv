`timescale 1ns/1ps

import defines::*;

module immediate_sel (
    input imm_sel_e ImmSel_i, // Immediate selection input
    input logic [DATA_WIDTH-1:0] imm_i_i,
    input logic [DATA_WIDTH-1:0] imm_s_i,
    input logic [DATA_WIDTH-1:0] imm_b_i,
    input logic [DATA_WIDTH-1:0] imm_u_i,
    input logic [DATA_WIDTH-1:0] imm_j_i,
    output logic [DATA_WIDTH-1:0] ImmSel_o // Selected immediate output
);

    always_comb begin
        case (ImmSel_i)
            IMM_TYPE_I:   ImmSel_o = imm_i_i; // Load instructions use I-type immediate
            IMM_TYPE_S:   ImmSel_o = imm_s_i; // I-type arithmetic uses I-type immediate
            IMM_TYPE_B:   ImmSel_o = imm_b_i; // Store instructions use S-type immediate
            IMM_TYPE_U:   ImmSel_o = imm_u_i; // AUIPC uses U-type immediate
            IMM_TYPE_J:   ImmSel_o = imm_j_i; // LUI uses U-type immediate
            default:      ImmSel_o = IMM_TYPE_R; // Default case, no immediate used
        endcase
    end
endmodule
