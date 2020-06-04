library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity convolution_engine is
    generic (
        DATA_WIDTH      : positive := 8;
        NUMBER_CU       : positive := 128
    );
    port ( 
        clk             : in std_logic;
        i_stall         : in std_logic;
        i_clearAccum    : in std_logic;
        i_loadPartSum   : in std_logic;
        i_enActivation  : in std_logic;
        i_inBufData     : in std_logic_vector(7 downto 0);
        i_wgsBufData    : in std_logic_vector(1023 downto 0);
        i_psumBufData   : in std_logic_vector(1023 downto 0);
        o_outBufData    : out std_logic_vector(1023 downto 0)
    );
end convolution_engine;

architecture arch of convolution_engine is

    signal r_stallDelayed   : std_logic;

begin

    convolution_units : for i in 0 to NUMBER_CU-1 generate
        cu : entity work.compute_unit
        port map (
            clk             => clk,
            i_stall         => r_stallDelayed,
            i_clearAccum    => i_clearAccum,
            i_loadPartSum   => i_loadPartSum,
            i_enActivation  => i_enActivation,
            i_value         => signed(i_inBufData),
            i_weight        => signed(i_wgsBufData(DATA_WIDTH*(i+1)-1 
                                                   downto DATA_WIDTH*i)),
            i_partialSumIn  => signed(i_psumBufData(DATA_WIDTH*(i+1)-1 
                                                    downto DATA_WIDTH*i)),
            std_logic_vector(o_result) => 
                o_outBufData(DATA_WIDTH*(i+1)-1 downto DATA_WIDTH*i)
        );
    end generate;

    extra_output : if NUMBER_CU*DATA_WIDTH < 1024 generate
        o_outBufData(1023 downto NUMBER_CU*DATA_WIDTH) <= (others => '0');
    end generate;

    -- The stall signal for the CUs must be delayed by one clock
    -- (to account for the latency of the bram buffers)
    process (clk)
    begin
        if rising_edge(clk) then
            r_stallDelayed <= i_stall;
        end if;
    end process;

end arch;
