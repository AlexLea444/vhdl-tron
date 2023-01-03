library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bike_velocity is
	port (
		player : in std_logic;
		p1_select : in std_logic;
		north : in std_logic;
		south : in std_logic;
		east : in std_logic;
		west : in std_logic;
		clk : in std_logic;
		encoded_velocity : out std_logic_vector(1 downto 0)
	);
end;

architecture synth of bike_velocity is
-- ACTIVE LOW
signal prev_n : std_logic:='1'; -- changed
signal prev_e : std_logic:='1';
signal prev_s : std_logic:='1';
signal prev_w : std_logic:='1';

--Store velocity encoding
signal next_velocity : std_logic_vector(1 downto 0) := "11";

--Set to 0, turns to 1 to start game
signal flag : std_logic := '0';

begin
	process(clk) begin
		if rising_edge(clk) then
			if (flag = '0') then
				if (player = '1') then
					next_velocity <= "11";
				else
					next_velocity <= "10";
				end if;
				if (p1_select = '0') then
					flag <= '1';
				end if;
			else
				if (prev_s = '1' and north = '0') then -- ACTIVE LOW
					next_velocity <= "00"; -- UP
				end if;
				if (prev_w = '1' and east = '0') then
					next_velocity <= "11"; -- RIGHT
				end if;
				if (prev_n = '1' and south = '0') then
					next_velocity <= "01"; -- DOWN
				end if;
				if (prev_e = '1' and west = '0') then
					next_velocity <= "10"; -- LEFT
				end if;
					prev_n <= north;
					prev_e <= east;
					prev_s <= south;
					prev_w <= west;
			end if;
		end if;		
	end process;					
	encoded_velocity <= next_velocity;
end;

