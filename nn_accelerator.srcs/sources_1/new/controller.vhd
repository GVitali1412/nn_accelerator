library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity controller is
    generic (
        KERNEL_SIZE     : positive := 9;
        N_CHANNELS      : positive := 8;
        MAP_SIZE        : positive := 13 * 13
    );
    port (
        clk             : in std_logic;
        i_start         : in std_logic;
        o_clearAccum    : out std_logic;
        o_loadPartSum   : out std_logic;

        -- in buffer
        o_inBufEn       : out std_logic;
        o_inBufAddr     : out std_logic_vector(17 downto 0);

        -- weights buffer
        o_wgsBufEn      : out std_logic;
        o_wgsBufAddr    : out std_logic_vector(8 downto 0);

        -- partial sums buffer
        o_psumBufEn     : out std_logic;
        o_psumBufAddr   : out std_logic_vector(8 downto 0);

        -- out buffer
        o_outBufEn      : out std_logic;
        o_outBufWe      : out std_logic;
        o_outBufAddr    : out std_logic_vector(8 downto 0)
    );
end controller;

architecture arch of controller is

    type state_type is (IDLE, PIPE_FILL, COMPUTE, LAST);
    signal fsm_state        : state_type := IDLE;

    signal s_enInstrRom     : std_logic;
    signal r_instrPtr       : unsigned(8 downto 0) := (others => '0');
    signal s_instr          : std_logic_vector(63 downto 0);

    signal s_weightIdx      : natural range 0 to KERNEL_SIZE - 1;
    signal s_channelIdx     : natural range 0 to N_CHANNELS - 1;
    signal s_mapIdx         : natural range 0 to MAP_SIZE - 1;
    signal s_save           : std_logic;

    component instruction_rom
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            addra           : in std_logic_vector(8 downto 0);
            douta           : out std_logic_vector(63 downto 0)
        );
    end component;

begin

    -- TODO
    s_enInstrRom <= '0';

    process (clk)
    begin
        if rising_edge(clk) then
            case fsm_state is
                when IDLE =>
                    if i_start = '1' then fsm_state <= PIPE_FILL;
                    end if;
                when PIPE_FILL =>
                    if s_mapIdx = 1 then fsm_state <= COMPUTE;
                    end if;
                when COMPUTE =>
                    if s_mapIdx = MAP_SIZE-1 and s_save = '1' then 
                        fsm_state <= LAST;
                    end if;
                when LAST =>
                    if s_save = '1' then fsm_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;


    o_inBufEn <= '1';

    o_outBufEn <= '1' when fsm_state = COMPUTE or fsm_state = LAST
                  else '0';

    o_outBufWe <= '1' when s_save = '1'
                   else '0';

    o_wgsBufEn <= '1';

    o_clearAccum <= '1' when s_save = '1'
                    else '0';
    
    -- TODO enable partial sums buffer
    o_psumBufEn <= '0';
    o_loadPartSum <= '0';

    counters : entity work.counters
    port map (
        clk             => clk,
        i_start         => i_start,
        o_weightIdx     => s_weightIdx,
        o_channelIdx    => s_channelIdx,
        o_mapIdx        => s_mapIdx,
        o_save          => s_save
    );

    addresses_generator : entity work.addr_generator
    port map (
        clk             => clk,
        i_weightIdx     => s_weightIdx,
        i_channelIdx    => s_channelIdx,
        i_mapIdx        => s_mapIdx,
        o_inBufAddr     => o_inBufAddr,
        o_wgsBufAddr    => o_wgsBufAddr,
        o_psumBufAddr   => o_psumBufAddr,
        o_outBufAddr    => o_outBufAddr
    );

    instr_rom : instruction_rom
    port map (
        clka            => clk,
        ena             => s_enInstrRom,
        addra           => r_instrPtr,
        douta           => s_instr
    );


end arch;
