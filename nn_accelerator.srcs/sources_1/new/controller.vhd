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
        i_ctrlReg0      : in std_logic_vector(31 downto 0);
        i_ctrlReg1      : in std_logic_vector(31 downto 0);
        i_ctrlReg2      : in std_logic_vector(31 downto 0);
        i_ctrlReg3      : in std_logic_vector(31 downto 0);

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

    type state_type is (IDLE, FETCH_INSTR, COMPUTE, STOP);
    signal state            : state_type := IDLE;

    signal s_enInstrRom     : std_logic;
    signal r_instrPtr       : unsigned(8 downto 0) := (others => '0');
    signal s_instr          : std_logic_vector(63 downto 0);

    signal s_start          : std_logic;
    signal s_done           : std_logic;

    signal s_weightIdx      : natural range 0 to KERNEL_SIZE - 1;
    signal s_channelIdx     : natural range 0 to N_CHANNELS - 1;
    signal s_mapIdx         : natural range 0 to MAP_SIZE - 1;
    signal s_mapIdxOld      : natural range 0 to MAP_SIZE - 1;
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

    s_enInstrRom <= '1';

    process (clk)
        variable v_opcode : std_logic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            case state is
            when IDLE =>
                if i_ctrlReg0(0) = '1' then
                    state <= FETCH_INSTR;
                end if;
            
            when FETCH_INSTR =>
                v_opcode := s_instr(63 downto 60);
                case v_opcode is
                when "0000" =>  -- Stop
                    state <= IDLE;

                when "0001" =>  -- Start convolution
                    state <= COMPUTE;
                
                when others =>
                    state <= STOP;

                end case;

                r_instrPtr <= r_instrPtr + 1;
            
            when COMPUTE =>
                if s_done = '1' then
                    state <= STOP;
                end if;
            
            when STOP =>
                state <= STOP;

            end case;

        end if;
    end process;


    process(state)
    begin
        case state is
        when IDLE =>
            s_start <= '0';
        when FETCH_INSTR =>
            if s_instr(63 downto 60) = "0001" then
                s_start <= '1';
            else
                s_start <= '0';
            end if;
        when others =>
            s_start <= '0';
        end case;
    end process;


    o_inBufEn <= '1';

    o_outBufEn <= '1' when state = COMPUTE
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
        i_start         => s_start,
        o_weightIdx     => s_weightIdx,
        o_channelIdx    => s_channelIdx,
        o_mapIdx        => s_mapIdx,
        o_mapIdxOld     => s_mapIdxOld,
        o_save          => s_save,
        o_done          => s_done
    );

    addresses_generator : entity work.addr_generator
    port map (
        clk             => clk,
        i_weightIdx     => s_weightIdx,
        i_channelIdx    => s_channelIdx,
        i_mapIdx        => s_mapIdx,
        i_mapIdxOld     => s_mapIdxOld,
        o_inBufAddr     => o_inBufAddr,
        o_wgsBufAddr    => o_wgsBufAddr,
        o_psumBufAddr   => o_psumBufAddr,
        o_outBufAddr    => o_outBufAddr
    );

    instr_rom : instruction_rom
    port map (
        clka            => clk,
        ena             => s_enInstrRom,
        addra           => std_logic_vector(r_instrPtr),
        douta           => s_instr
    );


end arch;
