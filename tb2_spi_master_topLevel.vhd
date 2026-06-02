library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb2_spi_master_topLevel is
end tb2_spi_master_topLevel;

architecture sim of tb2_spi_master_topLevel is

    -- Component Signals
    signal clk            : std_logic := '0';
    signal reset          : std_logic := '0';
    signal start          : std_logic := '1'; -- KEY1 is active low
    signal uart_rx_pin    : std_logic := '1'; -- Idle high
    signal data_tx        : std_logic_vector(7 downto 0) := (others => '0');
    signal miso           : std_logic := '0';
    
    signal sclk           : std_logic;
    signal mosi           : std_logic;
    signal cs_n           : std_logic;
    signal busy           : std_logic;
    signal data_rx        : std_logic_vector(7 downto 0);
    signal data_ready     : std_logic;

    -- Simulation Constants
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz
    -- 1 / 115200 = 8.68 microseconds per bit
    constant BIT_PERIOD : time := 8.68 us; 

    -- Procedure to simulate sending a byte via UART
    procedure send_uart_byte(
        constant data : in std_logic_vector(7 downto 0);
        signal rx_line : out std_logic
    ) is
    begin
        -- Start Bit
        rx_line <= '0';
        wait for BIT_PERIOD;
        
        -- Data Bits (LSB First)
        for i in 0 to 7 loop
            rx_line <= data(i);
            wait for BIT_PERIOD;
        end loop;
        
        -- Stop Bit
        rx_line <= '1';
        wait for BIT_PERIOD;
    end procedure;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.spi_master_topLevel
        port map (
            clk         => clk,
            reset       => reset,
            start       => start,
            uart_rx_pin => uart_rx_pin,
            data_tx     => data_tx,
            miso        => miso,
            sclk        => sclk,
            mosi        => mosi,
            cs_n        => cs_n,
            busy        => busy,
            data_rx     => data_rx,
            data_ready  => data_ready
        );

    -- Clock Generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- 1. Global Reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 1 us;

        -- 2. Test UART Path (Sending 'A' = 0x41 = "01000001")
        -- This simulates your laptop sending a character
        report "Starting UART to SPI Test: Sending 0x41";
        send_uart_byte(X"41", uart_rx_pin);
        
        -- Wait for SPI to finish (it will trigger automatically)
        wait until data_ready = '1';
        wait for 100 us;

        -- 3. Test Manual Button Path
        -- Simulate setting switches to 0xAA and pressing Start
        data_tx <= X"AA";
        start <= '0'; -- Press button
        wait for 100 ns;
        start <= '1'; -- Release button
        
        -- Loopback simulation: Connect MOSI to MISO logic in TB
        -- (Optional: you can create a process to drive MISO = MOSI)
        
        wait for 1 ms;
        report "Simulation Finished";
        wait;
    end process;

    -- Loopback Logic for Simulation: Connect MOSI back to MISO
    miso <= mosi;

end sim;