library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counters is
    generic (
        KERNEL_SIZE     : positive := 9;
        FILTER_DEPTH    : positive := 1;
        X_LENGTH        : positive := 13;
        Y_LENGTH        : positive := 13;
        MAP_SIZE        : positive := (X_LENGTH+2) * (Y_LENGTH+2)
    );
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        o_kernelPos     : out natural range 0 to KERNEL_SIZE + 2;
        o_filterCount   : out natural range 0 to FILTER_DEPTH - 1;
        o_mapPos        : out natural range 0 to MAP_SIZE - 1
    );
end counters;

architecture arch of counters is

    signal s_kernelPos      : natural range 0 to KERNEL_SIZE + 2;
    signal s_filterCount    : natural range 0 to FILTER_DEPTH - 1;
    signal s_mapPos         : natural range 0 to MAP_SIZE - 1;
    signal s_xPos           : natural range 0 to X_LENGTH - 1;
    signal s_yPos           : natural range 0 to Y_LENGTH - 1;

begin

    o_kernelPos <= s_kernelPos;
    o_filterCount <= 0;  -- TODO: for now only one kernel per filter
    o_mapPos <= s_mapPos;

    -- Update 'kernel' position
    process (clk)
    begin
        if rising_edge(clk) then
            if i_start = '1' or s_kernelPos = KERNEL_SIZE+2 then
                s_kernelPos <= 0;
            else
                s_kernelPos <= s_kernelPos + 1;
            end if;
        end if;
    end process;

    -- Update 'x' and 'y' position
    process (clk) 
    begin
        if rising_edge(clk) then
            if i_start = '1' then
                s_xPos <= 0;
                s_yPos <= 0;
            elsif s_kernelPos = KERNEL_SIZE+2 then
                if s_xPos = X_LENGTH-1 then  -- Row completed
                    s_xPos <= 0;
                    if s_yPos = Y_LENGTH-1 then  -- Go back to the first row
                        s_yPos <= 0;
                    else                         -- Go to the next row
                        s_yPos <= s_yPos + 1;
                    end if;
                else                         -- Continue to the same row
                    s_xPos <= s_xPos + 1;
                end if;
            end if;
        end if;
    end process;

    -- Update 'map' position
    process (clk)
    begin
        if rising_edge(clk) then
            if i_start = '1' then
                s_mapPos <= 16;  -- Initial position
            elsif s_kernelPos = KERNEL_SIZE+2 then
                if s_xPos = X_LENGTH-1 and s_yPos = Y_LENGTH-1 then
                    s_mapPos <= 16;
                elsif s_xPos = X_LENGTH-1 then
                    s_mapPos <= s_mapPos + 3;  -- Jump to the next row
                else
                    s_mapPos <= s_mapPos + 1;
                end if;
            end if;
        end if;
    end process;

end arch;
