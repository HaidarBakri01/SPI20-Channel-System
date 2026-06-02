library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_spi_to_sd is
end tb_spi_to_sd;

architecture sim of tb_spi_to_sd is
    -- Testbench Signals
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '1';
    signal start        : std_logic := '0';
    signal data_tx      : std_logic_vector(15 downto 0) := x"A1A2"; -- Data to SD
    signal miso         : std_logic;
    signal sclk         : std_logic;
    signal mosi         : std_logic;
    signal cs_n         : std_logic;
    signal busy         : std_logic;
    signal data_rx      : std_logic_vector(15 downto 0);
    signal data_ready   : std_logic;

begin

    -- 1. Instantiate YOUR Top Level SPI Master
    UUT_MASTER : entity work.spi_master_topLevel
        port map (
            clk         => clk,
            reset       => reset,
            start       => start,
            data_tx     => data_tx,
            miso        => miso,
            sclk        => sclk,
            mosi        => mosi,
            cs_n        => cs_n,
            busy        => busy,
            data_rx     => data_rx,
            data_ready  => data_ready
        );

    -- 2. Instantiate the SD Card Model (The Slave)
    -- This simulates a real SD card responding with x"A5A5"
    UUT_SLAVE : entity work.sd_card_sim
        port map (
            sclk => sclk,
            mosi => mosi,
            miso => miso
        );

    -- 3. Generate 50MHz Clock
    clk <= not clk after 10 ns;

    -- 4. Test Procedure
    process
    begin
        -- Initial Reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- Pulse Start signal to begin SPI transaction
        start <= '1';
        wait for 20 ns;
        start <= '0';

        -- Wait for the Controller to finish the 16-bit shift
        wait until data_ready = '1';
        
        -- Check if we received the x"A5A5" from our SD simulation
        assert data_rx = x"A5A5" 
            report "SUCCESS: Received xA5A5 from SD Card Model" 
            severity note;

        wait for 500 ns;
        report "Simulation Finished";
        wait;
    end process;

end sim;