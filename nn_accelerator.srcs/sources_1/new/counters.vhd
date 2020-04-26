library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counters is
    generic (
        KERNEL_SIZE     : positive := 9;
        N_CHANNELS      : positive := 8;
        N_ROWS          : positive := 13;
        N_COLUMNS       : positive := 13;
        MAP_SIZE        : positive := N_ROWS * N_COLUMNS
    );
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        o_weightIdx     : out natural range 0 to KERNEL_SIZE - 1;
        o_channelIdx    : out natural range 0 to N_CHANNELS - 1;
        o_mapIdx        : out natural range 0 to MAP_SIZE - 1;
        o_save          : out std_logic
    );
end counters;

architecture arch of counters is

    type mapPos_type is (N, NE, E, SE, S, SW, W, NW, C);
    signal s_mapPos         : mapPos_type;

    signal s_weightIdx      : natural range 0 to KERNEL_SIZE + 2;
    signal s_channelIdx     : natural range 0 to N_CHANNELS - 1;
    signal s_mapIdx         : natural range 0 to MAP_SIZE - 1;
    signal s_row            : natural range 0 to N_ROWS - 1;
    signal s_column         : natural range 0 to N_COLUMNS - 1;

    -- Shift register to assert the o_save with a delay of 3 clock cycles
    signal r_shiftSave      : std_logic_vector(2 downto 0);

begin

    o_weightIdx <= s_weightIdx;
    o_channelIdx <= s_channelIdx;
    o_mapIdx <= s_mapIdx;
    o_save <= r_shiftSave(2);

    process (clk)
        variable v_saveFlag : std_logic := '0';
    begin
        if rising_edge(clk) then
            v_saveFlag := '0';

            if i_start = '1' then
                s_mapPos <= NW;
                s_weightIdx <= 4;
                s_channelIdx <= 0;
                s_column <= 0;
                s_row <= 0;
                s_mapIdx <= 0;
                r_shiftSave <= "001";

            else
                case s_mapPos is

                when NW =>  -- Top left corner
                    if s_weightIdx = 8 then
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Move to the right
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 3;
                            s_column <= s_column + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= N;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 4;
                        end if;
                    elsif s_weightIdx = 5 then
                        s_weightIdx <= 7;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when N =>  -- Top border
                    if s_weightIdx = 8 then
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Move to the right
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 3;
                            s_column <= s_column + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_column = N_COLUMNS-2 then
                                -- Top right corner reached
                                s_mapPos <= NE;
                            end if;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 3;
                        end if;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when NE =>  -- Top right corner
                    if s_weightIdx = 7 then  
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Go to the next row
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 1;
                            s_column <= 0;
                            s_row <= s_row + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= W;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 3;
                        end if;
                    elsif s_weightIdx = 4 then
                        s_weightIdx <= 6;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when W =>  -- Left border
                    if s_weightIdx = 8 then
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Move to the right
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 0;
                            s_column <= s_column + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= C;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 1;
                        end if;
                    elsif s_weightIdx = 2 then
                        s_weightIdx <= 4;
                    elsif s_weightIdx = 5 then
                        s_weightIdx <= 7;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when C =>  -- Not on a border/corner
                    if s_weightIdx = 8 then
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Move to the right
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 0;
                            s_column <= s_column + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_column = N_COLUMNS-2 then
                                -- Rigth border reached
                                s_mapPos <= E;
                            end if;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 0;
                        end if;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when E =>  -- Right border
                    if s_weightIdx = 7 then
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Go to the next row
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 1;
                            s_column <= 0;
                            s_row <= s_row + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_row = N_ROWS-2 then
                                -- Next row will be the last one
                                s_mapPos <= SW;
                            else
                                s_mapPos <= W;
                            end if;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 0;
                        end if;
                    elsif s_weightIdx = 1 then
                        s_weightIdx <= 3;
                    elsif s_weightIdx = 4 then
                        s_weightIdx <= 6;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when SW =>  -- Bottom left corner
                    if s_weightIdx = 5 then
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Move to the right
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 0;
                            s_column <= s_column + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            s_mapPos <= S;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 1;
                        end if;
                    elsif s_weightIdx = 2 then
                        s_weightIdx <= 4;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when S =>  -- Bottom border
                    if s_weightIdx = 5 then
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Move to the right
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 0;
                            s_column <= s_column + 1;
                            s_mapIdx <= s_mapIdx + 1;
                            if s_column = N_COLUMNS-2 then
                                -- Bottom right corner reached
                                s_mapPos <= SE;
                            end if;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 0;
                        end if;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                when SE =>  -- Bottom right corner
                    if s_weightIdx = 4 then  
                        if s_channelIdx = N_CHANNELS-1 then
                            -- Go back to the top left corner 
                            v_saveFlag := '1';
                            s_channelIdx <= 0;
                            s_weightIdx <= 4;
                            s_column <= 0;
                            s_row <= 0;
                            s_mapIdx <= 0;
                            s_mapPos <= NW;
                        else
                            s_channelIdx <= s_channelIdx + 1;
                            s_weightIdx <= 0;
                        end if;
                    elsif s_weightIdx = 1 then
                        s_weightIdx <= 3;
                    else
                        s_weightIdx <= s_weightIdx + 1;
                    end if;

                end case;

                -- Update the 'save' shift register
                r_shiftSave <= r_shiftSave(1 downto 0) & v_saveFlag;

            end if;
        end if;
    end process;

end arch;
