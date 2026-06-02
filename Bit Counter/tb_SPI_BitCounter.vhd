library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity tb_SPI_BitCounter is
-- Testbench has no ports
end tb_SPI_BitCounter;

architecture bench of tb_SPI_BitCounter is

  -- Component Declaration: Must match your RTL entity name exactly
  component SPI_BitCounter
          port(
              clk            : in std_logic;
              reset          : in std_logic;
              count_enable   : in std_logic;
              SCLK           : in std_logic;
              bit_count_done : out std_logic
          );
  end component;

  -- Local signals to connect to the Unit Under Test (UUT)
  signal clk            : std_logic := '0';
  signal reset          : std_logic := '0';
  signal count_enable   : std_logic := '0';
  signal SCLK           : std_logic := '0';
  signal bit_count_done : std_logic;

  -- Timing constants
  constant clock_period : time := 10 ns; -- 100 MHz system clock
  signal stop_the_clock : boolean := false;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: SPI_BitCounter port map ( 
                                 clk            => clk,
                                 reset          => reset,
                                 count_enable   => count_enable,
                                 SCLK           => SCLK,
                                 bit_count_done => bit_count_done 
                               );

  -- Stimulus Process: Drives the test scenario
  stimulus: process
  begin
    -- 1. Reset Phase
    reset <= '1';
    count_enable <= '0';
    SCLK <= '0';
    wait for 40 ns;
    reset <= '0';
    wait for 40 ns;

    -- 2. Start Transfer (Wait for clk edge for professional synchronization)
    wait until rising_edge(clk);
    count_enable <= '1';

    -- 3. Provide 17 SCLK pulses
    -- The 17th pulse ensures the 16th rising edge is fully processed 
    -- and the 'done' flag is visible while count_enable is still high.
    for i in 0 to 16 loop
        SCLK <= '0';
        wait for 100 ns; -- SCLK Low period
        SCLK <= '1';
        wait for 100 ns; -- SCLK High period (Counter increments here)
    end loop;

    -- 4. Hold 'count_enable' high for a few system clocks 
    -- so bit_count_done can be clearly seen in the waveform.
    wait for 100 ns; 

    -- 5. End Transfer
    count_enable <= '0';
    wait for 200 ns;
    
    -- Stop the system clock to end the simulation
    stop_the_clock <= true;
    wait;
  end process;

  -- Professional Clock Generator Process
  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0';
      wait for clock_period / 2;
      clk <= '1';
      wait for clock_period / 2;
    end loop;
    wait;
  end process;

end bench;