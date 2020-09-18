library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_constants.all;


entity conv_controller is
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
        i_stall         : in std_logic;

        i_mapSize       : in unsigned(15 downto 0);
        i_lastChanIdx   : in unsigned(9 downto 0);
        i_nMapRows      : in unsigned(7 downto 0);
        i_nMapColumns   : in unsigned(7 downto 0);

        i_inBaseAddr    : in unsigned(16 downto 0);
        i_wsBaseAddr    : in unsigned(10 downto 0);
        i_psBaseAddr    : in unsigned(8 downto 0);
        i_outBaseAddr   : in unsigned(8 downto 0);

        o_inBufAddr     : out std_logic_vector(16 downto 0);
        o_wsBufAddr     : out std_logic_vector(10 downto 0);
        o_psBufAddr     : out std_logic_vector(8 downto 0);
        o_outBufAddr    : out std_logic_vector(8 downto 0);

        o_save          : out std_logic;
        o_done          : out std_logic
    );
end conv_controller;

architecture arch of conv_controller is

    signal s_weightIdx      : natural range 0 to KERNEL_SIZE - 1;
    signal s_channelIdx     : natural range 0 to MAX_N_CHANNELS - 1;
    signal s_mapIdx         : natural range 0 to MAX_MAP_SIZE - 1;
    signal s_mapIdxOld      : natural range 0 to MAX_MAP_SIZE - 1;

begin

    counters : entity work.conv_counters
    port map (
        clk             => clk,
        i_start         => i_start,
        i_stall         => i_stall,
        i_lastChanIdx   => i_lastChanIdx,
        i_nMapRows      => i_nMapRows,
        i_nMapColumns   => i_nMapColumns,
        o_weightIdx     => s_weightIdx,
        o_channelIdx    => s_channelIdx,
        o_mapIdx        => s_mapIdx,
        o_mapIdxOld     => s_mapIdxOld,
        o_save          => o_save,
        o_done          => o_done
    );

    addresses_generator : entity work.conv_addr_generator
    port map (
        clk             => clk,
        i_stall         => i_stall,
        i_inBaseAddr    => i_inBaseAddr,
        i_wgsBaseAddr   => i_wsBaseAddr,
        i_psumBaseAddr  => i_psBaseAddr,
        i_outBaseAddr   => i_outBaseAddr,
        i_weightIdx     => s_weightIdx,
        i_channelIdx    => s_channelIdx,
        i_mapIdx        => s_mapIdx,
        i_mapIdxOld     => s_mapIdxOld,
        i_mapSize       => i_mapSize,
        i_nMapColumns   => i_nMapColumns,
        o_inBufAddr     => o_inBufAddr,
        o_wgsBufAddr    => o_wsBufAddr,
        o_psumBufAddr   => o_psBufAddr,
        o_outBufAddr    => o_outBufAddr
    );

end arch;
