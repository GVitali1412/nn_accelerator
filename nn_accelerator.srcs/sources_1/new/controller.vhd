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
        i_stall         : in std_logic;
        o_addrEn        : out std_logic;

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
        o_wsBufEn       : out std_logic;
        o_wsBufAddr     : out std_logic_vector(10 downto 0);

        -- Partial sums buffer
        o_psBufEn       : out std_logic;
        o_psBufAddr     : out std_logic_vector(8 downto 0);

        -- Output buffer
        o_outBufEn      : out std_logic;
        o_outBufWe      : out std_logic;
        o_outBufAddr    : out std_logic_vector(8 downto 0);

        i_dmaDone       : in std_logic;
        o_queueDataIn   : out std_logic_vector(63 downto 0);
        o_enqueueReq    : out std_logic;
        i_queueFull     : in std_logic
    );
end controller;

architecture arch of controller is

    type state_type is (IDLE, FETCH_INSTR, DECODE_INSTR, PIPE_FILL1, PIPE_FILL2, COMPUTE, 
                        STOP, WAIT_DMA);
    signal state            : state_type := IDLE;

    signal r_instrPtr       : unsigned(8 downto 0) := (others => '0');
    signal r_currInstr      : std_logic_vector(63 downto 0);
    signal s_instr          : std_logic_vector(63 downto 0);

    type mode_type is (CONV, FC, POOL);
    signal r_computeMode    : mode_type;

    signal r_computeConfig  : std_logic_vector(59 downto 0);

    signal s_firstBlock     : std_logic;
    signal s_lastBlock      : std_logic;

    signal r_inBaseAddr     : unsigned(16 downto 0) := (others => '0');
    signal r_wsBaseAddr     : unsigned(10 downto 0) := (others => '0');
    signal r_psBaseAddr     : unsigned(8 downto 0) := (others => '0');
    signal r_outBaseAddr    : unsigned(8 downto 0) := (others => '0');

    signal s_start          : std_logic;

    signal s_inBufAddrConv  : std_logic_vector(16 downto 0);
    signal s_wsBufAddrConv  : std_logic_vector(10 downto 0);
    signal s_psBufAddrConv  : std_logic_vector(8 downto 0);
    signal s_outBufAddrConv : std_logic_vector(8 downto 0);
    signal s_saveConv       : std_logic;
    signal s_doneConv       : std_logic;

    signal s_inBufAddrFC    : std_logic_vector(16 downto 0);
    signal s_wsBufAddrFC    : std_logic_vector(10 downto 0);
    signal s_psBufAddrFC    : std_logic_vector(8 downto 0);
    signal s_outBufAddrFC   : std_logic_vector(8 downto 0);
    signal s_saveFC         : std_logic;
    signal s_doneFC         : std_logic;


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
                    state <= PIPE_FILL1;
                    r_computeMode <= CONV;
                    r_computeConfig <= r_currInstr(59 downto 0);

                when "0010" =>  -- Load base addresses
                    state <= FETCH_INSTR;
                    r_inBaseAddr <= unsigned(r_currInstr(59 downto 43));
                    r_wsBaseAddr <= unsigned(r_currInstr(42 downto 32));
                    r_psBaseAddr <= unsigned(r_currInstr(31 downto 23));
                    r_outBaseAddr <= unsigned(r_currInstr(22 downto 14));
                
                when "0011" =>  -- Enqueue a DMA transfer
                    state <= FETCH_INSTR;

                when "0100" =>  -- Wait until DMA transfers are completed
                    state <= WAIT_DMA;

                when "0101" => -- Start fully-connected computation
                    state <= PIPE_FILL1;
                    r_computeMode <= FC;
                    r_computeConfig <= r_currInstr(59 downto 0);
                
                when others =>
                    state <= STOP;

                end case;
            
            when PIPE_FILL1 =>
                state <= PIPE_FILL2;
            
            when PIPE_FILL2 =>
                state <= COMPUTE;
                
            when COMPUTE =>
                if ((s_doneConv = '1' and r_computeMode = CONV)
                    or (s_doneFC = '1' and r_computeMode = FC))
                then 
                    state <= FETCH_INSTR;
                end if;
            
            when STOP =>
                state <= STOP;
            
            when WAIT_DMA =>
                if i_dmaDone = '1' then
                    state <= FETCH_INSTR;
                end if;

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
            if r_currInstr(63 downto 60) = "0001" or r_currInstr(63 downto 60) = "0101" then
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

    s_firstBlock <= r_computeConfig(49);
    s_lastBlock <= r_computeConfig(48);

    o_clearAccum <= '1' when state = COMPUTE 
                             and ((s_saveConv = '1' and r_computeMode = CONV)
                                  or (s_saveFC = '1' and r_computeMode = FC))
                             and s_firstBlock = '1'
                    else '0';

    o_loadPartSum <= '1' when state = COMPUTE
                              and ((s_saveConv = '1' and r_computeMode = CONV)
                                   or (s_saveFC = '1' and r_computeMode = FC))
                              and s_firstBlock = '0'
                     else '0';

    -- If the current block is the last layer save the results with the 
    -- activation function, otherwise save the partial sums
    o_enActivation <= '1' when s_lastBlock = '1'
                      else '0';
    
    o_addrEn <= '1' when state = COMPUTE else '0';

    o_inBufEn <= '1' when state = COMPUTE else '0';

    o_inBufAddr <= s_inBufAddrConv when r_computeMode = CONV
                   else s_inBufAddrFC;

    o_wsBufEn <= '1' when state = COMPUTE else '0';

    o_wsBufAddr <= s_wsBufAddrConv when r_computeMode = CONV
                   else s_wsBufAddrFC;
    
    o_psBufEn <= '1' when state = COMPUTE else '0';

    o_psBufAddr <= s_psBufAddrConv when r_computeMode = CONV
                   else s_psBufAddrFC;
    
    o_outBufEn <= '1' when state = COMPUTE else '0';
    
    o_outBufAddr <= s_outBufAddrConv when r_computeMode = CONV
                    else s_outBufAddrFC;

    -- The CUs write two time to the first map position
    -- the first while filling the pipeline
    -- the second is the correct result and overwrite the first
    o_outBufWe <= '1' when state = COMPUTE and ((s_saveConv = '1' and r_computeMode = CONV)
                                                or (s_saveFC = '1' and r_computeMode = FC))
                  else '0';

    o_enqueueReq <= '1' when state = DECODE_INSTR and r_currInstr(63 downto 60) = "0011"
                    else '0';

    o_queueDataIn <= r_currInstr when state = DECODE_INSTR and r_currInstr(63 downto 60) = "0011"
                     else (others => '0');
    
    
    convolution_controller : entity work.conv_controller
    port map (
        clk             => clk,
        i_start         => s_start,
        i_stall         => i_stall,
        i_mapSize       => unsigned(r_computeConfig(31 downto 16)),
        i_lastChanIdx   => unsigned(r_computeConfig(59 downto 50)),
        i_nMapRows      => unsigned(r_computeConfig(47 downto 40)),
        i_nMapColumns   => unsigned(r_computeConfig(39 downto 32)),
        i_inBaseAddr    => r_inBaseAddr,
        i_wsBaseAddr    => r_wsBaseAddr,
        i_psBaseAddr    => r_psBaseAddr,
        i_outBaseAddr   => r_outBaseAddr,
        o_inBufAddr     => s_inBufAddrConv,
        o_wsBufAddr     => s_wsBufAddrConv,
        o_psBufAddr     => s_psBufAddrConv,
        o_outBufAddr    => s_outBufAddrConv,
        o_save          => s_saveConv,
        o_done          => s_doneConv
    );

    fully_connect_controller : entity work.fc_controller
    port map (
        clk             => clk,
        i_start         => s_start,
        i_stall         => i_stall,
        i_nWeights      => unsigned(r_computeConfig(58 downto 50)),
        i_nNeurons      => unsigned(r_computeConfig(39 downto 38)),
        i_inBaseAddr    => r_inBaseAddr,
        i_wsBaseAddr    => r_wsBaseAddr,
        i_psBaseAddr    => r_psBaseAddr,
        i_outBaseAddr   => r_outBaseAddr,
        o_inBufAddr     => s_inBufAddrFC,
        o_wsBufAddr     => s_wsBufAddrFC,
        o_psBufAddr     => s_psBufAddrFC,
        o_outBufAddr    => s_outBufAddrFC,
        o_save          => s_saveFC,
        o_done          => s_doneFC
    );

end arch;
