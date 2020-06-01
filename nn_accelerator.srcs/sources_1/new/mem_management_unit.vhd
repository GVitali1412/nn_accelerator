library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_management_unit is
    port (
        clk             : in std_logic;
        i_reset         : in std_logic;

        i_addrInBuf     : in std_logic_vector(16 downto 0);
        i_addrWsBuf     : in std_logic_vector(10 downto 0);
        i_addrPsBuf     : in std_logic_vector(8 downto 0);
        i_addrOutBuf    : in std_logic_vector(8 downto 0);
        i_addrEn        : in std_logic;
        o_stall         : out std_logic;

        i_dmaQueueData  : in std_logic_vector(63 downto 0);
        i_dmaEnqueue    : in std_logic;
        o_dmaDone       : out std_logic;

        -- AXI4-lite master interface to CDMA IP
        o_araddrInBuf   : out std_logic_vector(31 downto 0);
        o_arvalidInBuf  : out std_logic;
        i_arreadyInBuf  : in std_logic;
        i_rdataInBuf    : in std_logic_vector(31 downto 0);
        i_rrespInBuf    : in std_logic_vector(1 downto 0);
        i_rvalidInBuf   : in std_logic;
        o_rreadyInBuf   : out std_logic;
        o_awaddrInBuf   : out std_logic_vector(31 downto 0);
        o_awvalidInBuf  : out std_logic;
        i_awreadyInBuf  : in std_logic;
        o_wdataInBuf    : out std_logic_vector(31 downto 0);
        o_wvalidInBuf   : out std_logic;
        i_wreadyInBuf   : in std_logic;
        i_brespInBuf    : in std_logic_vector(1 downto 0);
        i_bvalidInBuf   : in std_logic;
        o_breadyInBuf   : out std_logic;

        -- AXI4-lite master interface to CDMA IP
        o_araddrWsBuf   : out std_logic_vector(31 downto 0);
        o_arvalidWsBuf  : out std_logic;
        i_arreadyWsBuf  : in std_logic;
        i_rdataWsBuf    : in std_logic_vector(31 downto 0);
        i_rrespWsBuf    : in std_logic_vector(1 downto 0);
        i_rvalidWsBuf   : in std_logic;
        o_rreadyWsBuf   : out std_logic;
        o_awaddrWsBuf   : out std_logic_vector(31 downto 0);
        o_awvalidWsBuf  : out std_logic;
        i_awreadyWsBuf  : in std_logic;
        o_wdataWsBuf    : out std_logic_vector(31 downto 0);
        o_wvalidWsBuf   : out std_logic;
        i_wreadyWsBuf   : in std_logic;        
        i_brespWsBuf    : in std_logic_vector(1 downto 0);
        i_bvalidWsBuf   : in std_logic;
        o_breadyWsBuf   : out std_logic;

        -- AXI4-lite master interface to CDMA IP
        o_araddrPsBuf   : out std_logic_vector(31 downto 0);
        o_arvalidPsBuf  : out std_logic;
        i_arreadyPsBuf  : in std_logic;
        i_rdataPsBuf    : in std_logic_vector(31 downto 0);
        i_rrespPsBuf    : in std_logic_vector(1 downto 0);
        i_rvalidPsBuf   : in std_logic;
        o_rreadyPsBuf   : out std_logic;
        o_awaddrPsBuf   : out std_logic_vector(31 downto 0);
        o_awvalidPsBuf  : out std_logic;
        i_awreadyPsBuf  : in std_logic;
        o_wdataPsBuf    : out std_logic_vector(31 downto 0);
        o_wvalidPsBuf   : out std_logic;
        i_wreadyPsBuf   : in std_logic;
        i_brespPsBuf    : in std_logic_vector(1 downto 0);
        i_bvalidPsBuf   : in std_logic;
        o_breadyPsBuf   : out std_logic;

        -- AXI4-lite master interface to CDMA IP
        o_araddrOutBuf  : out std_logic_vector(31 downto 0);
        o_arvalidOutBuf : out std_logic;
        i_arreadyOutBuf : in std_logic;
        i_rdataOutBuf   : in std_logic_vector(31 downto 0);
        i_rrespOutBuf   : in std_logic_vector(1 downto 0);
        i_rvalidOutBuf  : in std_logic;
        o_rreadyOutBuf  : out std_logic;
        o_awaddrOutBuf  : out std_logic_vector(31 downto 0);
        o_awvalidOutBuf : out std_logic;
        i_awreadyOutBuf : in std_logic;
        o_wdataOutBuf   : out std_logic_vector(31 downto 0);
        o_wvalidOutBuf  : out std_logic;
        i_wreadyOutBuf  : in std_logic;
        i_brespOutBuf   : in std_logic_vector(1 downto 0);
        i_bvalidOutBuf  : in std_logic;
        o_breadyOutBuf  : out std_logic
    );
