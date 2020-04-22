library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity controller is
    generic (
        KERNEL_SIZE     : positive := 9;
        FILTER_DEPTH    : positive := 1;
        MAP_SIZE        : positive := 13 * 13
    );
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        o_clearAccum    : out std_logic;

        -- in bram
        o_inBramEn      : out std_logic;
        o_inBramAddr    : out std_logic_vector(17 downto 0);

        -- out bram
        o_outBramEn     : out std_logic;
        o_outBramWe     : out std_logic;
        o_outBramAddr   : out std_logic_vector(8 downto 0);

        -- weights bram
        o_wgsBramEn     : out std_logic;
        o_wgsBramAddr   : out std_logic_vector(8 downto 0)
    );
end controller;

architecture arch of controller is

    type state_type is (IDLE, PIPE_FILL, COMPUTE, LAST);
    signal fsm_state        : state_type := IDLE;

    signal s_kernelIdx      : natural range 0 to KERNEL_SIZE - 1;
    signal s_filterIdx      : natural range 0 to FILTER_DEPTH - 1;
    signal s_mapIdx         : natural range 0 to MAP_SIZE - 1;
    signal s_save           : std_logic;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            case fsm_state is
                when IDLE =>
                    if i_start = '1' then fsm_state <= PIPE_FILL;
                    end if;
                when PIPE_FILL =>
                    if s_mapIdx = 1 then fsm_state <= COMPUTE;
                    end if;
                when COMPUTE =>
                    if s_mapIdx = MAP_SIZE-1 and s_save = '1' then 
                        fsm_state <= LAST;
                    end if;
                when LAST =>
                    if s_save = '1' then fsm_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;


    o_inBramEn <= '1';

    o_outBramEn <= '1' when fsm_state = COMPUTE or fsm_state = LAST
                   else '0';

    o_outBramWe <= '1' when s_save = '1'
                   else '0';

    o_wgsBramEn <= '1';

    o_clearAccum <= '1' when s_save = '1'
                    else '0';


    counters : entity work.counters
    port map (
        clk             => clk,
        i_start         => i_start,
        o_kernelIdx     => s_kernelIdx,
        o_filterIdx     => s_filterIdx,
        o_mapIdx        => s_mapIdx,
        o_save          => s_save
    );

    addresses_generator : entity work.addr_generator
    port map (
        clk             => clk,
        i_kernelIdx     => s_kernelIdx,
        i_filterIdx     => s_filterIdx,
        i_mapIdx        => s_mapIdx,
        o_inBramAddr    => o_inBramAddr,
        o_outBramAddr   => o_outBramAddr,
        o_wgsBramAddr   => o_wgsBramAddr
    );

end arch;
