library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

Entity clk_generation is


		generic(
			-- formula of the divide value = fsys/(2*fsclk)
			-- my fpga freq is 50MHZ and assume SPI is 1 MHZ so divide value = 25
			
			divide_value  : integer := 25 -- baud rate
		
		);

		port(
		
		--Inputs 
		clk         : in std_logic;
		reset       : in std_logic;
		clk_enable  : in std_logic; -- from FSM 
		
		--outputs
		SCLK	    : out std_logic; -- CONNEcted to the shift_regsiter to know when to push or pull bits across the MOSI/MISO lines
		--one cycle pules for bit counter
		SCLK_strobe : out std_logic --Sample Tick and tell other block such as the bit_counter block event just happened
									-- moreover, it generate at the rising edge of the SCLK
									-- it run on the fast system clock and use that signal to prevent timing error
		
		
		);
	
end Entity;

architecture SPI_clk_generation_RTL of clk_generation is


	signal count : integer range 0 to divide_value := 0;
	signal sclk_register : std_logic := '0';
	signal strobe_register : std_logic := '0';
	
begin
	
	SCLK <= sclk_register;
	SCLK_strobe <= strobe_register;
	
	--SPI Mode 0
	process(clk, reset)
	begin
		if reset = '1' then -- reset everything and signals
			count <= 0;
			sclk_register <= '0'; -- CPOL 
			strobe_register <= '0';
		elsif rising_edge(clk) then
			strobe_register <= '0';
			if clk_enable = '1' then 
				if count = divide_value - 1 then 
					--reset count then toggles the SCLK signal
					count <= 0;
					sclk_register <= not sclk_register;
					
					-- clock phase condition - CPHA 
					if sclk_register = '0' then 
						strobe_register <= '1';
					end if;
				else 
				-- increment on every rising_edge
					count <= count + 1;
				end if;
			else -- if there is no signal from the FSM --> clk_enable. So, reset the clock to idle state CPOL = 0
				count <= 0;
				sclk_register <= '0';
				strobe_register <= '0';
			end if;	
		end if;
	end process;
	
	
end SPI_clk_generation_RTL;