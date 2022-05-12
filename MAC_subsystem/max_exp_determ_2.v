module max_exp_determ_2(input  [FP16_exp_width:0] i_wire2_1,
					    input  [FP16_exp_width:0] i_wire2_2,
					    input  [FP16_exp_width:0] i_exp9,
					    output [FP16_exp_width:0] o_max_exp,
					    output [50:0]             number		);
parameter FP16_exp_width = 5;

// 32b*32b float multiplier

//parameter sig_width = 5;
//parameter exp_width = 8;
//parameter ieee_compliance = 1;
//parameter grp_size = 3;
//
//parameter grp_width_num = 6;

wire [50:0] numbers [0:3];

wire [6-1:0] wire3_1;

// assign wire3_1 = (wire2_1>wire2_2) ? wire2_1 : wire2_2;

// assign max_exp = (wire3_1>exp9_tmp) ?wire3_1 : exp9_tmp;

wire [1:0] eq, gr;
COM6 com3(eq[0], gr[0], i_wire2_1, i_wire2_2, numbers[0]);
MX#(6) mux11(wire3_1, i_wire2_2, i_wire2_1, gr[0], numbers[1]);
COM6 com4(eq[1], gr[1], wire3_1, i_exp9, numbers[2]);
MX#(6) mux12(o_max_exp, i_exp9, wire3_1, gr[1], numbers[3]);

reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<4; j=j+1) begin 
		sum = sum + numbers[j];
	end
end

assign number = sum;

endmodule
