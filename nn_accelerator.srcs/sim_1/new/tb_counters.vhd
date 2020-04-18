library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity tb_counters is
--  port ( );
end tb_counters;

architecture tb of tb_counters is

    component counters is
        generic (
            KERNEL_SIZE     : positive := 9;
            FILTER_DEPTH    : positive := 1;
            X_LENGTH        : positive := 13;
            Y_LENGTH        : positive := 13;
            MAP_SIZE        : positive := X_LENGTH * Y_LENGTH
        );
        port (
            clk             : in std_logic;
            i_start         : in std_logic;
            o_kernelPos     : out natural range 0 to KERNEL_SIZE + 2;
            o_filterCount   : out natural range 0 to FILTER_DEPTH - 1;
            o_mapPos        : out natural range 0 to MAP_SIZE - 1
        );
    end component;

    constant clock_period   : time := 10 ns;
    signal clk              : std_logic := '0';
    signal start            : std_logic := '0';
    signal s_kernelPos      : natural range 0 to 11;
    signal s_filterCount    : natural range 0 to 0;
    signal s_mapPos         : natural range 0 to 12;

begin

    UUT : counters
    port map (
        clk             => clk,
        i_start         => start,
        o_kernelPos     => s_kernelPos,
        o_filterCount   => s_filterCount,
        o_mapPos        => s_mapPos
    );

    clock_gen : process is
    begin
        wait for clock_period/2;
        clk <= not clk;
    end process;

    test : process is
    begin
        wait for clock_period * 2;
        start <= '1';
        wait for clock_period;
        start <= '0';
        wait for 1000 ms;
    end process;

end tb;
