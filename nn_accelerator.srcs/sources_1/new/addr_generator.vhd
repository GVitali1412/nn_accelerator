library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity addr_generator is
    generic (
        KERNEL_SIZE     : positive := 9;
        FILTER_DEPTH    : positive := 1;
        MAP_SIZE        : positive := 13 * 13
    );
    port (
        clk             : in std_logic;
        i_kernelPos     : in natural range 0 to KERNEL_SIZE + 2;
        i_filterCount   : in natural range 0 to FILTER_DEPTH - 1;
        i_mapPos        : in natural range 0 to MAP_SIZE - 1;
        o_inBramAddr    : out std_logic_vector(17 downto 0);
        o_outBramAddr   : out std_logic_vector(8 downto 0);
        o_wgsBramAddr   : out std_logic_vector(8 downto 0)
    );
end addr_generator;

architecture arch of addr_generator is

    signal s_offset         : integer range -16 to 16;

begin

    with i_kernelPos select
        s_offset <= -16 when 0,
                    -15 when 1,
                    -14 when 2,
                    -1  when 3,
                     0  when 4,
                     1  when 5,
                     14 when 6,
                     15 when 7,
                     16 when 8,
                     0  when others;
    
    o_inBramAddr  <= std_logic_vector(to_unsigned(i_mapPos + s_offset, 18));
    o_outBramAddr <= std_logic_vector(to_unsigned(i_mapPos, 9));
    o_wgsBramAddr <= std_logic_vector(to_unsigned(i_kernelPos, 9));

end arch;
