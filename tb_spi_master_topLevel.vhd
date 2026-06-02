library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_spi_master_topLevel is
end tb_spi_master_topLevel;

architecture tb of tb_spi_master_topLevel is

    -- 1. Component Declaration (Matches your Top Level)
    component spi_master_topLevel
        generic (
            divide_value : integer := 25 -- Added to match your clk_gen
        );
        port (clk         : in std_logic;
              reset       : in std_logic;
              start       : in std_logic;
              data_tx     : in std_logic_vector (15 downto 0);
              miso        : in std_logic;
              sclk        : out std_logic;
              mosi        : out std_logic;
              cs_n        : out std_logic;
              busy        : out std_logic;
              data_rx     : out std_logic_vector (15 downto 0);
              data_ready  : out std_logic);
    end component;

    -- Signals
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal start       : std_logic := '0';
    signal data_tx     : std_logic_vector (15 downto 0) := (others => '0');
    signal miso        : std_logic := '0';
    signal sclk        : std_logic;
    signal mosi        : std_logic;
    signal cs_n        : std_logic;
    signal busy        : std_logic;
    signal data_rx     : std_logic_vector (15 downto 0);
    signal data_ready  : std_logic;

    -- Constants
    constant TbPeriod : time := 20 ns; -- 50 MHz FPGA Clock
    signal TbSimEnded : std_logic := '0';

begin

    -- 2. Instantiate the Unit Under Test (UUT)
    dut : spi_master_topLevel
    generic map (
        divide_value => 25 -- SCLK = 1MHz if clk = 50MHz
    )
    port map (clk         => clk,
              reset       => reset,
              start       => start,
              data_tx     => data_tx,
              miso        => miso,
              sclk        => sclk,
              mosi        => mosi,
              cs_n        => cs_n,
              busy        => busy,
              data_rx     => data_rx,
              data_ready  => data_ready);

    -- 3. Clock Generation
    clk <= not clk after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- 4. Loopback (Optional: Connect MOSI to MISO to test data receiving)
    -- miso <= mosi; 

    -- 5. Stimulus Process
    stimuli : process
    begin
        -- Initialization
        start <= '0';
        data_tx <= (others => '0');
        miso <= '0';

        -- Reset Sequence
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- TRANSACTION 1: Send 0xABCD
        data_tx <= x"ABCD";
        wait for TbPeriod;
        start <= '1';      -- Pulse start
        wait for TbPeriod;
        start <= '0';

        -- Wait for the Master to finish the 16-bit transfer
        wait until busy = '0';
        wait for 200 ns;

        -- TRANSACTION 2: Send 0x1234
        data_tx <= x"1234";
        start <= '1';
        wait for TbPeriod;
        start <= '0';

        -- Wait for finish
        wait until busy = '0';
        wait for 1000 ns;

        -- End Simulation
        TbSimEnded <= '1';
        report "SPI Simulation Completed Successfully";
        wait;
    end process;

end tb;

-- Configuration block
configuration cfg_tb_spi_master_topLevel of tb_spi_master_topLevel is
    for tb
    end for;
end cfg_tb_spi_master_topLevel;