library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_tb is
end uart_rx_tb;

architecture sim of uart_rx_tb is

    -- Signals to connect to the UART component
    signal clk       : std_logic := '0';
    signal rx_serial : std_logic := '1'; -- Idle high
    signal rx_byte   : std_logic_vector(7 downto 0);
    signal rx_done   : std_logic;

    -- Constants
    constant CLK_PERIOD : time := 20 ns;   -- 50 MHz
    -- 1 / 115200 baud = 8.68 microseconds per bit
    constant BIT_PERIOD : time := 8.68 us; 

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.uart_rx
        port map (
            clk       => clk,
            rx_serial => rx_serial,
            rx_byte   => rx_byte,
            rx_done   => rx_done
        );

    -- 50 MHz Clock Generator
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process: Mimics a Laptop sending data
    stim_proc: process
    begin
        -- Wait for initial power-on
        wait for 100 ns;

        -- TEST 1: Send the character 'A' (Binary: 01000001, Hex: 0x41)
        -- UART sends LSB first
        
        report "UART Sim: Sending 0x41 (A)";
        
        -- Start Bit (Logic 0)
        rx_serial <= '0';
        wait for BIT_PERIOD;
        
        -- Data Bits (LSB to MSB: 1, 0, 0, 0, 0, 0, 1, 0)
        rx_serial <= '1'; wait for BIT_PERIOD; -- Bit 0
        rx_serial <= '0'; wait for BIT_PERIOD; -- Bit 1
        rx_serial <= '0'; wait for BIT_PERIOD; -- Bit 2
        rx_serial <= '0'; wait for BIT_PERIOD; -- Bit 3
        rx_serial <= '0'; wait for BIT_PERIOD; -- Bit 4
        rx_serial <= '0'; wait for BIT_PERIOD; -- Bit 5
        rx_serial <= '1'; wait for BIT_PERIOD; -- Bit 6
        rx_serial <= '0'; wait for BIT_PERIOD; -- Bit 7
        
        -- Stop Bit (Logic 1)
        rx_serial <= '1';
        wait for BIT_PERIOD;

        -- Wait to see rx_done pulse
        wait until rx_done = '1';
        wait for 10 us;

        -- TEST 2: Send Hex 0x55 (Alternating bits 01010101)
        report "UART Sim: Sending 0x55";
        
        rx_serial <= '0'; wait for BIT_PERIOD; -- Start
        for i in 0 to 7 loop
            if (i mod 2 = 0) then rx_serial <= '1'; else rx_serial <= '0'; end if;
            wait for BIT_PERIOD;
        end loop;
        rx_serial <= '1'; wait for BIT_PERIOD; -- Stop

        wait for 100 us;
        report "Simulation Finished";
        wait;
    end process;

end sim;