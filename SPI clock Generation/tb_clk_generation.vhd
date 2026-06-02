library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity tb_clk_generation is
end;

architecture bench of tb_clk_generation is

  -- Component Declaration (Semicolon removed from last port)
  component clk_generation
      generic(
          divide_value  : integer := 25
      );
      port(
          clk         : in std_logic;
          reset       : in std_logic;
          clk_enable  : in std_logic;
          SCLK        : out std_logic;
          SCLK_strobe : out std_logic
      );
  end component;

  -- Signals initialized for simulation safety
  signal clk            : std_logic := '0';
  signal reset          : std_logic := '0';
  signal clk_enable     : std_logic := '0';
  signal SCLK           : std_logic;
  signal SCLK_strobe    : std_logic;

  constant clock_period : time := 10 ns;
  signal stop_the_clock : boolean := false; -- Fixed: Initialized to false

begin

  -- Fixed: Provided value 25 to generic map
  uut: clk_generation 
    generic map ( divide_value => 25 ) 
    port map ( 
      clk          => clk,
      reset        => reset,
      clk_enable   => clk_enable,
      SCLK         => SCLK,
      SCLK_strobe  => SCLK_strobe 
    );

  stimulus: process
  begin
    -- 1. Initialization and Reset
    reset <= '1';
    clk_enable <= '0';
    wait for 20 ns;
    
    reset <= '0';
    wait for 20 ns;

    -- 2. Start Clock Generation
    clk_enable <= '1';
    
    -- Fixed: Wait long enough to see SCLK toggle several times
    -- (1 MHz SPI clock needs 1000ns per period)
    wait for 5000 ns; 

    -- 3. Stop Simulation
    clk_enable <= '0';
    wait for 100 ns;
    stop_the_clock <= true;
    wait;
  end process;

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