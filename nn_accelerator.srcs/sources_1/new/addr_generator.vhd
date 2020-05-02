library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity addr_generator is
    generic (
        KERNEL_SIZE     : positive := 9;
        MAX_N_CHANNELS  : positive := 1024;
        MAP_SIZE        : positive := 13 * 13
    );
    port (
        clk             : in std_logic;
        i_weightIdx     : in natural range 0 to KERNEL_SIZE - 1;
        i_channelIdx    : in natural range 0 to MAX_N_CHANNELS - 1;
        i_mapIdx        : in natural range 0 to MAP_SIZE - 1;
        i_mapIdxOld     : in natural range 0 to MAP_SIZE - 1;
        o_inBufAddr     : out std_logic_vector(17 downto 0);
        o_wgsBufAddr    : out std_logic_vector(8 downto 0);
        o_psumBufAddr   : out std_logic_vector(8 downto 0);
        o_outBufAddr    : out std_logic_vector(8 downto 0)
    );
end addr_generator;

architecture arch of addr_generator is

    signal s_offset         : integer range -16 to 16;
    signal r_inBufAddr      : std_logic_vector(17 downto 0);
    signal r_wgsBufAddr     : std_logic_vector(8 downto 0);
    signal r_psumBufAddr    : std_logic_vector(8 downto 0);
    signal r_outBufAddr     : std_logic_vector(8 downto 0);

begin

    with i_weightIdx select
        s_offset <= -14 when 0,
                    -13 when 1,
                    -12 when 2,
                    -1  when 3,
                     0  when 4,
                     1  when 5,
                     12 when 6,
                     13 when 7,
                     14 when 8,
                     0  when others;

    process (clk)
    begin
        if rising_edge(clk) then
            r_inBufAddr  <= std_logic_vector(to_unsigned(
                                                i_mapIdx
                                                + (i_channelIdx * MAP_SIZE)
                                                + s_offset, 18));

            r_wgsBufAddr <= std_logic_vector(to_unsigned(
                                                i_weightIdx 
                                                + (i_channelIdx * KERNEL_SIZE)
                                                , 9));

            r_psumBufAddr <= std_logic_vector(to_unsigned(i_mapIdx, 9));

            r_outBufAddr <= std_logic_vector(to_unsigned(i_mapIdxOld, 9));
        end if;
    end process;
    
    o_inBufAddr  <= r_inBufAddr;
    o_wgsBufAddr <= r_wgsBufAddr;
    o_psumBufAddr <= r_psumBufAddr;
    o_outBufAddr <= r_outBufAddr;

end arch;
