library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counters is
    generic (
        KERNEL_SIZE     : positive := 9;
        MAX_N_CHANNELS  : positive := 1024;
        MAX_N_MAP_ROWS  : positive := 256;
        MAX_N_MAP_COL   : positive := 256;
        MAX_MAP_SIZE    : positive := 256 * 256
    );
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        i_stall         : in std_logic;
        i_lastChanIdx   : in unsigned(9 downto 0);
        i_nMapRows      : in unsigned(7 downto 0);
        i_nMapColumns   : in unsigned(7 downto 0);
        o_weightIdx     : out natural range 0 to KERNEL_SIZE - 1;
        o_channelIdx    : out natural range 0 to MAX_N_CHANNELS - 1;
        o_mapIdx        : out natural range 0 to MAX_MAP_SIZE - 1;
        o_mapIdxOld     : out natural range 0 to MAX_MAP_SIZE - 1;
        o_save          : out std_logic;
        o_done          : out std_logic
    );
end counters;

architecture arch of counters is

    type mapPos_type is (N, NE, E, SE, S, SW, W, NW, C);
    signal r_mapPos         : mapPos_type;

    signal r_weightIdx      : natural range 0 to KERNEL_SIZE + 2;
    signal r_channelIdx     : natural range 0 to MAX_N_CHANNELS - 1;
    signal r_mapIdx         : natural range 0 to MAX_MAP_SIZE - 1;
    signal r_mapIdxOld      : natural range 0 to MAX_MAP_SIZE - 1;
    signal r_row            : natural range 0 to MAX_N_MAP_ROWS - 1;
    signal r_column         : natural range 0 to MAX_N_MAP_COL - 1;

    signal r_done           : std_logic;

    -- Shift register to assert the o_save with a delay of 4 clock cycles
    signal r_shiftSave      : std_logic_vector(3 downto 0);

begin

    o_weightIdx <= r_weightIdx;
    o_channelIdx <= r_channelIdx;
    o_mapIdx <= r_mapIdx;
    o_mapIdxOld <= r_mapIdxOld;
    o_save <= r_shiftSave(3);

    -- Assert the done signal with the last save 
    o_done <= r_done and r_shiftSave(3);

    process (clk)
        variable v_saveFlag : std_logic := '0';
    begin
        if rising_edge(clk) then
            if i_stall = '0' then
                v_saveFlag := '0';

                if i_start = '1' then
                    r_mapPos <= NW;
                    r_weightIdx <= 4;
                    r_channelIdx <= 0;
                    r_column <= 0;
                    r_row <= 0;
                    r_mapIdx <= 0;
                    r_mapIdxOld <= 0;
                    r_done <= '0';
                    r_shiftSave <= "0001";

                else
                    case r_mapPos is

                    when NW =>  -- Top left corner
                        if r_weightIdx = 8 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Move to the right
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 3;
                                r_column <= r_column + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                r_mapPos <= N;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 4;
                            end if;
                        elsif r_weightIdx = 5 then
                            r_weightIdx <= 7;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when N =>  -- Top border
                        if r_weightIdx = 8 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Move to the right
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 3;
                                r_column <= r_column + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                if r_column = i_nMapColumns - 2 then
                                    -- Top right corner reached
                                    r_mapPos <= NE;
                                end if;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 3;
                            end if;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when NE =>  -- Top right corner
                        if r_weightIdx = 7 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Go to the next row
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 1;
                                r_column <= 0;
                                r_row <= r_row + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                r_mapPos <= W;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 3;
                            end if;
                        elsif r_weightIdx = 4 then
                            r_weightIdx <= 6;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when W =>  -- Left border
                        if r_weightIdx = 8 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Move to the right
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 0;
                                r_column <= r_column + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                r_mapPos <= C;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 1;
                            end if;
                        elsif r_weightIdx = 2 then
                            r_weightIdx <= 4;
                        elsif r_weightIdx = 5 then
                            r_weightIdx <= 7;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when C =>  -- Not on a border/corner
                        if r_weightIdx = 8 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Move to the right
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 0;
                                r_column <= r_column + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                if r_column = i_nMapColumns - 2 then
                                    -- Rigth border reached
                                    r_mapPos <= E;
                                end if;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 0;
                            end if;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when E =>  -- Right border
                        if r_weightIdx = 7 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Go to the next row
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 1;
                                r_column <= 0;
                                r_row <= r_row + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                if r_row = i_nMapRows - 2 then
                                    -- Next row will be the last one
                                    r_mapPos <= SW;
                                else
                                    r_mapPos <= W;
                                end if;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 0;
                            end if;
                        elsif r_weightIdx = 1 then
                            r_weightIdx <= 3;
                        elsif r_weightIdx = 4 then
                            r_weightIdx <= 6;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when SW =>  -- Bottom left corner
                        if r_weightIdx = 5 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Move to the right
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 0;
                                r_column <= r_column + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                r_mapPos <= S;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 1;
                            end if;
                        elsif r_weightIdx = 2 then
                            r_weightIdx <= 4;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when S =>  -- Bottom border
                        if r_weightIdx = 5 then
                            if r_channelIdx = i_lastChanIdx then
                                -- Move to the right
                                v_saveFlag := '1';
                                r_channelIdx <= 0;
                                r_weightIdx <= 0;
                                r_column <= r_column + 1;
                                r_mapIdx <= r_mapIdx + 1;
                                r_mapIdxOld <= r_mapIdx;
                                if r_column = i_nMapColumns - 2 then
                                    -- Bottom right corner reached
                                    r_mapPos <= SE;
                                end if;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 0;
                            end if;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    when SE =>  -- Bottom right corner
                        if r_weightIdx = 4 then
                            if r_channelIdx = i_lastChanIdx then
                                -- End reached
                                v_saveFlag := '1';
                                r_done <= '1';
                                r_mapIdxOld <= r_mapIdx;
                            else
                                r_channelIdx <= r_channelIdx + 1;
                                r_weightIdx <= 0;
                            end if;
                        elsif r_weightIdx = 1 then
                            r_weightIdx <= 3;
                        else
                            r_weightIdx <= r_weightIdx + 1;
                        end if;

                    end case;

                    -- Update the 'save' shift register
                    r_shiftSave <= r_shiftSave(2 downto 0) & v_saveFlag;

                end if;
            end if;
        end if;
    end process;

end arch;
