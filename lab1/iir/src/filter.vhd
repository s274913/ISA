library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is
	port(
		clk, rst    : in  std_logic;
		vin         : in  std_logic;
		Din, b0, a1 : in  signed(7 downto 0);
		vout        : out   std_logic;
		Dout        : out signed(7 downto 0)
	);
end entity filter;

architecture RTL of filter is

	signal m1, m2, ff             : signed(8 downto 0);
	signal m1_tmp, m2_tmp, ff_tmp : signed(16 downto 0);
	signal tmpfb, fb              : signed(8 downto 0);
	signal w, s1                  : signed(8 downto 0);
	signal v_out, v_in, tmprvin   : std_logic;
	signal tmpDin                 : signed(7 downto 0);
	signal tmpDout                : signed(7 downto 0);
	signal internalDin            : signed(8 downto 0);
	signal extension              : signed(0 downto 0);
	signal tmprv_out              : std_logic;
begin

	registerrvout : process(clk)
	begin
		if rst = '0' then
			tmprv_out <= '0';
		elsif (clk'event and clk = '1') then
			tmprv_out <= v_out;
		end if;
	end process registerrvout;
	vout <= tmprv_out;

	registerrvi : process(clk)
	begin
		if rst = '0' then
			tmprvin <= '0';
		elsif (clk'event and clk = '1') then
			tmprvin <= vin;
		end if;
	end process registerrvi;
	v_in <= tmprvin;

	registerfb : process(clk)
	begin
		if rst = '0' then
			tmpfb <= (others => '0');
		elsif (clk'event and clk = '1') then
			if v_in = '1' then
				tmpfb <= w;
			end if;
		end if;
	end process registerfb;
	fb <= tmpfb;

	registersDin : process(clk)         --@suppress
	begin
		if rst = '0' then
			tmpDin <= (others => '0');
		elsif (clk'event and clk = '1') then
			if vin = '1' then
				tmpDin <= Din;
			end if;
		end if;
	end process registersDin;
	extension   <= (others => tmpDin(7));
	internalDin <= extension & tmpDin;

	registersDout : process(clk)        --@suppress
	begin
		if rst = '0' then
			tmpDout <= (others => '0');
		elsif (clk'event and clk = '1') then
			tmpDout <= s1(7 downto 0);
		end if;
	end process registersDout;
	Dout <= tmpDout;

	---------------------------------------------------
	v_out  <= v_in;
	----------------------------------------------------
	-- y = b0*w(n) + b1*w(n-1)
	-- w = x(n) - a1*w(n-1) 
	----------------------------------------------------
	m1_tmp <= fb * a1;                  --result moltiplication need 17 bit
	m1     <= m1_tmp(15 downto 7);      --restoring on 9 bit the result.It's 15 downto 7 
	w      <= internalDin - m1;         --and not 16 downto 8 because the dot shift
	ff_tmp <= w * b0;                   -- of 1 position more (e.g. 1.00*1.00=11.0000)
	m2_tmp <= fb * b0;
	m2     <= m2_tmp(15 downto 7);
	ff     <= ff_tmp(15 downto 7);
	s1     <= ff + m2;
	-----------------------------------------------------

end architecture RTL;
