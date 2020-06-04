library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity addr_generator is
    generic (
        KERNEL_SIZE     : positive := 9;
        MAX_N_CHANNELS  : positive := 1024;
        MAX_MAP_SIZE    : positive := 256 * 256
    );
    port (
        clk             : in std_logic;
        i_stall         : in std_logic;
        i_inBaseAddr    : in unsigned(16 downto 0);
        i_wgsBaseAddr   : in unsigned(10 downto 0);
        i_psumBaseAddr  : in unsigned(8 downto 0);
        i_outBaseAddr   : in unsigned(8 downto 0);
        i_weightIdx     : in natural range 0 to KERNEL_SIZE - 1;
        i_channelIdx    : in natural range 0 to MAX_N_CHANNELS - 1;
        i_mapIdx        : in natural range 0 to MAX_MAP_SIZE - 1;
        i_mapIdxOld     : in natural range 0 to MAX_MAP_SIZE - 1;
        i_mapSize       : in unsigned(15 downto 0);
        i_nMapColumns   : in unsigned(7 downto 0);
        o_inBufAddr     : out std_logic_vector(16 downto 0);
        o_wgsBufAddr    : out std_logic_vector(10 downto 0);
        o_psumBufAddr   : out std_logic_vector(8 downto 0);
        o_outBufAddr    : out std_logic_vector(8 downto 0)
    );
end addr_generator;

architecture arch of addr_generator is

    signal r_offset         : integer range -16 to 16;

    signal r_inBufAddrPipeA : unsigned(16 downto 0);
    signal r_inBufAddrPipeB : unsigned(16 downto 0);
    signal r_wsBufAddrPipeA : unsigned(10 downto 0);
    signal r_wsBufAddrPipeB : unsigned(10 downto 0);

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
                case i_weightIdx is
                    when 0 => r_offset <= -to_integer(i_nMapColumns+1);
                    when 1 => r_offset <= -to_integer(i_nMapColumns);
                    when 2 => r_offset <= -to_integer(i_nMapColumns-1);
                    when 3 => r_offset <= -1;
                    when 4 => r_offset <= 0;
                    when 5 => r_offset <= 1;
                    when 6 => r_offset <= to_integer(i_nMapColumns-1);
                    when 7 => r_offset <= to_integer(i_nMapColumns);
                    when 8 => r_offset <= to_integer(i_nMapColumns+1);
                when others => r_offset <= 0;
                end case;
            end if;
        end if;
    end process;

    -- Input address
    process (clk)
    begin
        if rising_edge(clk) then
            if i_stall = '0' then
                r_inBufAddrPipeA <= to_unsigned((i_channelIdx * to_integer(i_mapSize)), 17);
                
                r_inBufAddrPipeB <= to_unsigned(
                                        to_integer(i_inBaseAddr)
                                        + i_mapIdx, 17);

                r_inBufAddr <= std_logic_vector(r_inBufAddrPipeA + r_inBufAddrPipeB + r_offset);
            end if;
        end if;
    end process;

    -- Weights address
    process (clk)
    begin
        if rising_edge(clk) then
            if i_stall = '0' then
                r_wsBufAddrPipeA <= to_unsigned(i_channelIdx * KERNEL_SIZE, 11);

                r_wsBufAddrPipeB <= i_wgsBaseAddr + to_unsigned(i_weightIdx, 11); 
                
                r_wsBufAddr <= std_logic_vector(r_wsBufAddrPipeA + r_wsBufAddrPipeB);
            end if;
        end if;
    end process;

    -- Psum address
    process (clk)
    begin
        if rising_edge(clk) then
            if i_stall = '0' then
                r_psBufAddrPipe <= std_logic_vector(
                                        to_unsigned(
                                            to_integer(i_psumBaseAddr)
                                            + i_mapIdx, 9));
                
                r_psBufAddr <= r_psBufAddrPipe;
            end if;
        end if;
    end process;

    -- Output address
    process (clk)
    begin
        if rising_edge(clk) then
            if i_stall = '0' then
                r_outBufAddrPipe <= std_logic_vector(
                                        to_unsigned(
                                            to_integer(i_outBaseAddr)
                                            + i_mapIdxOld, 9));
                
                r_outBufAddr <= r_outBufAddrPipe;
            end if;
        end if;
    end process;
    
    o_inBufAddr  <= r_inBufAddr;
    o_wgsBufAddr <= r_wsBufAddr;
    o_psumBufAddr <= r_psBufAddr;
    o_outBufAddr <= r_outBufAddr;

end arch;
