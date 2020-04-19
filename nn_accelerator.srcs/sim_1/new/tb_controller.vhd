library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity tb_controller is
--  port ( );
end tb_controller;

architecture tb of tb_controller is

    component controller is
        generic (
            KERNEL_SIZE     : positive := 9;
            FILTER_DEPTH    : positive := 1;
            MAP_SIZE        : positive := 13 * 13
        );
        port (
            clk             : in std_logic;
            i_start         : in std_logic;
            o_clearAccum    : out std_logic;
            o_inBramEn      : out std_logic;
            o_inBramAddr    : out std_logic_vector(17 downto 0);
            o_outBramEn     : out std_logic;
            o_outBramWe     : out std_logic;
            o_outBramAddr   : out std_logic_vector(8 downto 0);
            o_wgsBramEn     : out std_logic;
            o_wgsBramAddr   : out std_logic_vector(8 downto 0)
        );
    end component;

    constant clock_period   : time := 10 ns;
    signal clk              : std_logic := '0';
    signal start            : std_logic := '0';
    
    signal s_clearAccum     : std_logic;
    signal s_inBramEn       : std_logic;
    signal s_inBramAddr     : std_logic_vector(17 downto 0);
    signal s_outBramEn      : std_logic;
    signal s_outBramWe      : std_logic;
    signal s_outBramAddr    : std_logic_vector(8 downto 0);
    signal s_wgsBramEn      : std_logic;
    signal s_wgsBramAddr    : std_logic_vector(8 downto 0);
    
begin

    UUT : controller
    port map (
        clk             => clk,
        i_start         => start,
        o_clearAccum    => s_clearAccum,
        o_inBramEn      => s_inBramEn,
        o_inBramAddr    => s_inBramAddr,
        o_outBramEn     => s_outBramEn,
        o_outBramWe     => s_outBramWe,
        o_outBramAddr   => s_outBramAddr,
        o_wgsBramEn     => s_wgsBramEn,
        o_wgsBramAddr   => s_wgsBramAddr
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
