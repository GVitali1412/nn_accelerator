library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity controller is
    generic (
        KERNEL_SIZE     : positive := 9;
        MAX_N_CHANNELS  : positive := 1024;
        MAX_MAP_SIZE    : positive := 256 * 256
    );
    port (
        clk             : in std_logic;

        -- AXI control registers
        i_ctrlReg0      : in std_logic_vector(31 downto 0);
        i_ctrlReg1      : in std_logic_vector(31 downto 0);
        i_ctrlReg2      : in std_logic_vector(31 downto 0);
        i_ctrlReg3      : in std_logic_vector(31 downto 0);
        o_rstCtrlReg    : out std_logic;

        -- Instruction buffer
        o_enInstr       : out std_logic;
        o_instrPtr      : out std_logic_vector(8 downto 0);
        i_instruction   : in std_logic_vector(63 downto 0);

        o_clearAccum    : out std_logic;
        o_loadPartSum   : out std_logic;
        o_enActivation  : out std_logic;

        -- Input buffer
        o_inBufEn       : out std_logic;
        o_inBufAddr     : out std_logic_vector(16 downto 0);

        -- Weights buffer
        o_wgsBufEn      : out std_logic;
        o_wgsBufAddr    : out std_logic_vector(10 downto 0);

        -- Partial sums buffer
        o_psumBufEn     : out std_logic;
        o_psumBufAddr   : out std_logic_vector(8 downto 0);

        -- Output buffer
        o_outBufEn      : out std_logic;
        o_outBufWe      : out std_logic;
        o_outBufAddr    : out std_logic_vector(8 downto 0)
    );
end controller;

architecture arch of controller is

    type state_type is (IDLE, FETCH_INSTR, DECODE_INSTR, COMPUTE, STOP);
    signal state            : state_type := IDLE;

    signal r_instrPtr       : unsigned(8 downto 0) := (others => '0');
    signal r_currInstr      : std_logic_vector(63 downto 0);
    signal s_instr          : std_logic_vector(63 downto 0);

    -- Register containing the number of (input) channels minus 1 for the 
    -- current computation block = index of the last channel
    signal r_lastChanIdx    : unsigned(9 downto 0);

    signal r_nMapRows       : unsigned(7 downto 0);
    signal r_nMapColumns    : unsigned(7 downto 0);
    signal r_mapSize        : unsigned(15 downto 0);

    signal r_firstBlock     : std_logic;
    signal r_lastBlock      : std_logic;

    signal r_inBaseAddr     : unsigned(16 downto 0) := (others => '0');
    signal r_wgsBaseAddr    : unsigned(10 downto 0) := (others => '0');
    signal r_psumBaseAddr   : unsigned(8 downto 0) := (others => '0');
    signal r_outBaseAddr    : unsigned(8 downto 0) := (others => '0');

    signal s_start          : std_logic;
    signal s_done           : std_logic;

    signal s_weightIdx      : natural range 0 to KERNEL_SIZE - 1;
    signal s_channelIdx     : natural range 0 to MAX_N_CHANNELS - 1;
    signal s_mapIdx         : natural range 0 to MAX_MAP_SIZE - 1;
    signal s_mapIdxOld      : natural range 0 to MAX_MAP_SIZE - 1;
    signal s_save           : std_logic;

