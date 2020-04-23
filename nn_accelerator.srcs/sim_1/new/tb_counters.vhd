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
            FILTER_DEPTH    : positive := 8;
            X_LENGTH        : positive := 13;
            Y_LENGTH        : positive := 13;
            MAP_SIZE        : positive := X_LENGTH * Y_LENGTH
        );
        port (
            clk             : in std_logic;
            i_start         : in std_logic;
            o_kernelIdx     : out natural range 0 to KERNEL_SIZE - 1;
            o_filterIdx     : out natural range 0 to FILTER_DEPTH - 1;
            o_mapIdx        : out natural range 0 to MAP_SIZE - 1;
            o_save          : out std_logic
        );
    end component;

    constant clock_period   : time := 10 ns;
    signal clk              : std_logic := '0';
    signal start            : std_logic := '0';
    signal s_kernelIdx      : natural range 0 to 8;
    signal s_filterIdx      : natural range 0 to 0;
    signal s_mapIdx         : natural range 0 to 168;
    signal s_save           : std_logic;

begin

    UUT : counters
    port map (
        clk             => clk,
        i_start         => start,
        o_kernelIdx     => s_kernelIdx,
        o_filterIdx     => s_filterIdx,
        o_mapIdx        => s_mapIdx,
        o_save          => s_save
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
