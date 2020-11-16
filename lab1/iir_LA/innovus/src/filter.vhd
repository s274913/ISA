library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is
	generic(parallelism : integer := 8);
	port(
		clk               : in  std_logic;
		rst               : in  std_logic;
		B0, A1, C, A_sqrd : in  std_logic_vector(parallelism - 1 downto 0);
		Vin               : in  std_logic;
		x                 : in  std_logic_vector(parallelism - 1 downto 0);
		y                 : out std_logic_vector(parallelism - 1 downto 0);
		vout              : out std_logic
	);
end entity filter;

architecture RTL of filter is

	---------------------------------------------------------
	component reg is
		generic(parallelism : integer := 9);
		port(
			clk : in  std_logic;
			rst : in  std_logic;
			D   : in  signed(parallelism - 1 downto 0);
			Q   : out signed(parallelism - 1 downto 0)
		);
	end component reg;

	component reg_en is
		generic(parallelism : integer := 9);
		port(
			clk : in  std_logic;
			rst : in  std_logic;
			D   : in  signed(parallelism - 1 downto 0);
			Q   : out signed(parallelism - 1 downto 0);
			en  : in  std_logic
		);
	end component reg_en;

	component shift is
		generic(levelPipe : integer := 5);
		port(
			clk    : in  std_logic;
			rst    : in  std_logic;
			D      : in  std_logic;
			Q      : out std_logic;
			enable : out std_logic_vector(1 downto 0)
		);
	end component shift;
	----------------------------------------------------------------------

	signal extension                              : signed(0 downto 0);
	signal concatenated                           : signed(8 downto 0);
	signal x_internal                             : signed(parallelism - 1 downto 0);
	signal x_minus_1                              : signed(8 downto 0);
	signal m1_tmp, m2_tmp, m3_tmp, m4_tmp, m5_tmp : signed(16 downto 0);
	signal m1, m2, m3, m4, m5                     : signed(8 downto 0);
	signal s1, s2, s3, s4                         : signed(8 downto 0);
	signal out_reg_2, out_reg_3                   : signed(8 downto 0);
	signal out_reg_4                              : signed(8 downto 0);
	signal out_pipe_1, out_pipe_2, out_pipe_3     : signed(8 downto 0);
	signal out_pipe_4, out_pipe_5                 : signed(8 downto 0);
	signal out_pipe_6, out_pipe_7, out_pipe_13    : signed(8 downto 0);
	signal out_pipe_8, out_pipe_9, out_pipe_10    : signed(8 downto 0);
	signal out_pipe_11, out_pipe_12               : signed(8 downto 0);
	signal s_v, v_in, tmp_vin                     : std_logic;
	signal y_signed                               : signed(7 downto 0);
	signal x_signed                               : signed(7 downto 0);
	signal enable                                 : std_logic_vector(1 downto 0);
	-----------------------------------------------------------------------
begin

	in_regs : reg_en
		generic map(
			parallelism => 8
		)
		port map(
			clk => clk,
			rst => rst,
			D   => x_signed,
			Q   => (x_internal),
			en  => Vin
		);
	x_signed <= signed(x);

	extension(0) <= x_internal(7);
	concatenated <= extension & x_internal;

	x_n_minus_1 : reg
		generic map(
			parallelism => 9
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (concatenated),
			Q   => (x_minus_1)
		);

	out_reg : reg_en
		generic map(
			parallelism => 8
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (s3(7 downto 0)),
			Q   => y_signed,
			en  => enable(0)
		);
	y <= std_logic_vector(y_signed);

	v_out_pipe : shift
		generic map(
			levelPipe => 6
		)
		port map(
			clk         => clk,
			rst         => rst,
			D           => s_v,
			Q           => vout,
			enable => enable
		);

	reg_2 : reg_en
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (m3),
			Q   => (out_reg_2),
			en  => enable(1)
		);
	reg_3 : reg_en
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (s2),
			Q   => (out_reg_3),
			en  => enable(1)
		);
	reg_4 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (m4),
			Q   => (out_reg_4)
		);

	--------Vin Register-----------------		
	reg_vin : process(clk)
	begin
		if rst = '0' then
			tmp_vin <= '0';
		elsif (clk'event and clk = '1') then
			tmp_vin <= Vin;
		end if;
	end process reg_vin;
	v_in <= tmp_vin;

	---------------------------------------
	pipe_1 : reg
		generic map(
			parallelism => 9
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (concatenated),
			Q   => (out_pipe_1)
		);

	pipe_2 : reg
		generic map(
			parallelism => 9
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (m2),
			Q   => (out_pipe_2)
		);

	pipe_3 : reg
		generic map(
			parallelism => 9
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (m5),
			Q   => (out_pipe_3)
		);

	pipe_4 : reg
		generic map(
			parallelism => 9
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (s1),
			Q   => (out_pipe_4)
		);

	pipe_11 : reg
		generic map(
			parallelism => 9
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (out_pipe_8),
			Q   => (out_pipe_11)
		);

	pipe_12 : reg
		generic map(
			parallelism => 9
		)
		port map(
			clk => clk,
			rst => rst,
			D   => (s4),
			Q   => (out_pipe_12)
		);

	pipe_5 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (out_pipe_3),
			Q   => (out_pipe_5)
		);
	pipe_6 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (s2),
			Q   => (out_pipe_6)
		);
	pipe_13 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (out_reg_3),
			Q   => (out_pipe_13)
		);
	pipe_7 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (out_pipe_5),
			Q   => (out_pipe_7)
		);
	pipe_8 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (m1),
			Q   => (out_pipe_8)
		);
	pipe_9 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (out_reg_4),
			Q   => (out_pipe_9)
		);
	pipe_10 : reg
		generic map(parallelism => 9)
		port map(
			clk => clk,
			rst => rst,
			D   => (out_pipe_7),
			Q   => (out_pipe_10)
		);
	------------------------------------------------------------------------------------------------

	m1_tmp <= out_pipe_6 * signed(B0);
	m2_tmp <= x_minus_1 * signed(A1);   --@suppress
	m3_tmp <= out_reg_3 * signed(A_sqrd);
	m4_tmp <= out_pipe_13 * signed(C);
	m5_tmp <= x_minus_1 * signed(B0);   --@suppress

	m1 <= m1_tmp(15 downto 7);
	m2 <= m2_tmp(15 downto 7);
	m3 <= m3_tmp(15 downto 7);
	m4 <= m4_tmp(15 downto 7);
	m5 <= m5_tmp(15 downto 7);

	s1 <= out_pipe_1 - out_pipe_2;
	s2 <= out_pipe_4 + out_reg_2;
	s3 <= out_pipe_11 + out_pipe_12;
	s4 <= out_pipe_10 - out_pipe_9;

	----------------------------------------------------------------------------------------------
	s_v <= v_in;

end architecture RTL;
