library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity compute_unit is
    generic (DATA_WIDTH : positive := 8);
    port (
        clk             : in std_logic;
        i_clearAccum    : in std_logic;
        i_value         : in signed(DATA_WIDTH-1 downto 0);
        i_weight        : in signed(DATA_WIDTH-1 downto 0);
        o_result        : out signed(DATA_WIDTH-1 downto 0)
    );
end compute_unit;

architecture arch of compute_unit is

    signal r_value          : signed(DATA_WIDTH-1 downto 0);
    signal r_weight         : signed(DATA_WIDTH-1 downto 0);
    signal r_accumulator    : signed(2*DATA_WIDTH-1 downto 0);

begin

    -- Register the input value and the weight
    process (clk)
    begin
        if rising_edge(clk) then
            r_value <= i_value;
            r_weight <= i_weight;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            -- Clear the accumulator
            if i_clearAccum = '1' then
                r_accumulator <= (others => '0');
            else
                r_accumulator <= r_accumulator + (r_value * r_weight);
            end if;
        end if;
    end process;

    -- TODO: check for overflow/underflow -> saturate the output
    o_result <= r_accumulator(DATA_WIDTH-1 downto 0);

end arch;
