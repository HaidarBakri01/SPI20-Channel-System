library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Entity FSM_SPI is

			port(
			
			--inputs
			clk   : in std_logic;
			reset : in std_logic;
			
			-- input triggers or control input
			start_tx       : in std_logic;
			bit_count_done : in std_logic;
			
			--system outputs which controled from the input
			CS_n         : out std_logic;
			shift_enable : out std_logic;
			count_enable : out std_logic;
			SCLK_enable  : out std_logic;
			data_ready   : out std_logic
			);

end FSM_SPI;

architecture RTL_FSM_SPI of FSM_SPI is

	-- define the 4 states 
	type state_type is (IDLE, START, SHIFT, DONE);
	signal current_state, next_state : state_type;
	
	begin
	------------------------------------------------------First process (state memory)------------------------------------------------
	process(clk, reset)
	begin
		-- when we rest the system FSM or controller will stay in the same state no change
		if reset = '1'then
			current_state <= IDLE;
		elsif rising_edge(clk) then	-- else when the clk is the event and at the same time it is 1 so go to the next state
			current_state <= next_state;
		end if;	
	end process;
	---------------------------------------------------------------------------------------------------------------------------------
	
	------------------------------------------------Second Process Control logic (Combinational)-------------------------------------
	process(current_state, bit_count_done, start_tx)
	begin
		
		next_state   <= current_state; -- default assignments to prevent latches
		CS_n 		 <= '1'; --inactive to active it trun it to 0 --> active low logic 0
		shift_enable <= '0';
		count_enable <= '0';
		SCLK_enable  <= '0';
		data_ready   <= '0';
		
		case current_state is
		--type state_type is (IDLE, START, SHIFT, DONE);
		
		--state1
			when IDLE =>
				CS_n <= '1'; --keep the peripheral disable
				if start_tx = '0' then  -- transition
					next_state <= START;
				else
					next_state <= IDLE;
				END if;
				
			-- state2	
			when START =>	 -- AUTO transition; there are no condtion. But it is important to mak sure the system start
				CS_n <= '0'; --ACTIVE THE peripheral; WHICH mean active low on the clock cycle
				next_state <= SHIFT;
				
			-- state3	
			when SHIFT =>
				CS_n 		 <= '0';
				SCLK_enable  <= '1';
				shift_enable <= '1';
				count_enable <= '1';
				if bit_count_done = '1' then --transition
					next_state <= DONE;
			    else 
					next_state <= SHIFT; -- stay in the same state
				end if;
			
			-- state4
			when DONE =>
					CS_n 	   <= '1'; -- return it to idle; which is inactive peripheral
					data_ready <= '1'; -- data is valid
					--return back to the idle state
					next_state <= IDLE; 
		end case;	
	end process;
end RTL_FSM_SPI;