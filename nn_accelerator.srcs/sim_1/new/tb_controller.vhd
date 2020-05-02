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
            N_CHANNELS      : positive := 8;
            MAP_SIZE        : positive := 13 * 13
        );
        port (
            clk             : in std_logic;

            -- AXI control registers
            i_ctrlReg0      : in std_logic_vector(31 downto 0);
            i_ctrlReg1      : in std_logic_vector(31 downto 0);
            i_ctrlReg2      : in std_logic_vector(31 downto 0);
            i_ctrlReg3      : in std_logic_vector(31 downto 0);
            o_rstCtrlReg    : out std_logic;
    
            o_clearAccum    : out std_logic;
            o_loadPartSum   : out std_logic;
    
            -- in buffer
            o_inBufEn       : out std_logic;
            o_inBufAddr     : out std_logic_vector(17 downto 0);
    
            -- weights buffer
            o_wgsBufEn      : out std_logic;
            o_wgsBufAddr    : out std_logic_vector(8 downto 0);
    
            -- partial sums buffer
            o_psumBufEn     : out std_logic;
            o_psumBufAddr   : out std_logic_vector(8 downto 0);
    
            -- out buffer
            o_outBufEn      : out std_logic;
            o_outBufWe      : out std_logic;
            o_outBufAddr    : out std_logic_vector(8 downto 0)
        );
    end component;

    constant clock_period   : time := 10 ns;
    signal clk              : std_logic := '0';
    
    signal s_ctrlReg0       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ctrlReg1       : std_logic_vector(31 downto 0);
    signal s_ctrlReg2       : std_logic_vector(31 downto 0);
    signal s_ctrlReg3       : std_logic_vector(31 downto 0);
    signal s_rstCtrlReg     : std_logic;
    
    signal s_clearAccum     : std_logic;
    signal s_loadPartSum    : std_logic;
    
    signal s_inBufEn       : std_logic;
    signal s_inBufAddr     : std_logic_vector(17 downto 0);
    signal s_wgsBufEn      : std_logic;
    signal s_wgsBufAddr    : std_logic_vector(8 downto 0);
    signal s_psumBufEn      : std_logic;
    signal s_psumBufAddr    : std_logic_vector(8 downto 0);
    signal s_outBufEn      : std_logic;
    signal s_outBufWe      : std_logic;
    signal s_outBufAddr    : std_logic_vector(8 downto 0);
    
begin

    UUT : controller
    port map (
        clk             => clk,
        i_ctrlReg0      => s_ctrlReg0,
        i_ctrlReg1      => s_ctrlReg1,
        i_ctrlReg2      => s_ctrlReg2,
        i_ctrlReg3      => s_ctrlReg3,
        o_rstCtrlReg    => s_rstCtrlReg,
        o_clearAccum    => s_clearAccum,
        o_loadPartSum   => s_loadPartSum,
        o_inBufEn       => s_inBufEn,
        o_inBufAddr     => s_inBufAddr,
        o_wgsBufEn      => s_wgsBufEn,
        o_wgsBufAddr    => s_wgsBufAddr,
        o_psumBufEn     => s_psumBufEn,
        o_psumBufAddr   => s_psumBufAddr,
        o_outBufEn      => s_outBufEn,
        o_outBufWe      => s_outBufWe,
        o_outBufAddr    => s_outBufAddr
    );

    clock_gen : process is
    begin
        wait for clock_period/2;
        clk <= not clk;
    end process;

    test : process is
    begin
        wait for clock_period * 8;
        s_ctrlReg0 <= (0 => '1', others => '0');
        wait for 1000 ms;
    end process;

end tb;
