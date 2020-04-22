library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counters is
    generic (
        KERNEL_SIZE     : positive := 9;
        FILTER_DEPTH    : positive := 1;
        X_LENGTH        : positive := 13;
        Y_LENGTH        : positive := 13;
        MAP_SIZE        : positive := X_LENGTH * Y_LENGTH
    );
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        o_kernelIdx     : out natural range 0 to KERNEL_SIZE - 1;
        o_filterIdx     : out natural range 0 to FILTER_DEPTH - 1;
        o_mapIdx        : out natural range 0 to MAP_SIZE - 1;
        o_save          : out std_logic
    );
end counters;

architecture arch of counters is

    type mapPos_type is (N, NE, E, SE, S, SW, W, NW, C);
    signal s_mapPos         : mapPos_type;

    signal s_kernelIdx      : natural range 0 to KERNEL_SIZE + 2;
    signal s_filterIdx      : natural range 0 to FILTER_DEPTH - 1;
    signal s_mapIdx         : natural range 0 to MAP_SIZE - 1;
    signal s_xPos           : natural range 0 to X_LENGTH - 1;
    signal s_yPos           : natural range 0 to Y_LENGTH - 1;

begin

    o_kernelIdx <= s_kernelIdx;
    o_filterIdx <= 0;  -- TODO: for now only one kernel per filter
    o_mapIdx <= s_mapIdx;

    process (clk)
    begin
        if rising_edge(clk) then
            if i_start = '1' then
                s_mapPos <= NW;
                s_kernelIdx <= 4;
                s_xPos <= 0;
                s_yPos <= 0;
                s_mapIdx <= 0;

            else
                case s_mapPos is

                    when NW =>  -- Top left corner
                        if s_kernelIdx = 8 then
                            s_kernelIdx <= 3;
                            s_xPos <= s_xPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= N;
                        elsif s_kernelIdx = 5 then
                            s_kernelIdx <= 7;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when N =>  -- Top border
                        if s_kernelIdx = 8 then
                            s_kernelIdx <= 3;
                            s_xPos <= s_xPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_xPos = X_LENGTH-2 then
                                s_mapPos <= NE;
                            end if;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when NE =>  -- Top right corner
                        if s_kernelIdx = 7 then  -- Go to the next row
                            s_kernelIdx <= 1;
                            s_xPos <= 0;
                            s_yPos <= s_yPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= W;
                        elsif s_kernelIdx = 4 then
                            s_kernelIdx <= 6;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when W =>  -- Left border
                        if s_kernelIdx = 8 then
                            s_kernelIdx <= 0;
                            s_xPos <= s_xPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= C;
                        elsif s_kernelIdx = 2 then
                            s_kernelIdx <= 4;
                        elsif s_kernelIdx = 5 then
                            s_kernelIdx <= 7;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when C =>  -- Not on a border/corner
                        if s_kernelIdx = 8 then
                            s_kernelIdx <= 0;
                            s_xPos <= s_xPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_xPos = X_LENGTH-2 then
                                s_mapPos <= E;
                            end if;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when E =>  -- Right border
                        if s_kernelIdx = 7 then  -- Go to the next row
                            s_kernelIdx <= 1;
                            s_xPos <= 0;
                            s_yPos <= s_yPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_yPos = Y_LENGTH-2 then
                                s_mapPos <= SW;  -- Next row will be the last
                            else
                                s_mapPos <= W;
                            end if;
                        elsif s_kernelIdx = 1 then
                            s_kernelIdx <= 3;
                        elsif s_kernelIdx = 4 then
                            s_kernelIdx <= 6;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when SW =>  -- Bottom left corner
                        if s_kernelIdx = 5 then
                            s_kernelIdx <= 0;
                            s_xPos <= s_xPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= S;
                        elsif s_kernelIdx = 2 then
                            s_kernelIdx <= 4;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when S =>  -- Bottom border
                        if s_kernelIdx = 5 then
                            s_kernelIdx <= 0;
                            s_xPos <= s_xPos + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_xPos = X_LENGTH-2 then
                                s_mapPos <= SE;
                            end if;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                    when SE =>  -- Bottom right corner
                        if s_kernelIdx = 4 then  -- Go back to the start
                            s_xPos <= 0;
                            s_yPos <= 0;
                            s_mapIdx <= 0;
                            s_mapPos <= NW;
                        elsif s_kernelIdx = 1 then
                            s_kernelIdx <= 3;
                        else
                            s_kernelIdx <= s_kernelIdx + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

    o_save <= 
        '1' when (s_mapPos = NW and s_kernelIdx = 7)
              or (s_mapPos = N and s_kernelIdx = 5)
              or (s_mapPos = NE and s_kernelIdx = 6)
              or (s_mapPos = W and s_kernelIdx = 4)
              or (s_mapPos = C and s_kernelIdx = 2)
              or (s_mapPos = E and s_kernelIdx = 3)
              or (s_mapPos = SW and s_kernelIdx = 4)
              or (s_mapPos = S and s_kernelIdx = 2)
              or (s_mapPos = SE and s_kernelIdx = 3)
        else '0';

end arch;
