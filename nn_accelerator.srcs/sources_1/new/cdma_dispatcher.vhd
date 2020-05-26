library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity cdma_dispatcher is
    port (
        clk             : in std_logic;
        i_reset         : in std_logic;
        o_dmaDone       : out std_logic;

        -- Request queue
        i_queueDataIn   : in std_logic_vector(63 downto 0);
        i_enqueueReq    : in std_logic;
        o_queueFull     : out std_logic;

        -- AXI4-lite master interface to CDMA IP
        -- Read channels
        o_araddr        : out std_logic_vector(31 downto 0);
        o_arvalid       : out std_logic;
        i_arready       : in std_logic;

        i_rdata         : in std_logic_vector(31 downto 0);
        i_rresp         : in std_logic_vector(1 downto 0);
        i_rvalid        : in std_logic;
        o_rready        : out std_logic;

        -- Write channels
        o_awaddr        : out std_logic_vector(31 downto 0);
        o_awvalid       : out std_logic;
        i_awready       : in std_logic;

        o_wdata         : out std_logic_vector(31 downto 0);
        o_wvalid        : out std_logic;
        i_wready        : in std_logic;
        
        i_bresp         : in std_logic_vector(1 downto 0);
        i_bvalid        : in std_logic;
        o_bready        : out std_logic
    );
end cdma_dispatcher;

architecture arch of cdma_dispatcher is

    type state_type is (IDLE, DEQUEUE, WRITE_SRC, WRITE_DST, WRITE_BTT, WAIT_DMA, RESET);
    signal state            : state_type := IDLE;
    
    signal s_dequeueReq     : std_logic;
    signal s_queueEmpty     : std_logic;
    signal s_queueDataOut   : std_logic_vector(63 downto 0);

    signal r_srcAddr        : std_logic_vector(31 downto 0);
    signal r_dstAddr        : std_logic_vector(31 downto 0);
    signal r_btt            : std_logic_vector(31 downto 0);

    signal r_awvalid        : std_logic := '0';
    signal r_wvalid         : std_logic := '0';

    signal r_done           : std_logic := '0';

    component fifo_dispatcher_queue
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            din             : in std_logic_vector(63 downto 0);
            wr_en           : in std_logic;
            rd_en           : in std_logic;
            dout            : out std_logic_vector(63 DOWNTO 0);
            full            : out std_logic;
            empty           : out std_logic
        );
    end component;

begin

    request_queue : fifo_dispatcher_queue
    port map (
        clk             => clk,
        rst             => i_reset,
        din             => i_queueDataIn,
        wr_en           => i_enqueueReq,
        rd_en           => s_dequeueReq,
        dout            => s_queueDataOut,
        full            => o_queueFull,
        empty           => s_queueEmpty
    );

    s_dequeueReq <= '1' when state = DEQUEUE else '0';

    o_araddr <= "10000000000000000000000000000100";  -- Status register has offset 0x04
    o_arvalid <= '1';  -- Always read the status register
    o_rready <= '1';  -- Always accept read data
    o_bready <= '1';  -- Always accept write responses
    o_awvalid <= r_awvalid;
    o_wvalid <= r_wvalid;

    o_awaddr <= "10000000000000000000000000011000" when state = WRITE_SRC  -- Offset 0x18
                    else
                "10000000000000000000000000100000" when state = WRITE_DST  -- Offset 0x20
                    else
                "10000000000000000000000000101000" when state = WRITE_BTT  -- Offset 0x28
                    else "10000000000000000000000000000000";  -- Offset 0x04
    
    o_wdata <= r_srcAddr when state = WRITE_SRC
                    else
               r_dstAddr when state = WRITE_DST
                    else
               r_btt when state = WRITE_BTT
                    else
               (2 => '1', others => '0') when state = RESET
                    else (others => '0');
    
    o_dmaDone <= r_done;

    process (clk)
    begin
        if rising_edge(clk) then
            case state is
            when IDLE =>
                r_done <= '0';
                if s_queueEmpty = '0' and (i_rvalid and i_rdata(1) and not i_rdata(12)) = '1' then
                    state <= DEQUEUE;
                    r_srcAddr(31 downto 12) <= s_queueDataOut(59 downto 40);
                    r_srcAddr(11 downto 0) <= (others => '0');
                    r_dstAddr(31 downto 12) <= s_queueDataOut(39 downto 20);
                    r_dstAddr(11 downto 0) <= (others => '0');
                    r_btt(17 downto 0) <= s_queueDataOut(19 downto 2);
                    r_btt(31 downto 18) <= (others => '0');
                end if;

            when DEQUEUE =>
                state <= WRITE_SRC;
                r_awvalid <= '1';
                r_wvalid <= '1';

            when WRITE_SRC =>
                if i_bvalid = '1' then  -- Source address set
                    state <= WRITE_DST;
                    r_awvalid <= '1';
                    r_wvalid <= '1';
                else
                    if i_awready = '1' then r_awvalid <= '0'; end if;
                    if i_wready = '1' then r_wvalid <= '0'; end if;
                end if;

            when WRITE_DST =>
                if i_bvalid = '1' then  -- Destination address set
                    state <= WRITE_BTT;
                    r_awvalid <= '1';
                    r_wvalid <= '1';
                else
                    if i_awready = '1' then r_awvalid <= '0'; end if;
                    if i_wready = '1' then r_wvalid <= '0'; end if;
                end if;

            when WRITE_BTT =>
                if i_bvalid = '1' then  -- BTT set, DMA transfer started
                    state <= WAIT_DMA;
                    r_awvalid <= '0';
                    r_wvalid <= '0';
                else
                    if i_awready = '1' then r_awvalid <= '0'; end if;
                    if i_wready = '1' then r_wvalid <= '0'; end if;
                end if;

            when WAIT_DMA =>  -- Wait for the completion of the DMA transfer
                if (i_rvalid and i_rdata(1) and i_rdata(12)) = '1' then  -- CDMA in idle state and IOC set
                    state <= RESET;
                    r_awvalid <= '1';
                    r_wvalid <= '1';
                end if;
            
            when RESET =>
                if i_bvalid = '1' then
                    state <= IDLE;
                    r_done <= '1';
                    r_awvalid <= '0';
                    r_wvalid <= '0';
                else
                    if i_awready = '1' then r_awvalid <= '0'; end if;
                    if i_wready = '1' then r_wvalid <= '0'; end if;
                end if;

            end case;
        end if;
    end process;

end arch;
