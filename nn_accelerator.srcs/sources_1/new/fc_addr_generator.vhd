library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_constants.all;


entity fc_addr_generator is
    port (
        clk             : in std_logic;
        i_stall         : in std_logic;
        i_inBaseAddr    : in unsigned(16 downto 0);
        i_wsBaseAddr    : in unsigned(10 downto 0);
        i_psBaseAddr    : in unsigned(8 downto 0);
        i_outBaseAddr   : in unsigned(8 downto 0);
        i_nWeights      : in unsigned(MAX_BITS_FC_WEIGHTS-1 downto 0);
        i_weightIdx     : in unsigned(MAX_BITS_FC_WEIGHTS-1 downto 0);
        i_neuronIdx     : in unsigned(MAX_BITS_FC_NEURONS-1 downto 0);
        i_neuronIdxOld  : in unsigned(MAX_BITS_FC_NEURONS-1 downto 0);
        o_inBufAddr     : out std_logic_vector(16 downto 0);
        o_wsBufAddr     : out std_logic_vector(10 downto 0);
        o_psBufAddr     : out std_logic_vector(8 downto 0);
        o_outBufAddr    : out std_logic_vector(8 downto 0)
    );
end fc_addr_generator;

architecture arch of fc_addr_generator is

    signal r_inBufAddrPipe  : unsigned(8 downto 0);
    signal r_wsBufAddrPipe  : unsigned(10 downto 0);
    signal r_psBufAddrPipe  : std_logic_vector(8 downto 0);
    signal r_outBufAddrPipe : std_logic_vector(8 downto 0);

    signal r_inBufAddr      : std_logic_vector(16 downto 0);
    signal r_wsBufAddr      : std_logic_vector(10 downto 0);
    signal r_psBufAddr      : std_logic_vector(8 downto 0);
    signal r_outBufAddr     : std_logic_vector(8 downto 0);

begin

    process (clk)
    begin
        if rising_edge(clk) then 
            if i_stall = '0' then
                r_inBufAddrPipe <= i_weightIdx;
                r_inBufAddr <= std_logic_vector(i_inBaseAddr + r_inBufAddrPipe);

                r_wsBufAddrPipe <= i_nWeights * i_neuronIdx + i_weightIdx;
                r_wsBufAddr <= std_logic_vector(i_wsBaseAddr + r_wsBufAddrPipe);

                r_psBufAddrPipe <= std_logic_vector(i_psBaseAddr + i_neuronIdx);
                r_psBufAddr <= r_psBufAddrPipe;

                r_outBufAddrPipe <= std_logic_vector(i_outBaseAddr + i_neuronIdxOld);
                r_outBufAddr <= r_outBufAddrPipe;
            end if;
        end if;
    end process;

    o_inBufAddr <= r_inBufAddr;
    o_wsBufAddr <= r_wsBufAddr;
    o_psBufAddr <= r_psBufAddr;
    o_outBufAddr <= r_outBufAddr;

end arch;
