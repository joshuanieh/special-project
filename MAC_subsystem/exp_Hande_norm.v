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

wire [50:0] numbers [0:11];

// wire zero_flag = (norm_sum_with_leading1 == 0) ? 1'b1 : 0;
wire zero_flag, inverted_zero_flag;
wire [2:0] tmp_or;
OR#(11) or1000(
    .o_z(inverted_zero_flag),
    .i_a(norm_sum_with_leading1),
    .number(numbers[0])
);
IV inv1000(zero_flag, inverted_zero_flag, numbers[1]);
// OR4 or1(tmp_or[0], norm_sum_with_leading1[0], norm_sum_with_leading1[1], norm_sum_with_leading1[2], norm_sum_with_leading1[3], numbers[0]);
// OR4 or2(tmp_or[1], norm_sum_with_leading1[4], norm_sum_with_leading1[5], norm_sum_with_leading1[6], norm_sum_with_leading1[7], numbers[1]);
// OR3 or3(tmp_or[2], norm_sum_with_leading1[8], norm_sum_with_leading1[9], norm_sum_with_leading1[10], numbers[2]);
// NR3 nr1(zero_flag, tmp_or[0], tmp_or[1], tmp_or[2], numbers[3]);

// final_exp = max_exp + signed_exp_diff + exp_carry - 24 + 15
// wire signed [8-1:0] final_exp = $signed({1'd0, max_exp}) + $signed(signed_exp_diff) + 
//                         $signed({1'b0, exp_carry}) - 5'sd9 - $signed({1'b0, Q_frac});
wire [6:0] tmp_s1, tmp_s2;
wire [7:0] tmp_s3;
wire [8:0] tmp_s4;
wire [3:0] tmp_c;
ADD#(7) add1(.i_a({1'b0, max_exp}), .i_b({{2{signed_exp_diff[4]}}, signed_exp_diff}), .o_s(tmp_s1), .o_c(tmp_c[0]), .number(numbers[4]));
SUB#(7) add2(.i_a({6'b0, exp_carry}), .i_b(7'b0001001), .o_d(tmp_s2), .o_b(tmp_c[1]), .number(numbers[5]));
ADD#(8) add3(.i_a({tmp_s1[6], tmp_s1}), .i_b({tmp_s2[6], tmp_s2}), .o_s(tmp_s3), .o_c(tmp_c[2]), .number(numbers[6]));
SUB#(9) add4(.i_a({tmp_s3[7], tmp_s3}), .i_b({4'b0, Q_frac}), .o_d(tmp_s4), .o_b(tmp_c[3]), .number(numbers[7]));
wire signed [7:0] final_exp;
assign final_exp = tmp_s4[7:0];

// wire need_to_operate_in_subnormal = ( final_exp < 8'sd1 ) ? 1'b1 : 0;
wire [1:0] tmp_or2;
wire final_exp_allzero;
OR4 or4(tmp_or2[0], final_exp[0], final_exp[1], final_exp[2], final_exp[3], numbers[8]);
OR4 or5(tmp_or2[1], final_exp[4], final_exp[5], final_exp[6], final_exp[7], numbers[9]);
NR2 nr2(final_exp_allzero, tmp_or2[0], tmp_or2[1], numbers[10]);
OR2 or6(need_to_operate_in_subnormal, final_exp_allzero, final_exp[7], numbers[11]);

always @(*) begin
    if (zero_flag)
        MAC_output = {sign, 15'd0};
    else begin
        if (need_to_operate_in_subnormal) begin
            case (final_exp)
                 8'sd0: MAC_output = {sign, 5'd0,       norm_sum_with_leading1[10:1]};
                -8'sd1: MAC_output = {sign, 5'd0, 1'd0, norm_sum_with_leading1[10:2]};
                -8'sd2: MAC_output = {sign, 5'd0, 2'd0, norm_sum_with_leading1[10:3]};
                -8'sd3: MAC_output = {sign, 5'd0, 3'd0, norm_sum_with_leading1[10:4]};
                -8'sd4: MAC_output = {sign, 5'd0, 4'd0, norm_sum_with_leading1[10:5]};
                -8'sd5: MAC_output = {sign, 5'd0, 5'd0, norm_sum_with_leading1[10:6]};
                -8'sd6: MAC_output = {sign, 5'd0, 6'd0, norm_sum_with_leading1[10:7]};
                -8'sd7: MAC_output = {sign, 5'd0, 7'd0, norm_sum_with_leading1[10:8]};
                -8'sd8: MAC_output = {sign, 5'd0, 8'd0, norm_sum_with_leading1[10:9]};
                -8'sd9: MAC_output = {sign, 5'd0, 9'd0, norm_sum_with_leading1[10]  };
                default: MAC_output = {sign, 15'd0};
            endcase
        end
        else
            MAC_output = {sign, final_exp[4:0], norm_sum_with_leading1[9:0]};
    end
end

reg [50:0] num;
integer j;
always @(*) begin
    num = 0;
    for (j=0; j<12; j=j+1) begin 
        num = num + numbers[j];
    end
end

assign number = num;

endmodule