begin

    o_enInstr <= '1';
    o_instrPtr <= std_logic_vector(r_instrPtr);

    process (clk)
        variable v_opcode : std_logic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            r_currInstr <= i_instruction;

            case state is
            when IDLE =>
                if i_ctrlReg0(0) = '1' then
                    state <= FETCH_INSTR;
                    r_instrPtr <= (others => '0');
                end if;
            
            when FETCH_INSTR =>
                state <= DECODE_INSTR;
                r_instrPtr <= r_instrPtr + 1;
            
            when DECODE_INSTR =>
                v_opcode := r_currInstr(63 downto 60);
                case v_opcode is
                when "0000" =>  -- Return to IDLE/reset state
                    state <= IDLE;
                    r_instrPtr <= (others => '0');

                when "0001" =>  -- Start convolution
                    state <= COMPUTE;
                    r_lastChanIdx <= unsigned(r_currInstr(59 downto 50));
                    r_firstBlock <= r_currInstr(49);
                    r_lastBlock <= r_currInstr(48);
                    r_nMapRows <= unsigned(r_currInstr(47 downto 40));
                    r_nMapColumns <= unsigned(r_currInstr(39 downto 32));
                    r_mapSize <= unsigned(r_currInstr(47 downto 40))
                                 * unsigned(r_currInstr(39 downto 32));

                when "0010" =>  -- Load base addresses
                    state <= FETCH_INSTR;
                    r_inBaseAddr <= unsigned(r_currInstr(59 downto 43));
                    r_wgsBaseAddr <= unsigned(r_currInstr(42 downto 32));
                    r_psumBaseAddr <= unsigned(r_currInstr(31 downto 23));
                    r_outBaseAddr <= unsigned(r_currInstr(22 downto 14));
                
                when others =>
                    state <= STOP;

                end case;
                
            when COMPUTE =>
                if s_done = '1' then
                    state <= FETCH_INSTR;
                end if;
            
            when STOP =>
                state <= STOP;

            end case;

        end if;
    end process;


    process (state, r_currInstr, i_ctrlReg0)
    begin
        case state is
        when IDLE =>
            s_start <= '0';
            if i_ctrlReg0(0) = '1' then
                o_rstCtrlReg <= '1';
            else
                o_rstCtrlReg <= '0';
            end if;
        when DECODE_INSTR =>
            if r_currInstr(63 downto 60) = "0001" then
                s_start <= '1';
            else
                s_start <= '0';
            end if;
            o_rstCtrlReg <= '0';
        when others =>
            s_start <= '0';
            o_rstCtrlReg <= '0';
        end case;
    end process;


    o_clearAccum <= '1' when state = COMPUTE 
                             and s_save = '1' 
                             and r_firstBlock = '1'
                    else '0';

    o_loadPartSum <= '1' when state = COMPUTE
                              and s_save = '1'
                              and r_firstBlock = '0'
                     else '0';

    -- If the current block is the last layer save the results with the 
    -- activation function, otherwise save the partial sums
    o_enActivation <= '1' when r_lastBlock = '1'
                      else '0';

    o_inBufEn <= '1' when state = COMPUTE
                 else '0';

    o_wgsBufEn <= '1' when state = COMPUTE
                  else '0';
    
    o_psumBufEn <= '1' when state = COMPUTE
                   else '0';
    
    o_outBufEn <= '1' when state = COMPUTE
        else '0';

    -- The CUs write two time to the first map position
    -- the first while filling the pipeline
    -- the second is the correct result and overwrite the first
    o_outBufWe <= '1' when state = COMPUTE and s_save = '1'
        else '0';


    counters : entity work.counters
    port map (
        clk             => clk,
        i_start         => s_start,
        i_lastChanIdx   => r_lastChanIdx,
        i_nMapRows      => r_nMapRows,
        i_nMapColumns   => r_nMapColumns,
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
        i_inBaseAddr    => r_inBaseAddr,
        i_wgsBaseAddr   => r_wgsBaseAddr,
        i_psumBaseAddr  => r_psumBaseAddr,
        i_outBaseAddr   => r_outBaseAddr,
        i_weightIdx     => s_weightIdx,
        i_channelIdx    => s_channelIdx,
        i_mapIdx        => s_mapIdx,
        i_mapIdxOld     => s_mapIdxOld,
        i_mapSize       => r_mapSize,
        i_nMapColumns   => r_nMapColumns,
        o_inBufAddr     => o_inBufAddr,
        o_wgsBufAddr    => o_wgsBufAddr,
        o_psumBufAddr   => o_psumBufAddr,
        o_outBufAddr    => o_outBufAddr
    );

end arch;
