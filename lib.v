`timescale 1ns/1ps

module AN3(Z,A,B,C,number);
      output Z;
       input A,B,C;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd8;



       // netlist
       and g1(Z,A,B,C);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.275;
           specparam Tp_B_Z = 0.275;
           specparam Tp_C_Z = 0.275;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
       endspecify
	   
endmodule
module AN4(Z,A,B,C,D,number);
      output Z;
       input A,B,C,D;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd10;
       // netlist
       and g1(Z,A,B,C,D);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.371;
           specparam Tp_B_Z = 0.371;
           specparam Tp_C_Z = 0.371;
           specparam Tp_D_Z = 0.371;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
           ( D *> Z ) = ( Tp_D_Z );
       endspecify
endmodule

module AN2(Z,A,B,number);
            output Z;
       input A,B;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd6;
       // netlist
       and g1(Z,A,B);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.225;
           specparam Tp_B_Z = 0.225;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
       endspecify
endmodule
module DRIVER(Z,A,number);
            output Z;
       input A;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd4;
       // netlist
       buf g1(Z,A);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.174;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
       endspecify
endmodule


module DRIVER2(Z,A,number);
          output Z;
       input A;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd4;
       // netlist
       buf g1(Z,A);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.178;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
       endspecify
endmodule

module EN(Z,A,B,number);
           output Z;
       input A,B;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd8;
       // netlist
       xnor g1(Z,A,B);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 1.10;
           specparam Tp_B_Z = 0.98;


           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );

       endspecify
endmodule

module EN3(Z,A,B,C,number);
           output Z;
       input A,B,C;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd14;
       // netlist
       xnor g1(Z,A,B,C);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 1.10;
           specparam Tp_B_Z = 0.98;
           specparam Tp_C_Z = 0.75;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
       endspecify
endmodule


module EO(Z,A,B,number);
         output Z;
       input A,B;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd8;	   
       xor u0(Z,A,B);
       // specify block
specify
specparam Tp_A_Z=0.343;
specparam Tp_B_Z=0.308;
( A *> Z ) = ( Tp_A_Z,Tp_A_Z );
( B *> Z ) = ( Tp_B_Z,Tp_B_Z );
endspecify
endmodule


module EO3(Z,A,B,C,number);
           output Z;
       input A,B,C;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd14;	 
       // netlist
       xor g1(Z,A,B,C);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.82;
           specparam Tp_B_Z = 0.78;
           specparam Tp_C_Z = 0.61;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
       endspecify
endmodule

module FD1(Q,D,CLK,RESET,number);
           output Q;
       input D,CLK,RESET;
       reg Q,realD,realRESET;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd27;	 
       always @D
       begin
         realD=1'bx;
         #0.581 realD=D;
       end

       always @(negedge RESET)
       begin
         realRESET=0;
         #0.248 Q =1'b0;
       end

       always @(posedge RESET)
        #0.176 realRESET=1;
      always @(negedge CLK) Q =#0.441 (realD&realRESET);
endmodule

module FD2(Q,D,CLK,RESET,number);
           output Q;
       input D,CLK,RESET;
       reg Q,realD,realRESET;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd27;	 
       always @D
       begin
         realD=1'bx;
         #0.581 realD=D;
       end

       always @(negedge RESET)
       begin
         realRESET=0;
         #0.248 Q =1'b0;
       end

       always @(posedge RESET)
        #0.176 realRESET=1;
      always @(posedge CLK) Q =#0.441 (realD&realRESET);
endmodule

module IV(Z,A,number);
          output Z;
       input A;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd2;	 
       // netlist
       not g1(Z,A);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.127;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
       endspecify
endmodule

module MUX21H(Z,A,B,CTRL,number);
            output Z;
       input A,B,CTRL;
       wire w;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd12;	 
       // netlist
	assign w=(CTRL)?B:A;
	buf g1(Z,w);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.316;
           specparam Tp_B_Z=0.337;
           specparam Tp_CTRL_Z = 0.347;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( CTRL *> Z ) = ( Tp_CTRL_Z );
       endspecify
endmodule

module ND2(Z,A,B,number);
         output Z;
       input A,B;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd4;	 
       // netlist
       nand g1(Z,A,B);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.176;
           specparam Tp_B_Z = 0.176;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
       endspecify
endmodule

module ND3(Z,A,B,C,number);
       output Z;
       input A,B,C;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd6;	 
       // netlist
       nand g1(Z,A,B,C);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.226;
           specparam Tp_B_Z = 0.226;
           specparam Tp_C_Z = 0.226;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
       endspecify
endmodule

module ND4(Z,A,B,C,D,number);
       output Z;
       input A,B,C,D;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd8;	 
       // netlist
       nand g1(Z,A,B,C,D);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.296;
           specparam Tp_B_Z = 0.296;
           specparam Tp_C_Z = 0.296;
           specparam Tp_D_Z = 0.296;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
           ( D *> Z ) = ( Tp_D_Z );
       endspecify
endmodule

module ND5(Z,A,B,C,D,E,number);
       output Z;
       input A,B,C,D,E;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd10;   
       // netlist
       nand g1(Z,A,B,C,D,E);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.386;
           specparam Tp_B_Z = 0.386;
           specparam Tp_C_Z = 0.386;
           specparam Tp_D_Z = 0.386;
           specparam Tp_E_Z = 0.386;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
           ( D *> Z ) = ( Tp_D_Z );
           ( E *> Z ) = ( Tp_E_Z );
       endspecify
endmodule

module NR2(Z,A,B,number);
        output Z;
       input A,B;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd4;	 
       // netlist
       nor g1(Z,A,B);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.227;
           specparam Tp_B_Z = 0.227;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
       endspecify
endmodule

module NR3(Z,A,B,C,number);
       output Z;
       input A,B,C;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd6;	 
       // netlist
       nor g1(Z,A,B,C);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.349;
           specparam Tp_B_Z = 0.349;
           specparam Tp_C_Z = 0.349;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
       endspecify
endmodule

module NR4(Z,A,B,C,D,number);
      output Z;
       input A,B,C,D;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd8;	 
       // netlist
       nor g1(Z,A,B,C,D);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.345;
           specparam Tp_B_Z = 0.345;
           specparam Tp_C_Z = 0.345;
           specparam Tp_D_Z = 0.345;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
           ( D *> Z ) = ( Tp_D_Z );
       endspecify
endmodule

module OR2(Z,A,B,number);
       output Z;
       input A,B;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd6;	 
       // netlist
       or g1(Z,A,B);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.297;
           specparam Tp_B_Z = 0.300;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
       endspecify
endmodule

module OR3(Z,A,B,C,number);
       output Z;
       input A,B,C;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd8;	 
       // netlist
       or g1(Z,A,B,C);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.430;
           specparam Tp_B_Z = 0.430;
           specparam Tp_C_Z = 0.429;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
       endspecify
endmodule

module OR4(Z,A,B,C,D,number);
         output Z;
       input A,B,C,D;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd10;	 
       // netlist
       or g1(Z,A,B,C,D);

       // specify block
       specify

           // delay parameters

           specparam Tp_A_Z = 0.544;
           specparam Tp_B_Z = 0.544;
           specparam Tp_C_Z = 0.540;
           specparam Tp_D_Z = 0.544;

           // path delay
           ( A *> Z ) = ( Tp_A_Z );
           ( B *> Z ) = ( Tp_B_Z );
           ( C *> Z ) = ( Tp_C_Z );
           ( D *> Z ) = ( Tp_D_Z );
       endspecify
endmodule

module HA1(S,O,A,B,number);
         output S,O;
       input A,B;
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd14;  
       // netlist
       xor g1(S,A,B);
       and g2(O,A,B);


       // specify block
       specify

           // delay parameters

           specparam Tp_A_S = 0.39;
           specparam Tp_B_S = 0.37;

           specparam Tp_A_O = 0.18;
           specparam Tp_B_O = 0.18;

           // path delay
           ( A *> S ) = ( Tp_A_S );
           ( B *> S ) = ( Tp_B_S );
           ( A *> O ) = ( Tp_A_O );
           ( B *> O ) = ( Tp_B_O );
       endspecify
endmodule

module FA1(S,CO,A,B,CI,number);
       output S,CO;
       input A,B,CI;

       wire x = (A&B)||(B&CI)||(A&CI);
       // netlist
       xor g1(S,A,B,CI);
       buf g2(CO,x);
 parameter size = 10'd50; 
  output [size:0] number;
  wire  [size:0] number;
  assign number=11'd26;  
       // specify block
       specify

           // delay parameters

           specparam Tp_A_S = 0.61;
           specparam Tp_B_S = 0.54;
           specparam Tp_C_S = 0.43;

           specparam Tp_A_O = 0.55;
           specparam Tp_B_O = 0.55;
           specparam Tp_C_O = 0.54;

           // path delay
           ( A *> S ) = ( Tp_A_S );
           ( B *> S ) = ( Tp_B_S );
           ( CI *> S ) = ( Tp_C_S );
           ( A *> CO ) = ( Tp_A_O );
           ( B *> CO ) = ( Tp_B_O );
           ( CI *> CO ) = ( Tp_C_O );
       endspecify
endmodule

//multi bits and
module ADD#(
    parameter BW = 2
)(
    input [BW-1:0] i_a,
    input [BW-1:0] i_b,
    output [BW-1:0] o_s,
    output o_c,
    output [50:0] number
);

    wire [BW-1:0] c;
    wire [50:0] numbers [0:BW-1];

    HA1 g_0(o_s[0], c[0], i_a[0], i_b[0], numbers[0]);

    genvar i;
    generate
        for (i=1; i<BW; i=i+1) begin
            FA1 g_i(o_s[i], c[i], i_a[i], i_b[i], c[i-1], numbers[i]);
        end
    endgenerate

    assign o_c = c[BW-1];

    reg [50:0] num;
    integer j;
    always @(*) begin
        num = 0;
        for (j=0; j<BW; j=j+1) begin 
            num = num + numbers[j];
        end
    end

    assign number = num;

endmodule

//multi bits inv
module INV#(
    parameter BW = 2
)(
    input [BW-1:0] i_a,
    output [BW-1:0] o_z,
    output [50:0] number
);
    wire [50:0] numbers[BW-1:0];
    genvar i;
    generate
        for (i=0; i<BW; i=i+1) begin
            IV g_i(o_z[i], i_a[i], numbers[i]);
        end
    endgenerate

    reg [50:0] num;
    integer j;
    always @(*) begin
        num = 0;
        for (j=0; j<BW; j=j+1) begin 
            num = num + numbers[j];
        end
    end

    assign number = num;

endmodule

module MX#(
    parameter BW = 2
)(
    output [BW-1:0] o_z,
    input [BW-1:0] i_a,
    input [BW-1:0] i_b,
    input i_ctrl,
    output [50:0] number
);

wire [50:0] numbers [0:BW-1];

genvar i;
generate
    for (i=0; i<BW; i=i+1) begin
        MUX21H mux(o_z[i], i_a[i], i_b[i], i_ctrl, numbers[i]);
    end
endgenerate

reg [50:0] sum;
integer j;
always @(*) begin
    sum = 0;
    for (j=0; j<BW; j=j+1) begin 
        sum = sum + numbers[j];
    end
end

assign number = sum;

endmodule

// module LUT_ONEHOT#(
//     parameter OPTIONS = 2, BITS = 2
// )(
//     input [OPTIONS-1:0] oneHot,
//     input [BITS-1:0] options [0:OPTIONS-1],
// 	output [BITS-1:0] o_data,
// 	output [50:0] number
// );

// wire [50:0] numbers [0:OPTIONS-1][0:BITS-1];

// wire [BITS-1:0] and_result [0:OPTIONS-1];
// genvar i, j;
// generate
//     for(i = 0; i<OPTIONS; i=i+1) begin
//         for(j = 0; j<BITS; j=j+1) begin
//             AN2 an1(and_result[i][j], oneHot[i], options[i][j], numbers[i][j]);
//         end
//     end
// endgenerate

// wire [50:0] numbers2[0:BITS-1];

// generate
//     for(i=0; i<BITS; i=i+1) begin
//         OR#(OPTIONS) or1(o_data[i], and_result[0:OPTIONS-1][i], numbers2[i]);        
//     end
// endgenerate

// reg [50:0] sum;
// integer k,l;
// always @(*) begin
// 	sum = 0;
// 	for (k=0; k<OPTIONS; k=k+1) begin
//         for (l=0; l<BITS; l=l+1) begin 
// 		    sum = sum + numbers[k][l];
//         end
// 	end
//     for (l=0; l<BITS; l=l+1) begin 
//         sum = sum + numbers2[l];
//     end
// end

// assign number = sum;

// endmodule


//multi inputs or
module OR#(
	parameter BW = 2
)(
	output [BW-1:0] o_z,
	input i_a [0:BW-1],
	output [50:0] number
);

wire [50:0] numbers [0:BW-1];
parameter l = BW%2 ? (BW+1)/2 : BW/2;

wire or_result[0:l-1];
wire [2*l-1:0] l2 = BW%2 ? {i_a, 1'b0} : i_a;
wire [50:0] numbers2;
genvar i;
generate
    if(BW == 1) begin
        assign o_z = i_a;
        assign numbers2 = 0;
    end
    else begin
    	for (i=0; i<l; i=i+1) begin
    		OR2 or1(or_result[i], l2[2*i], l2[2*i+1], numbers[i]);
    	end
        OR#(l) or2(o_z, or_result, numbers2);
    end
endgenerate

reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<l-1; j=j+1) begin 
		sum = sum + numbers[j];
	end
end

assign number = (BW%2) ? sum + numbers2 : sum + numbers[l-1] + numbers2;

endmodule


//HS1
module HS1 (
    output        o_z,
    output        o_b,
    input         i_x,
    input         i_y,
    output [50:0] number
);

wire [50:0] num_0, num_1, num_2;
assign number = num_0 + num_1 + num_2;

wire n_1;
EO  g_1(o_z, i_x, i_y, num_0);
IV  g_2(n_1, i_y, num_1);
NR2 g_3(o_b, n_1, i_x, num_2);
endmodule

//borrow-ripple original
//FS1
// module FS1 (
//  output        o_z,
//  output        o_b,
//  input         i_x,
//  input         i_y,
//  input         i_b,
//  output [50:0] number
// );

// wire [50:0] num_0, num_1, num_2, num_3, num_4, num_5;
// assign number = num_0 + num_1 + num_2 + num_3 + num_4 + num_5;

// wire n_1, n_2, n_3, n_4;
// EO3 g_1(o_z, i_x, i_y, i_b, num_0);
// IV  g_2(n_1, i_x, num_1);
// ND2 g_3(n_2, n_1, i_y, num_2);
// ND2 g_4(n_3, n_1, i_b, num_3);
// ND2 g_5(n_4, i_b, i_y, num_4);
// ND3 g_6(o_b, n_2, n_3, n_4, num_5);
// endmodule

//borrow-ripple modified
module FS1 (
    output        o_z,
    output        o_b,
    input         i_x,
    input         i_y,
    input         i_b,
    output [50:0] number
);

wire [50:0] num_0, num_1, num_2, num_3, num_4, num_5, num_6;
assign number = num_0 + num_1 + num_2 + num_3 + num_4 + num_5 + num_6;

wire n_0, n_1, n_2, n_3, n_4;
EO  g_0(n_0, i_x, i_y, num_0);
EO  g_1(o_z, n_0, i_b, num_1);
IV  g_2(n_1, i_x, num_2);
ND2 g_3(n_2, n_1, i_y, num_3);
IV  g_4(n_3, n_0, num_4);
ND2 g_5(n_4, i_b, n_3, num_5);
ND2 g_6(o_b, n_2, n_4, num_6);
endmodule

//FS2
// module FS2 (
//     output [1:0]  o_z,
//     output        o_b,
//     input  [1:0]  i_x,
//     input  [1:0]  i_y,
//     output [50:0] number
// );

// wire [50:0] num_0, num_1;
// assign number = num_0 + num_1;

// wire n_1;

// HS1 g_1(o_z[0], n_1, i_x[0], i_y[0], num_0);
// FS1 g_2(o_z[1], o_b, i_x[1], i_y[1], n_1, num_1);
// endmodule

module SUB#(
    parameter BW = 2
)(
    input [BW-1:0] i_a,
    input [BW-1:0] i_b,
    output [BW-1:0] o_d,
    output o_b,
    output [50:0] number
);

    wire [BW-1:0] b;
    wire [50:0] numbers [0:BW-1];

    HS1 g_0(o_d[0], b[0], i_a[0], i_b[0], numbers[0]);

    genvar i;
    generate
        for (i=1; i<BW; i=i+1) begin
            FS1 g_i(o_d[i], b[i], i_a[i], i_b[i], b[i-1], numbers[i]);
        end
    endgenerate

    assign o_b = b[BW-1];

    reg [50:0] num;
    integer j;
    always @(*) begin
        num = 0;
        for (j=0; j<BW; j=j+1) begin 
            num = num + numbers[j];
        end
    end

    assign number = num;

endmodule

//Equivalent gate
module EQ(equivalent, A, B, number);
    input  [4-1:0] A, B;
    output       equivalent;
    output [50:0] number;

    wire   [50:0] numbers[0:4];

    //equivalent = 1 iff A is equivalent to B
    wire   [3:0] n;
    EO g1(n[3], A[3], B[3], numbers[0]);
    EO g2(n[2], A[2], B[2], numbers[1]);
    EO g3(n[1], A[1], B[1], numbers[2]);
    EO g4(n[0], A[0], B[0], numbers[3]);
    NR4 g5(equivalent, n[3], n[2], n[1], n[0], numbers[4]);

    reg [50:0] sum;
    integer j;
    always @(*) begin
        sum = 0;
        for (j=0; j<5; j=j+1) begin 
            sum = sum + numbers[j];
        end
    end

    assign number = sum;

endmodule

//Comparator 4 bits
module COM(equivalent, greater, A, B, number);
    input  [4-1:0] A, B;
    output       equivalent, greater;
    output [50:0] number;

    wire   [50:0] numbers[0:17];

    //equivalent = 1 iff A is equivalent to B
    wire   [3:0] n;
    EO g1(n[3], A[3], B[3], numbers[0]);
    EO g2(n[2], A[2], B[2], numbers[1]);
    EO g3(n[1], A[1], B[1], numbers[2]);
    EO g4(n[0], A[0], B[0], numbers[3]);
    NR4 g5(equivalent, n[3], n[2], n[1], n[0], numbers[4]);

    //greater = 1 iff A is greater than B
    wire   [3:0] invB;
    wire   [3:0] m;
    wire   [3:0] invN;
    IV g6(invB[3], B[3], numbers[5]);
    IV g18(invB[2], B[2], numbers[6]);
    IV g7(invB[1], B[1], numbers[7]);
    IV g8(invB[0], B[0], numbers[8]);
    IV g17(invN[3], n[3], numbers[9]);
    IV g9(invN[2], n[2], numbers[10]);
    IV g10(invN[1], n[1], numbers[11]);
    IV g11(invN[0], n[0], numbers[12]);
    ND2 g12(m[0], A[3], invB[3], numbers[13]);
    ND3 g13(m[1], invN[3], A[2], invB[2], numbers[14]);
    ND4 g14(m[2], invN[3], invN[2], A[1], invB[1], numbers[15]);
    ND5 g15(m[3], invN[3], invN[2], invN[1], A[0], invB[0], numbers[16]);
    ND4 g16(greater, m[3], m[2], m[1], m[0], numbers[17]);

    reg [50:0] sum;
    integer j;
    always @(*) begin
        sum = 0;
        for (j=0; j<18; j=j+1) begin 
            sum = sum + numbers[j];
        end
    end

    assign number = sum;

endmodule

module COM6(equivalent, greater, A, B, number);
    input  [6-1:0] A, B;
    output       equivalent, greater;
    output [50:0] number;

    wire   [50:0] numbers[0:11];
 
    wire A54_g_B54;

    // assign A54_g_B54 = (A[5] && ~B[5]) || ((A[5] == B[5]) && (A[4] && ~B[4]));
    wire A51_B50, A5_eq_B5, A41_B40, A4_eq_B4;
    wire inv_B5, inv_B4;
    wire tmp;
    IV invB5(inv_B5, B[5], numbers[0]);
    AN2 A5_and_invB5(A51_B50, A[5], inv_B5, numbers[1]);
    EN A5_xnor_B5(A5_eq_B5, A[5], B[5], numbers[2]);
    IV invB4(inv_B4, B[4], numbers[4]);
    AN2 A4_and_invB4(A41_B40, A[4], inv_B4, numbers[5]);
    AN2 an1(tmp, A5_eq_B5, A41_B40, numbers[6]);
    OR2 or1(A54_g_B54, A51_B50, tmp, numbers[7]);

    
    EN A4_xnor_B4(A4_eq_B4, A[4], B[4], numbers[3]);
    wire eq_last4, g_last4;
    COM cmp(eq_last4, g_last4, A[3:0], B[3:0], numbers[8]);
    AN3 o_eq(equivalent, A5_eq_B5, A4_eq_B4, eq_last4, numbers[9]);
    // assign greater = A54_g_B54 || (A5_eq_B5 && A4_eq_B4 && g_last4);
    wire tmp2;
    AN3 an2(tmp2, A5_eq_B5, A4_eq_B4, g_last4, numbers[10]);
    OR2 or2(greater, A54_g_B54, tmp2, numbers[11]);

    reg [50:0] sum;
    integer j;
    always @(*) begin
        sum = 0;
        for (j=0; j<12; j=j+1) begin 
            sum = sum + numbers[j];
        end
    end

    assign number = sum;

endmodule

module EQ6(equivalent, A, B, number);
    input  [6-1:0] A, B;
    output       equivalent;
    output [50:0] number;

    wire   [50:0] numbers[0:3];

    wire A5_eq_B5, A4_eq_B4;
    EN A5_xnor_B5(A5_eq_B5, A[5], B[5], numbers[0]);
    EN A4_xnor_B4(A4_eq_B4, A[4], B[4], numbers[1]);

    wire eq_last4, g_last4;
    COM cmp(eq_last4, g_last4, A[3:0], B[3:0], numbers[2]);
    AN3 o_eq(equivalent, A5_eq_B5, A4_eq_B4, eq_last4, numbers[3]);

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