end mem_management_unit;

architecture arch of mem_management_unit is

    signal s_enqueueInBuf   : std_logic;
    signal s_enqueueWsBuf   : std_logic;
    signal s_enqueuePsBuf   : std_logic;
    signal s_enqueueOutBuf  : std_logic;

    signal s_dmaDoneInBuf   : std_logic;
    signal s_dmaDoneWsBuf   : std_logic;
    signal s_dmaDonePsBuf   : std_logic;
    signal s_dmaDoneOutBuf  : std_logic;

    signal s_queueFullIn    : std_logic;
    signal s_queueFullWs    : std_logic;
    signal s_queueFullPs    : std_logic;
    signal s_queueFullOut   : std_logic;

    signal s_slotIdUpInBuf  : std_logic_vector(7 downto 0);
    signal s_slotIdUpWsBuf  : std_logic_vector(8 downto 0);
    signal s_slotIdUpPsBuf  : std_logic_vector(6 downto 0);

    signal s_slotIdUpEnInBuf: std_logic;
    signal s_slotIdUpEnWsBuf: std_logic;
    signal s_slotIdUpEnPsBuf: std_logic;

    signal s_slotValidInBuf : std_logic;
    signal s_slotValidWsBuf : std_logic;
    signal s_slotValidPsBuf : std_logic;

    signal s_stallInBuf     : std_logic;
    signal s_stallWsBuf     : std_logic;
    signal s_stallPsBuf     : std_logic;

