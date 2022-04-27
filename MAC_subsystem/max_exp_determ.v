
module max_exp_determ(skip,
                      exp1, exp2, exp3, exp4, exp5, exp6, exp7, exp8, exp9,
                      max_exp, number);

parameter FP16_exp_width = 5;

// 32b*32b float multiplier

//parameter sig_width = 5;
//parameter exp_width = 8;
//parameter ieee_compliance = 1;
//parameter grp_size = 3;
//
//parameter grp_width_num = 6;

input  [9-1:0] skip;
input  [FP16_exp_width:0] exp1, exp2, exp3, exp4, exp5, exp6, exp7, exp8, exp9;  // neuron output
output [FP16_exp_width:0] max_exp;  // W
output [50:0] number;

wire [50:0] numbers [0:28];

wire [FP16_exp_width:0] exp1_tmp;
wire [FP16_exp_width:0] exp2_tmp;
wire [FP16_exp_width:0] exp3_tmp;
wire [FP16_exp_width:0] exp4_tmp;
wire [FP16_exp_width:0] exp5_tmp;
wire [FP16_exp_width:0] exp6_tmp;
wire [FP16_exp_width:0] exp7_tmp;
wire [FP16_exp_width:0] exp8_tmp;
wire [FP16_exp_width:0] exp9_tmp;

wire [FP16_exp_width:0] wire1_1;
wire [FP16_exp_width:0] wire1_2;
wire [FP16_exp_width:0] wire1_3;
wire [FP16_exp_width:0] wire1_4;
wire [FP16_exp_width:0] wire2_1;
wire [FP16_exp_width:0] wire2_2;
wire [FP16_exp_width:0] wire3_1;

assign exp1_tmp = (skip[8]==1) ? 6'd0 : exp1;
assign exp2_tmp = (skip[7]==1) ? 6'd0 : exp2;
assign exp3_tmp = (skip[6]==1) ? 6'd0 : exp3;
assign exp4_tmp = (skip[5]==1) ? 6'd0 : exp4;
assign exp5_tmp = (skip[4]==1) ? 6'd0 : exp5;
assign exp6_tmp = (skip[3]==1) ? 6'd0 : exp6;
assign exp7_tmp = (skip[2]==1) ? 6'd0 : exp7;
assign exp8_tmp = (skip[1]==1) ? 6'd0 : exp8;
assign exp9_tmp = (skip[0]==1) ? 6'd0 : exp9;
// MX#(6) mx0(exp1_tmp, exp1, 6'd0, skip[8], numbers[0]);
// MX#(6) mx1(exp2_tmp, exp2, 6'd0, skip[7], numbers[1]);
// MX#(6) mx2(exp3_tmp, exp3, 6'd0, skip[6], numbers[2]);
// MX#(6) mx3(exp4_tmp, exp4, 6'd0, skip[5], numbers[3]);
// MX#(6) mx4(exp5_tmp, exp5, 6'd0, skip[4], numbers[4]);
// MX#(6) mx5(exp6_tmp, exp6, 6'd0, skip[3], numbers[5]);
// MX#(6) mx6(exp7_tmp, exp7, 6'd0, skip[2], numbers[6]);
// MX#(6) mx7(exp8_tmp, exp8, 6'd0, skip[1], numbers[7]);
// MX#(6) mx8(exp9_tmp, exp9, 6'd0, skip[0], numbers[8]);

assign wire1_1 = (exp1_tmp>exp2_tmp) ? exp1_tmp : exp2_tmp;
assign wire1_2 = (exp3_tmp>exp4_tmp) ? exp3_tmp : exp4_tmp;
assign wire1_3 = (exp5_tmp>exp6_tmp) ? exp5_tmp : exp6_tmp;
assign wire1_4 = (exp7_tmp>exp8_tmp) ? exp7_tmp : exp8_tmp;
// wire exp21_1_eq, exp43_1_eq, exp65_1_eq, exp87_1_eq;
// wire exp21_2_eq, exp43_2_eq, exp65_2_eq, exp87_2_eq;
// wire exp21_1_ge, exp43_1_ge, exp65_1_ge, exp87_1_ge;
// wire exp21_2_ge, exp43_2_ge, exp65_2_ge, exp87_2_ge;
// COM com21_1(.equivalent(exp21_1_eq), .greater(exp21_1_g), .A(exp1_tmp[3:0]), .B(exp2_tmp[3:0]), .number(numbers[9]));
// COM com43_1(.equivalent(exp43_1_eq), .greater(exp43_1_g), .A(exp3_tmp[3:0]), .B(exp4_tmp[3:0]), .number(numbers[10]));
// COM com65_1(.equivalent(exp65_1_eq), .greater(exp65_1_g), .A(exp5_tmp[3:0]), .B(exp6_tmp[3:0]), .number(numbers[11]));
// COM com87_1(.equivalent(exp87_1_eq), .greater(exp87_1_g), .A(exp7_tmp[3:0]), .B(exp8_tmp[3:0]), .number(numbers[12]));

