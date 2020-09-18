library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_constants.all;


entity fc_controller is
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        i_stall         : in std_logic;

        i_nWeights      : in unsigned(MAX_BITS_FC_WEIGHTS-1 downto 0);
        i_nNeurons      : in unsigned(MAX_BITS_FC_NEURONS-1 downto 0);
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
end fc_controller;

architecture arch of fc_controller is

    signal s_weightIdx      : unsigned(MAX_BITS_FC_WEIGHTS-1 downto 0);
    signal s_neuronIdx      : unsigned(MAX_BITS_FC_NEURONS-1 downto 0);
    signal s_neuronIdxOld   : unsigned(MAX_BITS_FC_NEURONS-1 downto 0);

begin

    counters : entity work.fc_counters
    port map (
        clk             => clk,
        i_start         => i_start,
        i_stall         => i_stall,
        i_nWeights      => i_nWeights,
        i_nNeurons      => i_nNeurons,
        o_weightIdx     => s_weightIdx,
        o_neuronIdx     => s_neuronIdx,
        o_neuronIdxOld  => s_neuronIdxOld,
        o_save          => o_save,
        o_done          => o_done
    );

    addresses_generator : entity work.fc_addr_generator
    port map (
        clk             => clk,
        i_stall         => i_stall,
        i_inBaseAddr    => i_inBaseAddr,
        i_wsBaseAddr    => i_wsBaseAddr,
        i_psBaseAddr    => i_psBaseAddr,
        i_outBaseAddr   => i_outBaseAddr,
        i_nWeights      => i_nWeights,
        i_weightIdx     => s_weightIdx,
        i_neuronIdx     => s_neuronIdx,
        i_neuronIdxOld  => s_neuronIdxOld,
        o_inBufAddr     => o_inBufAddr,
        o_wsBufAddr     => o_wsBufAddr,
        o_psBufAddr     => o_psBufAddr,
        o_outBufAddr    => o_outBufAddr
    );


end arch;
