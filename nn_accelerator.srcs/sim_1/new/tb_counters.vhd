library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tb_counters is
--  port ( );
end tb_counters;

architecture tb of tb_counters is

    component counters is
        generic (
            KERNEL_SIZE     : positive := 9;
            MAX_N_CHANNELS  : positive := 1024;
            N_ROWS          : positive := 13;
            N_COLUMNS       : positive := 13;
            MAP_SIZE        : positive := N_ROWS * N_COLUMNS
        );
        port (
            clk             : in std_logic;
            i_start         : in std_logic;
            i_nChannels     : in unsigned(9 downto 0);
            o_weightIdx     : out natural range 0 to KERNEL_SIZE - 1;
            o_channelIdx    : out natural range 0 to MAX_N_CHANNELS - 1;
            o_mapIdx        : out natural range 0 to MAP_SIZE - 1;
            o_mapIdxOld     : out natural range 0 to MAP_SIZE - 1;
            o_save          : out std_logic;
            o_done          : out std_logic
        );
    end component;

    constant clock_period   : time := 10 ns;
    constant KERNEL_SIZE    : positive := 9;
    constant MAX_N_CHANNELS : positive := 1024;
    constant MAP_SIZE       : positive := 13 * 13;
    
    signal clk              : std_logic := '0';
    signal start            : std_logic := '0';
    signal s_nChannels      : unsigned(9 downto 0);
    signal s_weightIdx      : natural range 0 to KERNEL_SIZE - 1;
    signal s_channelIdx     : natural range 0 to MAX_N_CHANNELS - 1;
    signal s_mapIdx         : natural range 0 to MAP_SIZE - 1;
    signal s_mapIdxOld      : natural range 0 to MAP_SIZE - 1;
    signal s_save           : std_logic;

begin

    UUT : counters
    port map (
        clk             => clk,
        i_start         => start,
        i_nChannels     => s_nChannels,
        o_weightIdx     => s_weightIdx,
        o_channelIdx    => s_channelIdx,
        o_mapIdx        => s_mapIdx,
        o_mapIdxOld     => s_mapIdxOld,
        o_save          => s_save
    );

    clock_gen : process is
    begin
        wait for clock_period/2;
        clk <= not clk;
    end process;

    -- 20 input channels
    s_nChannels <= to_unsigned(19, 10);

    test : process is
    begin
        wait for clock_period * 2;
        start <= '1';
        wait for clock_period;
        start <= '0';
        wait for 1000 ms;
    end process;

end tb;
