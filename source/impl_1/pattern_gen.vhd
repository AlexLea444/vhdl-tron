library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pattern_gen is
	generic (
		game_rows : integer := 256;
		game_cols : integer := 512;
		drawing_rows : integer := 480;
		object_width : integer := 8);
	port (
		-- Player location information
		object_x_P1: in unsigned(5 downto 0);
		object_y_P1 : in unsigned(4 downto 0);
		object_x_P2 : in unsigned(5 downto 0);
		object_y_P2 : in unsigned(4 downto 0);
		prev_x_P1: in unsigned(5 downto 0);
		prev_y_P1 : in unsigned(4 downto 0);
		prev_x_P2 : in unsigned(5 downto 0);
		prev_y_P2 : in unsigned(4 downto 0);
		
		-- VGA information
		valid : in std_logic;
		row : in unsigned(9 downto 0);
		col : in unsigned(9 downto 0);
		
		-- Universal clock
		pll_clk : in std_logic;
		
		-- Controller inputs
		input_one : in unsigned(7 downto 0);
		input_two : in unsigned(7 downto 0);
		
		r_address : out std_logic_vector(10 downto 0);
		data_from_mem : in std_logic_vector(1 downto 0);
		w_address : out std_logic_vector(10 downto 0);
		data_to_mem : out std_logic_vector(1 downto 0);
		write_enable : out std_logic;
		write_a : out std_logic;
		read_b : out std_logic;
		
		rgb : out std_logic_vector(5 downto 0));
end;

architecture synth of pattern_gen is

-- Counter to cycle through every address of memory
signal memoryBC : unsigned(10 downto 0) := 11d"0";
signal trail_to_player : std_logic := '0'; -- '0' for player 1, '1' for player 2

-- Flags to indicate player collision status
signal collision_p1 : std_logic := '0';
signal collision_p2 : std_logic := '0';

-- Flag to indicate whether collisions should be detected
signal start_collision : std_logic := '0';

-- Help convert location in display to location in memory
signal mem_row : unsigned(7 downto 0);
signal mem_col : unsigned(8 downto 0);

