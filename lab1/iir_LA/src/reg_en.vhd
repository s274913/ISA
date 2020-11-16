library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- This is a register that has a load enable signal to save the data --
entity reg_en is
	generic(parallelism : integer := 9);
	port(
		clk : in  std_logic;
		rst : in  std_logic;
		D   : in  signed(parallelism - 1 downto 0);
		Q   : out signed(parallelism - 1 downto 0);
		en  : in  std_logic
	);
end entity reg_en;

architecture RTL of reg_en is

	signal tmp : signed(parallelism - 1 downto 0);

begin
	regprocess : process(clk, rst)      --@suppress
	begin
		if rst = '0' then
			tmp <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				tmp <= D;
			end if;
		end if;
	end process;
	Q <= tmp;
end architecture RTL;
