library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.config_constants.all;


entity fc_counters is
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        i_stall         : in std_logic;
        i_nWeights      : in unsigned(MAX_BITS_FC_WEIGHTS-1 downto 0);
        i_nNeurons      : in unsigned(MAX_BITS_FC_NEURONS-1 downto 0);
        o_weightIdx     : out unsigned(MAX_BITS_FC_WEIGHTS-1 downto 0);
        o_neuronIdx     : out unsigned(MAX_BITS_FC_NEURONS-1 downto 0);
        o_neuronIdxOld  : out unsigned(MAX_BITS_FC_NEURONS-1 downto 0);
        o_save          : out std_logic;
        o_done          : out std_logic
    );
end fc_counters;

architecture arch of fc_counters is
    
    signal r_weightIdx      : natural range 0 to MAX_FC_WEIGHTS - 1;
    signal r_neuronIdx      : natural range 0 to MAX_FC_NEURONS - 1;
    signal r_neuronIdxOld   : natural range 0 to MAX_FC_NEURONS - 1;
    signal r_shiftSave      : std_logic_vector(4 downto 0);
    signal r_shiftDone      : std_logic_vector(4 downto 0);

begin

    o_weightIdx <= to_unsigned(r_weightIdx, o_weightIdx'length);
    o_neuronIdx <= to_unsigned(r_neuronIdx, o_neuronIdx'length);
    o_neuronIdxOld <= to_unsigned(r_neuronIdxOld, o_neuronIdxOld'length);
    o_save <= r_shiftSave(4);
    o_done <= r_shiftDone(4);

    process(clk)
    begin
        if rising_edge(clk) then
            if i_stall = '0' then
                if i_start = '1' then
                    r_weightIdx <= 0;
                    r_neuronIdx <= 0;
                    r_neuronIdxOld <= 0;
                    r_shiftSave <= "00001";
                    r_shiftDone <= "00000";

                elsif r_weightIdx = i_nWeights - 1 then
                    r_weightIdx <= 0;
                    r_neuronIdx <= r_neuronIdx + 1;
                    r_neuronIdxOld <= r_neuronIdx;
                    r_shiftSave <= r_shiftSave(3 downto 0) & '1';

                    if r_neuronIdx = i_nNeurons - 1 then
                        r_shiftDone <= r_shiftDone(3 downto 0) & '1';
                    else
                        r_shiftDone <= r_shiftDone(3 downto 0) & '0';
                    end if;
                
                else
                    r_weightIdx <= r_weightIdx + 1;
                    r_shiftSave <= r_shiftSave(3 downto 0) & '0';
                    r_shiftDone <= r_shiftDone(3 downto 0) & '0';
                end if;

            end if;
        end if; 
    end process;

end arch;
