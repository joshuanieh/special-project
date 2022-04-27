
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

wire [50:0] numbers [0:24];

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

// assign exp1_tmp = (skip[8]==1) ? 6'd0 : exp1;
// assign exp2_tmp = (skip[7]==1) ? 6'd0 : exp2;
// assign exp3_tmp = (skip[6]==1) ? 6'd0 : exp3;
// assign exp4_tmp = (skip[5]==1) ? 6'd0 : exp4;
// assign exp5_tmp = (skip[4]==1) ? 6'd0 : exp5;
// assign exp6_tmp = (skip[3]==1) ? 6'd0 : exp6;
// assign exp7_tmp = (skip[2]==1) ? 6'd0 : exp7;
// assign exp8_tmp = (skip[1]==1) ? 6'd0 : exp8;
// assign exp9_tmp = (skip[0]==1) ? 6'd0 : exp9;
MX#(6) mx0(exp1_tmp, exp1, 6'd0, skip[8], numbers[0]);
MX#(6) mx1(exp2_tmp, exp2, 6'd0, skip[7], numbers[1]);
MX#(6) mx2(exp3_tmp, exp3, 6'd0, skip[6], numbers[2]);
MX#(6) mx3(exp4_tmp, exp4, 6'd0, skip[5], numbers[3]);
MX#(6) mx4(exp5_tmp, exp5, 6'd0, skip[4], numbers[4]);
MX#(6) mx5(exp6_tmp, exp6, 6'd0, skip[3], numbers[5]);
MX#(6) mx6(exp7_tmp, exp7, 6'd0, skip[2], numbers[6]);
MX#(6) mx7(exp8_tmp, exp8, 6'd0, skip[1], numbers[7]);
MX#(6) mx8(exp9_tmp, exp9, 6'd0, skip[0], numbers[8]);

// assign wire1_1 = (exp1_tmp>exp2_tmp) ? exp1_tmp : exp2_tmp;
// assign wire1_2 = (exp3_tmp>exp4_tmp) ? exp3_tmp : exp4_tmp;
// assign wire1_3 = (exp5_tmp>exp6_tmp) ? exp5_tmp : exp6_tmp;
// assign wire1_4 = (exp7_tmp>exp8_tmp) ? exp7_tmp : exp8_tmp;

wire eq_21, eq_43, eq_65, eq_87, gr_21, gr_43, gr_65, gr_87;
COM6 com21(eq_21, gr_21, exp1_tmp, exp2_tmp, numbers[9]);
COM6 com43(eq_43, gr_43, exp1_tmp, exp2_tmp, numbers[10]);
COM6 com65(eq_65, gr_65, exp1_tmp, exp2_tmp, numbers[11]);
COM6 com87(eq_87, gr_87, exp1_tmp, exp2_tmp, numbers[12]);

MX#(6) mux21(.o_z(wire1_1), .i_a(exp2_tmp), .i_b(exp1_tmp), .i_ctrl(gr_21), .number(numbers[13]));
MX#(6) mux43(.o_z(wire1_2), .i_a(exp4_tmp), .i_b(exp3_tmp), .i_ctrl(gr_43), .number(numbers[14]));
MX#(6) mux65(.o_z(wire1_3), .i_a(exp6_tmp), .i_b(exp5_tmp), .i_ctrl(gr_65), .number(numbers[15]));
MX#(6) mux87(.o_z(wire1_4), .i_a(exp8_tmp), .i_b(exp7_tmp), .i_ctrl(gr_87), .number(numbers[16]));

// assign wire2_1 = (wire1_1>wire1_2) ? wire1_1 : wire1_2;

// assign wire2_2 = (wire1_3>wire1_4) ? wire1_3 : wire1_4;

// assign wire3_1 = (wire2_1>wire2_2) ? wire2_1 : wire2_2;

// assign max_exp = (wire3_1>exp9_tmp) ?wire3_1 : exp9_tmp;

wire [3:0] eq, gr;
COM6 com1(eq[0], gr[0], wire1_1, wire1_2, numbers[17]);
MX#(6) mux9(wire2_1, wire1_2, wire1_1, gr[0], numbers[18]);
COM6 com2(eq[1], gr[1], wire1_3, wire1_4, numbers[19]);
MX#(6) mux10(wire2_2, wire1_4, wire1_3, gr[1], numbers[20]);
COM6 com3(eq[2], gr[2], wire2_1, wire2_2, numbers[21]);
MX#(6) mux11(wire3_1, wire2_2, wire2_1, gr[2], numbers[22]);
COM6 com4(eq[3], gr[3], wire3_1, exp9_tmp, numbers[23]);
MX#(6) mux12(max_exp, exp9_tmp, wire3_1, gr[3], numbers[24]);

reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<25; j=j+1) begin 
		sum = sum + numbers[j];
	end
end

assign number = sum;

endmodule
