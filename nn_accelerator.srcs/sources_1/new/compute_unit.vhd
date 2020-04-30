library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity compute_unit is
    generic (DATA_WIDTH : positive := 8);
    port (
        clk             : in std_logic;
        i_clearAccum    : in std_logic;
        i_loadPartSum   : in std_logic;
        i_enActivation  : in std_logic;
        i_value         : in signed(DATA_WIDTH-1 downto 0);
        i_weight        : in signed(DATA_WIDTH-1 downto 0);
        i_partialSumIn  : in signed(DATA_WIDTH-1 downto 0); 
        o_result        : out signed(DATA_WIDTH-1 downto 0)
    );
end compute_unit;

architecture arch of compute_unit is

    attribute use_dsp : string;
    attribute use_dsp of arch : architecture is "yes";

    signal r_value          : signed(DATA_WIDTH-1 downto 0);
    signal r_weight         : signed(DATA_WIDTH-1 downto 0);
    signal r_partialSumIn   : signed(DATA_WIDTH-1 downto 0);
    signal r_accumulator    : signed(2*DATA_WIDTH-1 downto 0);
    signal s_activation     : signed(DATA_WIDTH-1 downto 0);
    signal s_partialSumOut  : signed(DATA_WIDTH-1 downto 0);

begin

    -- Register the input value and the weight
    process (clk)
    begin
        if rising_edge(clk) then
            r_value <= i_value;
            r_weight <= i_weight;
            r_partialSumIn <= i_partialSumIn;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            -- Clear the accumulator
            if i_clearAccum = '1' then
                r_accumulator <= r_value * r_weight;
            elsif i_loadPartSum = '1' then
                r_accumulator <= r_partialSumIn + (r_value * r_weight);
            else
                r_accumulator <= r_accumulator + (r_value * r_weight);
            end if;
        end if;
    end process;

    -- Rectifier activation function
    s_activation <= "00000000" when r_accumulator < 0
                        else
                    "01111111" when r_accumulator > 1023  -- Saturate overflow
                        else
                    r_accumulator(10 downto 3);  -- Fixed precision, 3 fractional bits
    
    s_partialSumOut <= "10000000" when r_accumulator < -1024  -- Saturate underflow
                            else
                       "01111111" when r_accumulator > 1023  -- Saturate overflow
                            else                    
                       r_accumulator(10 downto 3);  -- Fixed precision, 3 fractional bits

    o_result <= s_activation when i_enActivation = '1' 
                    else
                s_partialSumOut;

end arch;
