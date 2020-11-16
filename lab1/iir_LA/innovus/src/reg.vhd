library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- This is a register whitout load enable signal --
entity reg is
	generic(parallelism : integer := 9);
	port(
		clk : in  std_logic;
		rst : in  std_logic;
		D   : in  signed( parallelism - 1 downto 0);
		Q   : out signed( parallelism - 1 downto 0)
	);
end entity reg;

architecture RTL of reg is

	signal tmp : signed( parallelism - 1 downto 0);

begin
	regprocess : process(clk, rst)      --@suppress
	begin
		if rst = '0' then
			tmp <= (others => '0');
		elsif clk'event and clk = '1' then
				tmp <= D;
		end if;
	end process;
	Q <= tmp;
end architecture RTL;
