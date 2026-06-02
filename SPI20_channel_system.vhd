Library IEEE;
use IEEE.std_logic_1164.all;


Entity SPI20_channel_system is

    port(
        -- since I use 8 bits and we have 20 channels, 20*8 = 160 bits, so I need 160 bits to 
        --store the data of all channels, and then I can send those 160 bits to 
        --the shift register and send them bit by bit to the slave
        -- 160 bits = 20 bytes = 20 channels * 8 bits per channel

        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;

        data_tx20 : in std_logic_vector(159 downto 0); --load the 20 channels data to the shift register
        --then copy those 160 bits into the memory at once. Then on every SCLK_stroble the
        -- sift register moves the bits onr position to the left. (send bit by bit to MOSI pin)

        -- 20 independents control/data pins
        sclk : out std_logic;
        cs_n : out std_logic_vector(19 downto 0); --chip select, toggle the signal active low
        mosin20 : out std_logic_vector(19 downto 0);
        miso20 : in std_logic_vector(19 downto 0); 
        
        --20 independents status and rx data for each channel
        data_rx20 : out std_logic_vector(159 downto 0); --when the master is pushing bit out on MOSI pin
                        --so, in the same clk cycle which is SCLK_stroble it send to MISO pin and samples data
                                -- whatever level 0 or 1 and pushed it to the right
                                --then the FSM send signals that the data is ready, and fpga can read all 160 bits
                                --from the data_rx bus simultaneously
        busy : out std_logic_vector(19 downto 0);
        data_ready : out std_logic_vector(19 downto 0)             
    );
end SPI20_channel_system;    


Architecture rtl20_spi_master of SPI20_channel_system is

    signal w_sclk_shared : std_logic_vector(19 downto 0);

    begin
        
        gen20_master : for i in 0 to 19 generate
            master_inst : entity work.spi_master_topLevel
                port map (
                        clk => clk,
                        reset => reset,
                        start => start,

                        --slice the 160 bits bus into 20 channels, each channel has 8 bits, so I need to select the 8 bits for each channel
                        data_tx => data_tx20((i+1)*8-1 downto (i*8)), --select the 8 bits for each channel
                        data_rx => data_rx20((i+1)*8-1 downto (i*8)), --select the 8 bits for each channel

                        miso => miso20(i),
                        mosi => mosin20(i),
                        cs_n => cs_n(i),

                        sclk => w_sclk_shared(i), --share the same SCLK signal for all channels

                        --status and data ready signals for each channel
                        busy => busy(i),
                        data_ready => data_ready(i)

                );
        end generate gen20_master;

            sclk <= w_sclk_shared(0);


end rtl20_spi_master;