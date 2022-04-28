module exp_Handle_norm(
           input      [11-1:0] norm_sum_with_leading1,
           input      [ 5-1:0] signed_exp_diff,
           input               exp_carry,
           input               sign,
           input      [ 6-1:0] max_exp,
           input      [ 5-1:0] Q_frac,
           output reg [16-1:0] MAC_output,
           output     [50:0]   number
       );

wire [50:0] numbers [0:26];

// wire zero_flag = (norm_sum_with_leading1 == 0) ? 1'b1 : 0;
wire zero_flag, inverted_zero_flag;
OR#(11) or1000(
    .o_z(inverted_zero_flag),
    .i_a(norm_sum_with_leading1),
    .number(numbers[0])
);
IV inv1000(zero_flag, inverted_zero_flag, numbers[1]);

// final_exp = max_exp + signed_exp_diff + exp_carry - 24 + 15
// wire signed [8-1:0] final_exp = $signed({1'd0, max_exp}) + $signed(signed_exp_diff) + 
//                         $signed({1'b0, exp_carry}) - 5'sd9 - $signed({1'b0, Q_frac});
wire [6:0] tmp_s1, tmp_s2;
wire [7:0] tmp_s3;
wire [8:0] tmp_s4;
wire [3:0] tmp_c;
ADD#(7) add1(.i_a({1'b0, max_exp}), .i_b({{2{signed_exp_diff[4]}}, signed_exp_diff}), .o_s(tmp_s1), .o_c(tmp_c[0]), .number(numbers[2]));
SUB#(7) add2(.i_a({6'b0, exp_carry}), .i_b(7'b0001001), .o_d(tmp_s2), .o_b(tmp_c[1]), .number(numbers[3]));
ADD#(8) add3(.i_a({tmp_s1[6], tmp_s1}), .i_b({tmp_s2[6], tmp_s2}), .o_s(tmp_s3), .o_c(tmp_c[2]), .number(numbers[4]));
SUB#(9) add4(.i_a({tmp_s3[7], tmp_s3}), .i_b({4'b0, Q_frac}), .o_d(tmp_s4), .o_b(tmp_c[3]), .number(numbers[5]));
wire signed [7:0] final_exp;
assign final_exp = tmp_s4[7:0];

// wire need_to_operate_in_subnormal = ( final_exp < 8'sd1 ) ? 1'b1 : 0;
wire inv_final_exp_allzero, final_exp_allzero;
OR#(8) or1001(
    .o_z(inv_final_exp_allzero),
    .i_a(final_exp),
    .number(numbers[6])
);
IV inv1001(final_exp_allzero, inv_final_exp_allzero, numbers[7]);
OR2 or6(need_to_operate_in_subnormal, final_exp_allzero, final_exp[7], numbers[8]);

// always @(*) begin
//     if (zero_flag)
//         MAC_output = {sign, 15'd0};
//     else begin
//         if (need_to_operate_in_subnormal) begin
//             case (final_exp)
//                  8'sd0: MAC_output = {sign, 5'd0,       norm_sum_with_leading1[10:1]};
//                 -8'sd1: MAC_output = {sign, 5'd0, 1'd0, norm_sum_with_leading1[10:2]};
//                 -8'sd2: MAC_output = {sign, 5'd0, 2'd0, norm_sum_with_leading1[10:3]};
//                 -8'sd3: MAC_output = {sign, 5'd0, 3'd0, norm_sum_with_leading1[10:4]};
//                 -8'sd4: MAC_output = {sign, 5'd0, 4'd0, norm_sum_with_leading1[10:5]};
//                 -8'sd5: MAC_output = {sign, 5'd0, 5'd0, norm_sum_with_leading1[10:6]};
//                 -8'sd6: MAC_output = {sign, 5'd0, 6'd0, norm_sum_with_leading1[10:7]};
//                 -8'sd7: MAC_output = {sign, 5'd0, 7'd0, norm_sum_with_leading1[10:8]};
//                 -8'sd8: MAC_output = {sign, 5'd0, 8'd0, norm_sum_with_leading1[10:9]};
//                 -8'sd9: MAC_output = {sign, 5'd0, 9'd0, norm_sum_with_leading1[10]  };
//                 default: MAC_output = {sign, 15'd0};
//             endcase
//         end
//         else
//             MAC_output = {sign, final_exp[4:0], norm_sum_with_leading1[9:0]};
//     end
// end
always@(*) begin
    MAC_output = wire_MAC_output;