begin

    o_dmaDone <= s_dmaDoneInBuf or s_dmaDoneWsBuf or s_dmaDonePsBuf 
                    or s_dmaDoneOutBuf;

    s_enqueueInBuf <= '1' when i_dmaEnqueue = '1'
                               and i_dmaQueueData(1 downto 0) = "00"
                      else '0';
    
    s_enqueueWsBuf <= '1' when i_dmaEnqueue = '1'
                               and i_dmaQueueData(1 downto 0) = "01"
                      else '0';
    
    s_enqueuePsBuf <= '1' when i_dmaEnqueue = '1'
                               and i_dmaQueueData(1 downto 0) = "10"
                      else '0';
    
    s_enqueueOutBuf <= '1' when i_dmaEnqueue = '1'
                                and i_dmaQueueData(1 downto 0) = "11"
                       else '0';

    o_stall <= s_stallInBuf or s_stallWsBuf or s_stallPsBuf;


    input_dispatcher : entity work.cdma_dispatcher
    generic map (
        SLOT_ID_BITS    => 8,
        OFFSET_BITS     => 9
    )
    port map (
        clk             => clk,
        i_reset         => i_reset,
        o_dmaDone       => s_dmaDoneInBuf,
        i_queueDataIn   => i_dmaQueueData,
        i_enqueueReq    => s_enqueueInBuf,
        o_queueFull     => s_queueFullIn,

        o_slotIdUpdate  => s_slotIdUpInBuf,
        o_slotIdEn      => s_slotIdUpEnInBuf,
        o_slotValid     => s_slotValidInBuf,

        o_araddr        => o_araddrInBuf,
        o_arvalid       => o_arvalidInBuf,
        i_arready       => i_arreadyInBuf,
        i_rdata         => i_rdataInBuf,
        i_rresp         => i_rrespInBuf,
        i_rvalid        => i_rvalidInBuf,
        o_rready        => o_rreadyInBuf,
        o_awaddr        => o_awaddrInBuf,
        o_awvalid       => o_awvalidInBuf,
        i_awready       => i_awreadyInBuf,
        o_wdata         => o_wdataInBuf,
        o_wvalid        => o_wvalidInBuf,
        i_wready        => i_wreadyInBuf,
        i_bresp         => i_brespInBuf,
        i_bvalid        => i_bvalidInBuf,
        o_bready        => o_breadyInBuf
    );

    input_stall_gen : entity work.stall_generator
    generic map (
        SLOT_ID_BITS    => 8
    )
    port map (
        clk             => clk,
        o_stall         => s_stallInBuf,
        i_slotId        => i_addrInBuf(16 downto 9),
        i_slotIdEn      => i_addrEn,
        i_slotIdUpdate  => s_slotIdUpInBuf,
        i_slotIdUpEn    => s_slotIdUpEnInBuf,
        i_slotValid     => s_slotValidInBuf
    );


    weights_dispatcher : entity work.cdma_dispatcher
    generic map (
        SLOT_ID_BITS    => 9,
        OFFSET_BITS     => 2
    )
    port map (
        clk             => clk,
        i_reset         => i_reset,
        o_dmaDone       => s_dmaDoneWsBuf,
        i_queueDataIn   => i_dmaQueueData,
        i_enqueueReq    => s_enqueueWsBuf,
        o_queueFull     => s_queueFullWs,

        o_slotIdUpdate  => s_slotIdUpWsBuf,
        o_slotIdEn      => s_slotIdUpEnWsBuf,
        o_slotValid     => s_slotValidWsBuf,

        o_araddr        => o_araddrWsBuf,
        o_arvalid       => o_arvalidWsBuf,
        i_arready       => i_arreadyWsBuf,
        i_rdata         => i_rdataWsBuf,
        i_rresp         => i_rrespWsBuf,
        i_rvalid        => i_rvalidWsBuf,
        o_rready        => o_rreadyWsBuf,
        o_awaddr        => o_awaddrWsBuf,
        o_awvalid       => o_awvalidWsBuf,
        i_awready       => i_awreadyWsBuf,
        o_wdata         => o_wdataWsBuf,
        o_wvalid        => o_wvalidWsBuf,
        i_wready        => i_wreadyWsBuf,
        i_bresp         => i_brespWsBuf,
        i_bvalid        => i_bvalidWsBuf,
        o_bready        => o_breadyWsBuf
    );

    weights_stall_gen : entity work.stall_generator
    generic map (
        SLOT_ID_BITS    => 9
    )
    port map (
        clk             => clk,
        o_stall         => s_stallWsBuf,
        i_slotId        => i_addrWsBuf(10 downto 2),
        i_slotIdEn      => i_addrEn,
        i_slotIdUpdate  => s_slotIdUpWsBuf,
        i_slotIdUpEn    => s_slotIdUpEnWsBuf,
        i_slotValid     => s_slotValidWsBuf
    );


    psum_dispatcher : entity work.cdma_dispatcher
    generic map (
        SLOT_ID_BITS    => 7,
        OFFSET_BITS     => 2
    )
    port map (
        clk             => clk,
        i_reset         => i_reset,
        o_dmaDone       => s_dmaDonePsBuf,
        i_queueDataIn   => i_dmaQueueData,
        i_enqueueReq    => s_enqueuePsBuf,
        o_queueFull     => s_queueFullPs,

        o_slotIdUpdate  => s_slotIdUpPsBuf,
        o_slotIdEn      => s_slotIdUpEnPsBuf,
        o_slotValid     => s_slotValidPsBuf,

        o_araddr        => o_araddrPsBuf,
        o_arvalid       => o_arvalidPsBuf,
        i_arready       => i_arreadyPsBuf,
        i_rdata         => i_rdataPsBuf,
        i_rresp         => i_rrespPsBuf,
        i_rvalid        => i_rvalidPsBuf,
        o_rready        => o_rreadyPsBuf,
        o_awaddr        => o_awaddrPsBuf,
        o_awvalid       => o_awvalidPsBuf,
        i_awready       => i_awreadyPsBuf,
        o_wdata         => o_wdataPsBuf,
        o_wvalid        => o_wvalidPsBuf,
        i_wready        => i_wreadyPsBuf,
        i_bresp         => i_brespPsBuf,
        i_bvalid        => i_bvalidPsBuf,
        o_bready        => o_breadyPsBuf
    );

    psum_stall_gen : entity work.stall_generator
    generic map (
        SLOT_ID_BITS    => 7
    )
    port map (
        clk             => clk,
        o_stall         => s_stallPsBuf,
        i_slotId        => i_addrPsBuf(8 downto 2),
        i_slotIdEn      => i_addrEn,
        i_slotIdUpdate  => s_slotIdUpPsBuf,
        i_slotIdUpEn    => s_slotIdUpEnPsBuf,
        i_slotValid     => s_slotValidPsBuf
    );


    output_dispatcher : entity work.cdma_dispatcher
    generic map (
        SLOT_ID_BITS    => 7,
        OFFSET_BITS     => 2
    )
    port map (
        clk             => clk,
        i_reset         => i_reset,
        o_dmaDone       => s_dmaDoneOutBuf,
        i_queueDataIn   => i_dmaQueueData,
        i_enqueueReq    => s_enqueueOutBuf,
        o_queueFull     => s_queueFullOut,

        o_slotIdUpdate  => open,
        o_slotIdEn      => open,
        o_slotValid     => open,

        o_araddr        => o_araddrOutBuf,
        o_arvalid       => o_arvalidOutBuf,
        i_arready       => i_arreadyOutBuf,
        i_rdata         => i_rdataOutBuf,
        i_rresp         => i_rrespOutBuf,
        i_rvalid        => i_rvalidOutBuf,
        o_rready        => o_rreadyOutBuf,
        o_awaddr        => o_awaddrOutBuf,
        o_awvalid       => o_awvalidOutBuf,
        i_awready       => i_awreadyOutBuf,
        o_wdata         => o_wdataOutBuf,
        o_wvalid        => o_wvalidOutBuf,
        i_wready        => i_wreadyOutBuf,
        i_bresp         => i_brespOutBuf,
        i_bvalid        => i_bvalidOutBuf,
        o_bready        => o_breadyOutBuf
    );

end arch;
