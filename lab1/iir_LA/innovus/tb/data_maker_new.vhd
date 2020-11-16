library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is
	port(
		CLK     : in  std_logic;
		RST_n   : in  std_logic;
		VOUT    : out std_logic;
		DOUT    : out std_logic_vector(7 downto 0);
		B0      : out std_logic_vector(7 downto 0);
		A1      : out std_logic_vector(7 downto 0);
		C       : out std_logic_vector(7 downto 0);
		A_sqrd  : out std_logic_vector(7 downto 0);
		END_SIM : out std_logic);
end data_maker;

architecture beh of data_maker is

	constant tco : time := 1 ns;

	signal sEndSim   : std_logic;
	signal END_SIM_i : std_logic_vector(0 to 206);

begin                                  -- beh

	B0     <= conv_std_logic_vector(53, 8);
	A1     <= conv_std_logic_vector(-21, 8);
	C      <= conv_std_logic_vector(-9, 8);
	A_sqrd <= conv_std_logic_vector(3, 8);

	process(CLK, RST_n)
		file fp_in       : text open READ_MODE is "../sim/samples.txt";
		variable line_in : line;
		variable x       : integer;
		variable cont 	 : integer := 0;
	begin                               -- process
		if RST_n = '0' then             -- asynchronous reset (active low)
			DOUT    <= (others => '0') after tco;
			VOUT    <= '0' after tco;
			sEndSim <= '0' after tco;
		elsif CLK'event and CLK = '1' then -- rising clock edge
			if not endfile(fp_in) and cont /= 6 then
				readline(fp_in, line_in);
				read(line_in, x);
				DOUT    <= conv_std_logic_vector(x, 8) after tco;
				VOUT    <= '1' after tco;
				sEndSim <= '0' after tco;
				cont := cont + 1;
			else
			    cont := cont + 1;
				VOUT    <= '0' after tco;
				sEndSim <= '1' after tco;
			end if;
		end if;
	end process;

	process(CLK, RST_n)
	begin                               -- process
		if RST_n = '0' then             -- asynchronous reset (active low)
			END_SIM_i <= (others => '0') after tco;
		elsif CLK'event and CLK = '1' then -- rising clock edge
			END_SIM_i(0)       <= sEndSim after tco;
			END_SIM_i(1 to 206) <= END_SIM_i(0 to 205) after tco;
		end if;
	end process;

	END_SIM <= END_SIM_i(206);

end beh;