// // assign exp21_2_g = (exp1_tmp[5] && ~exp2_tmp[5]) || ((exp1_tmp[5] == exp2_tmp[5]) && (exp1_tmp[4] && ~exp2_tmp[4]));

// // COM com21_2(.equivalent(exp21_2_eq), .greaterEqual(exp21_2_ge), .A({exp1_tmp[5], exp1_tmp[5], exp1_tmp[5:4]}), .B({exp2_tmp[5], exp2_tmp[5], exp2_tmp[5:4]}), .number(numbers[13]));
// // COM com43_2(.equivalent(exp43_2_eq), .greaterEqual(exp43_2_ge), .A({exp3_tmp[5], exp3_tmp[5], exp3_tmp[5:4]}), .B({exp4_tmp[5], exp4_tmp[5], exp4_tmp[5:4]}), .number(numbers[14]));
// // COM com65_2(.equivalent(exp65_2_eq), .greaterEqual(exp65_2_ge), .A({exp5_tmp[5], exp5_tmp[5], exp5_tmp[5:4]}), .B({exp6_tmp[5], exp6_tmp[5], exp6_tmp[5:4]}), .number(numbers[15]));
// // COM com87_2(.equivalent(exp87_2_eq), .greaterEqual(exp87_2_ge), .A({exp7_tmp[5], exp7_tmp[5], exp7_tmp[5:4]}), .B({exp8_tmp[5], exp8_tmp[5], exp8_tmp[5:4]}), .number(numbers[16]));
// // assign exp1ge2 = exp21_2_g || (exp21_2_eq && exp21_1_ge);
// wire exp1ge2, exp3ge4, exp5ge6, exp7ge8;
// wire exp1ge2_2, exp3ge4_2, exp5ge6_2, exp7ge8_2;
// AN2 an1ge2_2(.Z(exp1ge2_2), .A(exp21_2_eq), .B(exp21_1_ge), .number(numbers[17]));
// AN2 an3ge4_2(.Z(exp3ge4_2), .A(exp43_2_eq), .B(exp43_1_ge), .number(numbers[18]));
// AN2 an5ge6_2(.Z(exp5ge6_2), .A(exp65_2_eq), .B(exp65_1_ge), .number(numbers[19]));
// AN2 an7ge8_2(.Z(exp7ge8_2), .A(exp87_2_eq), .B(exp87_1_ge), .number(numbers[20]));
// OR2 or1ge2(.Z(exp1ge2), .A(exp21_2_ge), .B(exp1ge2_2), .number(numbers[21]));
// OR2 or3ge4(.Z(exp3ge4), .A(exp43_2_ge), .B(exp3ge4_2), .number(numbers[22]));
// OR2 or5ge6(.Z(exp5ge6), .A(exp65_2_ge), .B(exp5ge6_2), .number(numbers[23]));
// OR2 or7ge8(.Z(exp7ge8), .A(exp87_2_ge), .B(exp7ge8_2), .number(numbers[24]));
// MX#(6) mux21(.o_z(wire1_1), .i_a(exp2_tmp), .i_b(exp1_tmp), .i_ctrl(exp1ge2), .number(numbers[25]));
// MX#(6) mux43(.o_z(wire1_2), .i_a(exp4_tmp), .i_b(exp3_tmp), .i_ctrl(exp3ge4), .number(numbers[26]));
// MX#(6) mux65(.o_z(wire1_3), .i_a(exp6_tmp), .i_b(exp5_tmp), .i_ctrl(exp5ge6), .number(numbers[27]));
// MX#(6) mux87(.o_z(wire1_4), .i_a(exp8_tmp), .i_b(exp7_tmp), .i_ctrl(exp7ge8), .number(numbers[28]));

assign wire2_1 = (wire1_1>wire1_2) ? wire1_1 : wire1_2;
assign wire2_2 = (wire1_3>wire1_4) ? wire1_3 : wire1_4;

assign wire3_1 = (wire2_1>wire2_2) ? wire2_1 : wire2_2;

assign max_exp = (wire3_1>exp9_tmp) ?wire3_1 : exp9_tmp;

assign number = 0;

endmodule