begin
	move_and_generate : process (pll_clk) begin
		if rising_edge (pll_clk) then
			if (valid = '0') then
				rgb <= "000000";
				if (row >= drawing_rows) then
					
					read_b <= '1';
					r_address <= "00000000000";
					
					-- Code Below works as of 12/8 12:14 AM
					if (row = 10d"480" and col = 10d"0") then
						memoryBC <= 11d"0";
					end if;
					if (start_collision = '1') then
						if (memoryBC = 11d"2047") then
							write_enable <= '0';
							write_a <= '0';
							read_b <= '1';
						elsif (trail_to_player = '0') then
							w_address <= std_logic_vector(prev_y_P1(4 downto 0) & prev_x_P1(5 downto 0));
							if collision_p1 = '0' then
								write_enable <= '1';
							else
								write_enable <= '0';
							end if;
							write_a <= '1';
							trail_to_player <= '1';
							data_to_mem <= "10";
							memoryBC <= memoryBC + 11d"1";
						else 
							w_address <= std_logic_vector(prev_y_P2(4 downto 0) & prev_x_P2(5 downto 0));
							if collision_p2 = '0' then
								write_enable <= '1';
							else
								write_enable <= '0';
							end if;
							write_a <= '1';
							trail_to_player <= '0';
							data_to_mem <= "11";
							memoryBC <= memoryBC + 11d"1";
						end if;
					end if;
					
				end if;
			else
				write_a <= '0';
				write_enable <= '0';
				-- Confine player movement to within the RAM blocks and dimensions
				--if (collision_p1 = '1') then
					--rgb <= "011011";
				--elsif (collision_p2 = '1') then
					--rgb <= "110011"; -- If collision occurs for p2, whole screen is drawn in p1 colors
				--else
				if (collision_p1 = '0' and col > ("0" & object_x_P1(5 downto 0) & "000"))
					and (col < ("0" & object_x_P1(5 downto 0) & "000") + object_width)
					and (row > ("00" & object_y_P1(4 downto 0) & "000"))
					and (row < ("00" & object_y_P1(4 downto 0) & "000") + object_width) then
							rgb <= "110011";
				elsif    (collision_p1 = '0' and col > ("0" & prev_x_P1(5 downto 0) & "000")) -- PREVIOUS 
					and  (col < ("0" & prev_x_P1(5 downto 0) & "000") + object_width)
					and (row > ("00" & prev_y_P1(4 downto 0) & "000"))
					and (row < ("00" & prev_y_P1(4 downto 0) & "000") + object_width) then
						rgb <= "110011";
				elsif (collision_p2 = '0' and col > ("0" & object_x_P2(5 downto 0) & "000"))
					and (col < ("0" & object_x_P2(5 downto 0) & "000") + object_width)
					and (row > ("00" & object_y_P2(4 downto 0) & "000"))
					and (row < ("00" & object_y_P2(4 downto 0) & "000") + object_width) then
						rgb <= "011011";
				elsif    (collision_p2 = '0' and col > ("0" & prev_x_P2(5 downto 0) & "000")) -- PREVIOUS 
					and  (col < ("0" & prev_x_P2(5 downto 0) & "000") + object_width)
					and (row > ("00" & prev_y_P2(4 downto 0) & "000"))
					and (row < ("00" & prev_y_P2(4 downto 0) & "000") + object_width) then
						rgb <= "011011";
	
				-- Input Display Tests
				elsif ((col > 20) and (col < 31)	-- UP
					and (row > 439)
					and (row < 451)) then
						if (input_one(3) = '0') then
							rgb <= "000000";
						else
							rgb <= "111111";
						end if;
						--rgb <= "001111";
				elsif (col > 30 and (col < 41)	-- RIGHT
					and (row > 449)
					and (row < 461)) then
						if (input_one(0) = '0') then
							rgb <= "000000";
						else
							rgb <= "111111";
						end if;
				elsif (col > 20 and (col < 31)	-- DOWN
					and (row > 459)
					and (row < 470)) then
						if (input_one(2) = '0') then
							rgb <= "000000";
						else
							rgb <= "111111";
						end if;
				elsif ((col > 10) and (col < 21)	-- LEFT
					and (row > 449)
					and (row < 461)) then
						if (input_one(1) = '0') then
							rgb <= "000000";
						else
							rgb <= "111111";
						end if;
				elsif (col > 50) and (col < 61)	-- Select button
					and (row > 459)
					and (row < 470) then
						if (input_one(5) = '0') then
							rgb <= "000000";
							start_collision <= '1';
						else
							rgb <= "111111";
						end if;
				-- Collision Detection Test
				elsif (col > 80) and (col < 91)	-- Player 1, Black if no collision, Yellow if Collision!
					and (row > 459)
					and (row < 470) then
						if (collision_p1 = '0') then
							rgb <= "000000";
						else
							rgb <= "111100";
						end if;
				elsif (col > 100) and (col < 111)	-- Player 2, Black if no collision, Orange if Collision!
					and (row > 459)
					and (row < 470) then
						if (collision_p2 = '0') then
							rgb <= "000000";
						else
							rgb <= "111000";
						end if;
				
				else
					-- Reading Memory
					if ((row < game_rows) and (col < game_cols)) then
						r_address <= std_logic_vector((mem_row(7 downto 3) & mem_col(8 downto 3)));
						read_b <= '1';
						if (data_from_mem = "00") then -- "Area of Play"
							rgb <= "001100";
						elsif (data_from_mem = "01") then -- Walls
							rgb <= "111111";
							if (start_collision = '1' and (row(7 downto 3) = object_y_P1) and (col(8 downto 3) = object_x_P1)) then
								collision_p1 <= '1';
							end if;
							if (start_collision = '1' and (row(7 downto 3) = object_y_P2) and (col(8 downto 3) = object_x_P2)) then
								collision_p2 <= '1';
							end if;
						elsif (data_from_mem = "10") then -- Player 1
							rgb <= "100011";
							if (start_collision = '1' and (row(7 downto 3) = object_y_P1) and (col(8 downto 3) = object_x_P1) and (object_x_P1 <= prev_x_P1)) then
								collision_p1 <= '1';
							end if;
							if (start_collision = '1' and (row(7 downto 3) = object_y_P2) and (col(8 downto 3) = object_x_P2)) then
								collision_p2 <= '1';
							end if;
						else
							rgb <= "010011"; -- Player 2
							if (start_collision = '1' and (row(7 downto 3) = object_y_P1) and (col(8 downto 3) = object_x_P1)) then
								collision_p1 <= '1';
							end if;
							if (start_collision = '1' and (row(7 downto 3) = object_y_P2) and (col(8 downto 3) = object_x_P2) and (object_x_P2 <= prev_x_P2)) then
								collision_p2 <= '1';
							end if;
						end if;
					else
						rgb <= "000011";
						if (collision_p1 = '1') then
							rgb <= "011011";
							collision_p2 <= '0';
						elsif (collision_p2 = '1') then
							rgb <= "110011"; -- If collision occurs for p2, edge is drawn in p1 colors
							collision_p1 <= '0';
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	mem_row <= row(7 downto 0);
	mem_col <= col(8 downto 0) + 1;
	
end;


