library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_BitCounter is

		port(
			--input
			clk 		   : in std_logic; --clk sys
			reset  		   : in std_logic;
			count_enable   : in std_logic;
			SCLK_strobe    : IN std_logic;
	
			--output
			bit_count_done : out std_logic
		);

end SPI_BitCounter;


architecture SPI_BitCounter_RTL of SPI_BitCounter is

	signal counter :unsigned(4 downto 0) := (others => '0');
	signal sclk_delayed : std_logic := '0';
    signal sclk_rising  : std_logic;
	
	begin
	--------------------------------------------------------------------------------------------------------------------------------------------
	--Synchronous Data Input (Sampling)
	process(clk, reset)
	begin
		if reset = '1' then
			sclk_delayed <= '0';
		elsif rising_edge (clk) then
			sclk_delayed <= SCLK_strobe;
		end if;
	end process;
	--------------------------------------------------------------------------------------------------------------------------------------------
	
	sclk_rising <= '1' when (SCLK_strobe  = '1' and sclk_delayed = '0') else '0';
	
	-------------------------------------------------------------------------------------------------------------------------------------------
	--Synchronous State (The Counter)
	process(clk, reset)
	begin
		if reset = '1' then
			counter <= (others => '0');
		elsif rising_edge(clk) then
			if count_enable = '0' then
				counter <= (others => '0');
			elsif sclk_rising = '1' then 
				counter <= counter + 1;
			end if;	
		end if;	
	end process;
	-------------------------------------------------------------------------------------------------------------------------------------------
	--Combinational Logic (The Decoder)
	process(counter)
		begin
		if counter = 8 then
			bit_count_done <= '1';
		else
			bit_count_done <= '0';
		end if;
	end process;
		
end SPI_BitCounter_RTL;