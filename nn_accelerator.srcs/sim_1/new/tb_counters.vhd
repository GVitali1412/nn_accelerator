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
            MAX_N_MAP_ROWS  : positive := 256;
            MAX_N_MAP_COL   : positive := 256;
            MAX_MAP_SIZE    : positive := 256 * 256
        );
        port (
            clk             : in std_logic;
            i_start         : in std_logic;
            i_lastChanIdx   : in unsigned(9 downto 0);
            i_nMapRows      : in unsigned(7 downto 0);
            i_nMapColumns   : in unsigned(7 downto 0);
            o_weightIdx     : out natural range 0 to KERNEL_SIZE - 1;
            o_channelIdx    : out natural range 0 to MAX_N_CHANNELS - 1;
            o_mapIdx        : out natural range 0 to MAX_MAP_SIZE - 1;
            o_mapIdxOld     : out natural range 0 to MAX_MAP_SIZE - 1;
            o_save          : out std_logic;
            o_done          : out std_logic
        );
    end component;

    constant clock_period   : time := 10 ns;
    constant KERNEL_SIZE    : positive := 9;
    constant MAX_N_CHANNELS : positive := 1024;
    constant MAX_MAP_SIZE   : positive := 256 * 256;
    
    signal clk              : std_logic := '0';
    signal start            : std_logic := '0';
    signal s_lastChanIdx    : unsigned(9 downto 0);
    signal s_nMapRows       : unsigned(7 downto 0);
    signal s_nMapColumns    : unsigned(7 downto 0);
    signal s_weightIdx      : natural range 0 to KERNEL_SIZE - 1;
    signal s_channelIdx     : natural range 0 to MAX_N_CHANNELS - 1;
    signal s_mapIdx         : natural range 0 to MAX_MAP_SIZE - 1;
    signal s_mapIdxOld      : natural range 0 to MAX_MAP_SIZE - 1;
    signal s_save           : std_logic;
    signal s_done           : std_logic;

begin

    UUT : counters
    port map (
        clk             => clk,
        i_start         => start,
        i_lastChanIdx   => s_lastChanIdx,
        i_nMapRows      => s_nMapRows,
        i_nMapColumns   => s_nMapColumns,
        o_weightIdx     => s_weightIdx,
        o_channelIdx    => s_channelIdx,
        o_mapIdx        => s_mapIdx,
        o_mapIdxOld     => s_mapIdxOld,
        o_save          => s_save,
        o_done          => s_done 
    );

    clock_gen : process is
    begin
        wait for clock_period/2;
        clk <= not clk;
    end process;

    -- 20 input channels
    s_lastChanIdx <= to_unsigned(19, 10);

    -- 13 x 13 input map
    s_nMapRows <= to_unsigned(12, 8);
    s_nMapColumns <= to_unsigned(12, 8);

    test : process is
    begin
        wait for clock_period * 2;
        start <= '1';
        wait for clock_period;
        start <= '0';
        wait for 1000 ms;
    end process;

end tb;
