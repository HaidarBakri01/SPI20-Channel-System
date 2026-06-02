library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_ShiftRegister_tb is
end entity;

architecture behavior of SPI_ShiftRegister_tb is
    -- Component Declaration
    component SPI_ShiftRegister
        port(
            data_Tx      : in  std_logic_vector(15 downto 0);
            shift_enable : in  std_logic;
            SCLK         : in  std_logic;
            MISO         : in  std_logic;
            reset        : in  std_logic;
            MOSI         : out std_logic;
            data_Rx      : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals to connect to UUT
    signal data_Tx      : std_logic_vector(15 downto 0) := (others => '0');
    signal shift_enable : std_logic := '0';
    signal SCLK         : std_logic := '0';
    signal MISO         : std_logic := '0';
    signal reset        : std_logic := '0';
    signal MOSI         : std_logic;
    signal data_Rx      : std_logic_vector(15 downto 0);

    -- Clock constant
    constant SCLK_PERIOD : time := 100 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: SPI_ShiftRegister
        port map (
            data_Tx      => data_Tx,
            shift_enable => shift_enable,
            SCLK         => SCLK,
            MISO         => MISO,
            reset        => reset,
            MOSI         => MOSI,
            data_Rx      => data_Rx
        );

    -- SCLK generation
    sclk_process : process
    begin
        SCLK <= '0';
        wait for SCLK_PERIOD/2;
        SCLK <= '1';
        wait for SCLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- 1. Global Reset
        reset <= '1';
        data_Tx <= x"A5A5"; -- Test pattern to load 10100101...
        wait for 120 ns;
        reset <= '0';
        wait for SCLK_PERIOD;

        -- 2. Start Shifting (Simulating 16 bits)
        shift_enable <= '1';
        
        -- Bit 1: MISO is 1
        MISO <= '1'; wait for SCLK_PERIOD;
        -- Bit 2: MISO is 0
        MISO <= '0'; wait for SCLK_PERIOD;
        -- Bit 3: MISO is 1
        MISO <= '1'; wait for SCLK_PERIOD;
        
        -- Simulate remaining 13 bits with a simple loop
        for i in 1 to 13 loop
            MISO <= not MISO; -- Toggle MISO for variety
            wait for SCLK_PERIOD;
        end loop;

        -- 3. End Shifting
        shift_enable <= '0';
        
        wait for 200 ns;
        -- Stop simulation
        assert false report "Simulation Finished" severity failure;
        wait;
    end process;

end architecture;
