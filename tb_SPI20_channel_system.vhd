library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity tb_SPI20_channel_system is
end;

architecture bench of tb_SPI20_channel_system is

  -- Component Declaration for the Unit Under Test (UUT)
  component SPI20_channel_system
      port(
          clk        : in std_logic;
          reset      : in std_logic;
          start      : in std_logic;
          data_tx20  : in std_logic_vector(159 downto 0);
          sclk       : out std_logic;
          cs_n       : out std_logic_vector(19 downto 0);
          mosin20    : out std_logic_vector(19 downto 0);
          miso20     : in std_logic_vector(19 downto 0);
          data_rx20  : out std_logic_vector(159 downto 0);
          busy       : out std_logic_vector(19 downto 0);
          data_ready : out std_logic_vector(19 downto 0)             
      );
  end component;

  -- Signals to connect to the UUT
  signal clk        : std_logic := '0';
  signal reset      : std_logic := '0';
  signal start      : std_logic := '0';
  signal data_tx20  : std_logic_vector(159 downto 0) := (others => '0');
  signal sclk       : std_logic;
  signal cs_n       : std_logic_vector(19 downto 0);
  signal mosin20    : std_logic_vector(19 downto 0);
  signal miso20     : std_logic_vector(19 downto 0);
  signal data_rx20  : std_logic_vector(159 downto 0);
  signal busy       : std_logic_vector(19 downto 0);
  signal data_ready : std_logic_vector(19 downto 0);

  -- Clock period definition (50 MHz = 20ns period)
  constant CLK_PERIOD : time := 20 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: SPI20_channel_system 
    port map ( 
      clk        => clk,
      reset      => reset,
      start      => start,
      data_tx20  => data_tx20,
      sclk       => sclk,
      cs_n       => cs_n,
      mosin20    => mosin20,
      miso20     => miso20,
      data_rx20  => data_rx20,
      busy       => busy,
      data_ready => data_ready 
    );

  -- 1. Continuous Clock Generation
  clk_process : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  -- 2. Simulation Loopback (Internal wire)
  -- This sends the MOSI output of each channel back into its MISO input
  miso20 <= mosin20;

  -- 3. Stimulus Process
  stimulus: process
  begin
    -- Step A: Initialization & System Reset
    reset <= '1';
    start <= '0';
    
    -- Load unique test data into the 160-bit bus
    -- Channel 0 gets 0x01, Channel 1 gets 0x02 ... Channel 19 gets 0x14
    for i in 0 to 19 loop
        data_tx20((i*8+7) downto (i*8)) <= std_logic_vector(to_unsigned(i+1, 8));
    end loop;

    wait for 100 ns;
    reset <= '0'; -- Release reset
    wait for 100 ns;

    -- Step B: Trigger the SPI Transfer
    -- We pulse 'start' for one clock cycle
    wait until falling_edge(clk);
    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';

    -- Step C: Wait for Completion
    -- We monitor Channel 0's data_ready signal
    wait until data_ready(0) = '1';
    
    -- Give a little time to observe the final data_rx20 results
    wait for 500 ns;

    -- Step D: Finish Simulation
    report "Simulation Complete: All 20 channels processed in parallel!" severity note;
    
    -- Stop the simulation
    assert false report "End of Simulation" severity failure;
    wait;
  end process;

end bench;