end

//first stage
wire eq0;
wire [16-1:0] mux01;
EQ8 eq_0(eq0, final_exp, 8'sd0, numbers[11]);
MX#(16) mux_01(mux01, {sign, 5'd0, 1'd0, norm_sum_with_leading1[10:2]}, {sign, 5'd0, norm_sum_with_leading1[10:1]}, eq0, numbers[12]);

wire eq2, g2;
wire [16-1:0] mux23;
COM8 com_2(eq2, g2, final_exp, -8'sd2, numbers[13]);
MX#(16) mux_23(mux23, {sign, 5'd0, 3'd0, norm_sum_with_leading1[10:4]}, {sign, 5'd0, 2'd0, norm_sum_with_leading1[10:3]}, eq2, numbers[14]);

wire eq4, g4;
wire [16-1:0] mux45;
COM8 com_4(eq4, g4, final_exp, -8'sd4, numbers[15]);
MX#(16) mux_45(mux45, {sign, 5'd0, 5'd0, norm_sum_with_leading1[10:6]}, {sign, 5'd0, 4'd0, norm_sum_with_leading1[10:5]}, eq4, numbers[16]);

wire eq6, g6;
wire [16-1:0] mux67;
COM8 com_6(eq6, g6, final_exp, -8'sd6, numbers[17]);
MX#(16) mux_67(mux67, {sign, 5'd0, 7'd0, norm_sum_with_leading1[10:8]}, {sign, 5'd0, 6'd0, norm_sum_with_leading1[10:7]}, eq6, numbers[18]);

wire eq8, g8;
wire [16-1:0] mux89;
COM8 com_8(eq8, g8, final_exp, -8'sd8, numbers[19]);
MX#(16) mux_89(mux89, {sign, 5'd0, 9'd0, norm_sum_with_leading1[10]}, {sign, 5'd0, 8'd0, norm_sum_with_leading1[10:9]}, eq8, numbers[20]);

//second stage
wire [16-1:0] mux0123;
MX#(16) mux_0123(mux0123, mux23, mux01, g2, numbers[21]);

wire [16-1:0] mux4567;
MX#(16) mux_4567(mux4567, mux67, mux45, g6, numbers[22]);

wire eq10, g10;
wire [16-1:0] mux89def;
COM8 com_10(eq_10, g10, final_exp, -8'sd10, numbers[23]);
MX#(16) mux_89def(mux89def, {sign, 15'd0}, mux89, g10, numbers[24]);

//third stage
wire [16-1:0] mux01234567;
MX#(16) mux_01234567(mux01234567, mux4567, mux0123, g4, numbers[25]);

//forth stage
wire [16-1:0] wire_MAC_output;
wire [16-1:0] subnormal_output, not_zero_output;
MX#(16) mux_result(subnormal_output, mux89def, mux01234567, g8, numbers[26]);

MX#(16) mux_o1(.o_z(wire_MAC_output), .i_a(not_zero_output), .i_b({sign, 15'b0}), .i_ctrl(zero_flag), .number(numbers[9]));
MX#(16) mux_o2(.o_z(not_zero_output), .i_a({sign, final_exp[4:0], norm_sum_with_leading1[9:0]}), .i_b(subnormal_output), .i_ctrl(need_to_operate_in_subnormal), .number(numbers[10]));

reg [50:0] num;
integer j;
always @(*) begin
    num = 0;
    for (j=0; j<27; j=j+1) begin 
        num = num + numbers[j];
    end
end

assign number = num;

endmodule
