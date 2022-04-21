module align_CG2_NOclkGating(
           input  [ 4-1:0] denorm_pp,
           input  [ 6-1:0] exp,
           input  [ 6-1:0] max_exp,
           output [15-1:0] align_pp
       );


// Exponential Difference
// partial products will be aligned to the max_exp
wire [6-1:0] exp_diff = max_exp - exp;


// denorm_pp
// | 3 |  2 | 1 | 0 |
// | S | ld .       |
wire pp_sign = denorm_pp[3];


// denorm_pp_with_leading_one
// |  2 | 1 | 0 |
// | ld .       |
wire [3-1:0] denorm_pp_with_leading_one = denorm_pp[2:0];


// shifted_unsign_pp
//               exp_diff = 11    ----->           |  2 | 1 | 0 |
//                                                 | ld .       |
// | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |    .                                        G    R   S     |
reg [14-1:0] shifted_unsign_pp;
always@(*) begin
    case(exp_diff)
        6'd0 : shifted_unsign_pp = {       denorm_pp_with_leading_one, 11'd0}; // shifted_unsign_pp1 has one more bit for the signed bit.
        6'd1 : shifted_unsign_pp = { 1'd0, denorm_pp_with_leading_one, 10'd0}; // discard the LSB.
        6'd2 : shifted_unsign_pp = { 2'd0, denorm_pp_with_leading_one,  9'd0}; // discard the LSB.
        6'd3 : shifted_unsign_pp = { 3'd0, denorm_pp_with_leading_one,  8'd0}; // discard the LSB.
        6'd4 : shifted_unsign_pp = { 4'd0, denorm_pp_with_leading_one,  7'd0}; // discard the LSB.
        6'd5 : shifted_unsign_pp = { 5'd0, denorm_pp_with_leading_one,  6'd0}; // discard the LSB.
        6'd6 : shifted_unsign_pp = { 6'd0, denorm_pp_with_leading_one,  5'd0}; // discard the LSB.
        6'd7 : shifted_unsign_pp = { 7'd0, denorm_pp_with_leading_one,  4'd0}; // discard the LSB.
        6'd8 : shifted_unsign_pp = { 8'd0, denorm_pp_with_leading_one,  3'd0}; // discard the LSB.
        6'd9 : shifted_unsign_pp = { 9'd0, denorm_pp_with_leading_one,  2'd0}; // discard the LSB.
        6'd10: shifted_unsign_pp = {10'd0, denorm_pp_with_leading_one,  1'd0}; // discard the LSB.
        6'd11: shifted_unsign_pp = {11'd0, denorm_pp_with_leading_one       }; // discard the LSB.
        default: shifted_unsign_pp = 14'd0;
    endcase
end
// wire [14-1:0] tmp;
// assign tmp = {denorm_pp_with_leading_one, 11'd0};
// wire [14-1:0] shifted_unsign_pp;
// assign shifted_unsign_pp = (exp_diff > 13) ? 14'd0: tmp>>exp_diff;

/* ----------------------------- Sign Extension ----------------------------- */
// align_pp
//                    exp_diff = 11    ----->           |  2 | 1 | 0 |
//                                                      | ld .       |
// | 14 | 13 | 12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 |  2 | 1 | 0 |
// |  S |    .                                        G    R   S     |
assign align_pp = (pp_sign) ? ~{1'b0, shifted_unsign_pp} + 1'b1 : {1'b0, shifted_unsign_pp};


endmodule
