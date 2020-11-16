//`timescale 1ns

module tb_fir ();

	wire CLK_i;
	wire RST_n_i;
	wire [7:0] DIN_i;
	wire VIN_i;
	wire [7:0] B0_i;
	wire [7:0] A1_i;
	wire [7:0] DOUT_i;
	wire VOUT_i;
	wire END_SIM_i;

	clk_gen CG(
		.END_SIM(END_SIM_i),
		.CLK(CLK_i),
		.RST_n(RST_n_i));

	data_maker SM(
		.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VOUT(VIN_i),
		.DOUT(DIN_i),
		.B0(B0_i),
		.A1(A1_i),
		.END_SIM(END_SIM_i));

	filter UUT(
		.clk(CLK_i),
		.rst(RST_n_i),
		.vin(VIN_i),
		.Din(DIN_i),
		.b0(B0_i),
		.a1(A1_i),
		.vout(VOUT_i),
		.Dout(DOUT_i));

	data_sink DS(
		.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));

endmodule

		   
