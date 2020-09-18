library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity nn_accelerator is
    port (
        clk             : in std_logic;
        rstn            : in std_logic;

        inBuf_wEn       : in std_logic;
        inBuf_we        : in std_logic_vector(7 downto 0);
        inBuf_wAddr     : in std_logic_vector(16 downto 0);
        inBuf_wData     : in std_logic_vector(63 downto 0);
        inBuf_rst       : in std_logic;
        inBuf_clk       : in std_logic;

        wsBuf_wEn       : in std_logic;
        wsBuf_we        : in std_logic_vector(7 downto 0);
        wsBuf_wAddr     : in std_logic_vector(17 downto 0);
        wsBuf_wData     : in std_logic_vector(63 downto 0);
        wsBuf_rst       : in std_logic;
        wsBuf_clk       : in std_logic;

        psumBuf_wEn     : in std_logic;
        psumBuf_we      : in std_logic_vector(7 downto 0);
        psumBuf_wAddr   : in std_logic_vector(15 downto 0);
        psumBuf_wData   : in std_logic_vector(63 downto 0);
        psumBuf_rst     : in std_logic;
        psumBuf_clk     : in std_logic;

        outBuf_rEn      : in std_logic;
        outBuf_rAddr    : in std_logic_vector(15 downto 0);
        outBuf_rData    : out std_logic_vector(63 downto 0);
        outBuf_rst      : in std_logic;
        outBuf_clk      : in std_logic;

        instrBuf_wEn     : in std_logic;
        instrBuf_we     : in std_logic_vector(7 downto 0);
        instrBuf_wAddr   : in std_logic_vector(11 downto 0);
        instrBuf_wData  : in std_logic_vector(63 downto 0);
        instrBuf_rst    : in std_logic;
        instrBuf_clk    : in std_logic;

        -- Control axi slave interface
        s00_axi_awaddr  : in std_logic_vector(3 downto 0);
        s00_axi_awprot  : in std_logic_vector(2 downto 0);
        s00_axi_awvalid : in std_logic;
        s00_axi_awready : out std_logic;
        s00_axi_wdata   : in std_logic_vector(31 downto 0);
        s00_axi_wstrb   : in std_logic_vector(3 downto 0);
        s00_axi_wvalid  : in std_logic;
        s00_axi_wready  : out std_logic;
        s00_axi_bresp   : out std_logic_vector(1 downto 0);
        s00_axi_bvalid  : out std_logic;
        s00_axi_bready  : in std_logic;
        s00_axi_araddr  : in std_logic_vector(3 downto 0);
        s00_axi_arprot  : in std_logic_vector(2 downto 0);
        s00_axi_arvalid : in std_logic;
        s00_axi_arready : out std_logic;
        s00_axi_rdata   : out std_logic_vector(31 downto 0);
        s00_axi_rresp   : out std_logic_vector(1 downto 0);
        s00_axi_rvalid  : out std_logic;
        s00_axi_rready  : in std_logic;
        
        -- CDMA axi master interface
        m00_axi_araddr  : out std_logic_vector(31 downto 0);
        m00_axi_arvalid : out std_logic;
        m00_axi_arready : in std_logic;
        m00_axi_rdata   : in std_logic_vector(31 downto 0);
        m00_axi_rresp   : in std_logic_vector(1 downto 0);
        m00_axi_rvalid  : in std_logic;
        m00_axi_rready  : out std_logic;
        m00_axi_awaddr  : out std_logic_vector(31 downto 0);
        m00_axi_awvalid : out std_logic;
        m00_axi_awready : in std_logic;
        m00_axi_wdata   : out std_logic_vector(31 downto 0);
        m00_axi_wvalid  : out std_logic;
        m00_axi_wready  : in std_logic;
        m00_axi_bresp   : in std_logic_vector(1 downto 0);
        m00_axi_bvalid  : in std_logic;
        m00_axi_bready  : out std_logic;

        m01_axi_araddr  : out std_logic_vector(31 downto 0);
        m01_axi_arvalid : out std_logic;
        m01_axi_arready : in std_logic;
        m01_axi_rdata   : in std_logic_vector(31 downto 0);
        m01_axi_rresp   : in std_logic_vector(1 downto 0);
        m01_axi_rvalid  : in std_logic;
        m01_axi_rready  : out std_logic;
        m01_axi_awaddr  : out std_logic_vector(31 downto 0);
        m01_axi_awvalid : out std_logic;
        m01_axi_awready : in std_logic;
        m01_axi_wdata   : out std_logic_vector(31 downto 0);
        m01_axi_wvalid  : out std_logic;
        m01_axi_wready  : in std_logic;
        m01_axi_bresp   : in std_logic_vector(1 downto 0);
        m01_axi_bvalid  : in std_logic;
        m01_axi_bready  : out std_logic;

        m02_axi_araddr  : out std_logic_vector(31 downto 0);
        m02_axi_arvalid : out std_logic;
        m02_axi_arready : in std_logic;
        m02_axi_rdata   : in std_logic_vector(31 downto 0);
        m02_axi_rresp   : in std_logic_vector(1 downto 0);
        m02_axi_rvalid  : in std_logic;
        m02_axi_rready  : out std_logic;
        m02_axi_awaddr  : out std_logic_vector(31 downto 0);
        m02_axi_awvalid : out std_logic;
        m02_axi_awready : in std_logic;
        m02_axi_wdata   : out std_logic_vector(31 downto 0);
        m02_axi_wvalid  : out std_logic;
        m02_axi_wready  : in std_logic;
        m02_axi_bresp   : in std_logic_vector(1 downto 0);
        m02_axi_bvalid  : in std_logic;
        m02_axi_bready  : out std_logic;

        m03_axi_araddr  : out std_logic_vector(31 downto 0);
        m03_axi_arvalid : out std_logic;
        m03_axi_arready : in std_logic;
        m03_axi_rdata   : in std_logic_vector(31 downto 0);
        m03_axi_rresp   : in std_logic_vector(1 downto 0);
        m03_axi_rvalid  : in std_logic;
        m03_axi_rready  : out std_logic;
        m03_axi_awaddr  : out std_logic_vector(31 downto 0);
        m03_axi_awvalid : out std_logic;
        m03_axi_awready : in std_logic;
        m03_axi_wdata   : out std_logic_vector(31 downto 0);
        m03_axi_wvalid  : out std_logic;
        m03_axi_wready  : in std_logic;
        m03_axi_bresp   : in std_logic_vector(1 downto 0);
        m03_axi_bvalid  : in std_logic;
        m03_axi_bready  : out std_logic
    );
end nn_accelerator;

architecture arch of nn_accelerator is

    signal s_reset          : std_logic;

    signal s_stall          : std_logic;
    signal s_addrEn         : std_logic;
    
    signal s_ctrlReg0       : std_logic_vector(31 downto 0);
    signal s_ctrlReg1       : std_logic_vector(31 downto 0);
    signal s_ctrlReg2       : std_logic_vector(31 downto 0);
    signal s_ctrlReg3       : std_logic_vector(31 downto 0);
    signal s_rstCtrlReg     : std_logic;

    signal s_clearAccum     : std_logic;
    signal s_loadPartSum    : std_logic;
    signal s_enActivation   : std_logic;

    signal s_inBufREn      : std_logic;
    signal s_inBufRAddr    : std_logic_vector(16 downto 0);
    signal s_inBufRData    : std_logic_vector(7 downto 0);

    signal s_wsBufREn      : std_logic;
    signal s_wsBufRAddr    : std_logic_vector(10 downto 0);
    signal s_wsBufRData    : std_logic_vector(1023 downto 0);

    signal s_psumBufREn    : std_logic;
    signal s_psumBufRAddr  : std_logic_vector(8 downto 0);
    signal s_psumBufRData  : std_logic_vector(1023 downto 0);

    signal s_outBufWEn     : std_logic;
    signal s_outBufWe      : std_logic_vector(0 downto 0);
    signal s_outBufWAddr   : std_logic_vector(8 downto 0);
    signal s_outBufWData   : std_logic_vector(1023 downto 0);

    -- Instruction buffer
    signal s_instruction    : std_logic_vector(63 downto 0);
    signal s_instrPtr       : std_logic_vector(8 downto 0);
    signal s_enInstr        : std_logic;

    -- CDMA signals
    signal s_dmaDone        : std_logic;
    signal s_queueDataIn    : std_logic_vector(63 downto 0);
    signal s_enqueuReq      : std_logic;
    signal s_queueFull      : std_logic;
    

    component input_buffer
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(0 downto 0);
            addra           : in std_logic_vector(13 downto 0);
            dina            : in std_logic_vector(63 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(16 downto 0);
            doutb           : out std_logic_vector(7 downto 0)
        );
    end component;

    component weights_buffer
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(0 downto 0);
            addra           : in std_logic_vector(14 downto 0);
            dina            : in std_logic_vector(63 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(10 downto 0);
            doutb           : out std_logic_vector(1023 downto 0)
        );
    end component;

    component partialSum_buffer
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(0 downto 0);
            addra           : in std_logic_vector(12 downto 0);
            dina            : in std_logic_vector(63 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(8 downto 0);
            doutb           : out std_logic_vector(1023 downto 0)
        );
    end component;

    component output_buffer
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(0 downto 0);
            addra           : in std_logic_vector(8 downto 0);
            dina            : in std_logic_vector(1023 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(12 downto 0);
            doutb           : out std_logic_vector(63 downto 0)
        );
    end component;

    component instruction_buffer
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(7 downto 0);
            addra           : in std_logic_vector(8 downto 0);
            dina            : in std_logic_vector(63 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(8 downto 0);
            doutb           : out std_logic_vector(63 downto 0)
        );
    end component;

    attribute X_INTERFACE_INFO : STRING;
    attribute X_INTERFACE_INFO of instrBuf_wEn: signal is "xilinx.com:interface:bram:1.0 instrBuf EN";
    attribute X_INTERFACE_INFO of instrBuf_wData: signal is "xilinx.com:interface:bram:1.0 instrBuf DIN";
    attribute X_INTERFACE_INFO of instrBuf_we: signal is "xilinx.com:interface:bram:1.0 instrBuf WE";
    attribute X_INTERFACE_INFO of instrBuf_wAddr: signal is "xilinx.com:interface:bram:1.0 instrBuf ADDR";
    attribute X_INTERFACE_INFO of instrBuf_clk: signal is "xilinx.com:interface:bram:1.0 instrBuf CLK";
    attribute X_INTERFACE_INFO of instrBuf_rst: signal is "xilinx.com:interface:bram:1.0 instrBuf RST";

    attribute X_INTERFACE_INFO of inBuf_wEn: signal is "xilinx.com:interface:bram:1.0 inBuf EN";
    attribute X_INTERFACE_INFO of inBuf_wData: signal is "xilinx.com:interface:bram:1.0 inBuf DIN";
    attribute X_INTERFACE_INFO of inBuf_we: signal is "xilinx.com:interface:bram:1.0 inBuf WE";
    attribute X_INTERFACE_INFO of inBuf_wAddr: signal is "xilinx.com:interface:bram:1.0 inBuf ADDR";
    attribute X_INTERFACE_INFO of inBuf_clk: signal is "xilinx.com:interface:bram:1.0 inBuf CLK";
    attribute X_INTERFACE_INFO of inBuf_rst: signal is "xilinx.com:interface:bram:1.0 inBuf RST";

    attribute X_INTERFACE_INFO of wsBuf_wEn: signal is "xilinx.com:interface:bram:1.0 wsBuf EN";
    attribute X_INTERFACE_INFO of wsBuf_wData: signal is "xilinx.com:interface:bram:1.0 wsBuf DIN";
    attribute X_INTERFACE_INFO of wsBuf_we: signal is "xilinx.com:interface:bram:1.0 wsBuf WE";
    attribute X_INTERFACE_INFO of wsBuf_wAddr: signal is "xilinx.com:interface:bram:1.0 wsBuf ADDR";
    attribute X_INTERFACE_INFO of wsBuf_clk: signal is "xilinx.com:interface:bram:1.0 wsBuf CLK";
    attribute X_INTERFACE_INFO of wsBuf_rst: signal is "xilinx.com:interface:bram:1.0 wsBuf RST";

    attribute X_INTERFACE_INFO of psumBuf_wEn: signal is "xilinx.com:interface:bram:1.0 psumBuf EN";
    attribute X_INTERFACE_INFO of psumBuf_wData: signal is "xilinx.com:interface:bram:1.0 psumBuf DIN";
    attribute X_INTERFACE_INFO of psumBuf_we: signal is "xilinx.com:interface:bram:1.0 psumBuf WE";
    attribute X_INTERFACE_INFO of psumBuf_wAddr: signal is "xilinx.com:interface:bram:1.0 psumBuf ADDR";
    attribute X_INTERFACE_INFO of psumBuf_clk: signal is "xilinx.com:interface:bram:1.0 psumBuf CLK";
    attribute X_INTERFACE_INFO of psumBuf_rst: signal is "xilinx.com:interface:bram:1.0 psumBuf RST";

    attribute X_INTERFACE_INFO of outBuf_rEn: signal is "xilinx.com:interface:bram:1.0 outBuf EN";
    attribute X_INTERFACE_INFO of outBuf_rData: signal is "xilinx.com:interface:bram:1.0 outBuf DOUT";
    attribute X_INTERFACE_INFO of outBuf_rAddr: signal is "xilinx.com:interface:bram:1.0 outBuf ADDR";
    attribute X_INTERFACE_INFO of outBuf_rst: signal is "xilinx.com:interface:bram:1.0 outBuf CLK";
    attribute X_INTERFACE_INFO of outBuf_clk: signal is "xilinx.com:interface:bram:1.0 outBuf RST";

begin

    s_reset <= not rstn;

    control_registers : entity work.axi4lite_controls
    port map (
        clk             => clk,
        rstn            => rstn,
        i_rstReg        => s_rstCtrlReg,
        o_reg0          => s_ctrlReg0,
        o_reg1          => s_ctrlReg1,
        o_reg2          => s_ctrlReg2,
        o_reg3          => s_ctrlReg3,
        axi_awaddr      => s00_axi_awaddr,
        axi_awvalid     => s00_axi_awvalid,
        axi_awready     => s00_axi_awready,
        axi_wdata       => s00_axi_wdata,
        axi_wstrb       => s00_axi_wstrb,
        axi_wvalid      => s00_axi_wvalid,
        axi_wready      => s00_axi_wready,
        axi_bresp       => s00_axi_bresp,
        axi_bvalid      => s00_axi_bvalid,
        axi_bready      => s00_axi_bready,
        axi_araddr      => s00_axi_araddr,
        axi_arvalid     => s00_axi_arvalid,
        axi_arready     => s00_axi_arready,
        axi_rdata       => s00_axi_rdata,
        axi_rresp       => s00_axi_rresp,
        axi_rvalid      => s00_axi_rvalid,
        axi_rready      => s00_axi_rready
    );

    controller : entity work.controller
    port map (
        clk             => clk,
        i_stall         => s_stall,
        o_addrEn        => s_addrEn,
        i_ctrlReg0      => s_ctrlReg0,
        i_ctrlReg1      => s_ctrlReg1,
        i_ctrlReg2      => s_ctrlReg2,
        i_ctrlReg3      => s_ctrlReg3,
        o_rstCtrlReg    => s_rstCtrlReg,
        o_enInstr       => s_enInstr,
        o_instrPtr      => s_instrPtr,
        i_instruction   => s_instruction,
        o_clearAccum    => s_clearAccum,
        o_loadPartSum   => s_loadPartSum,
        o_enActivation  => s_enActivation,
        o_inBufEn       => s_inBufREn,
        o_inBufAddr     => s_inBufRAddr,
        o_wsBufEn       => s_wsBufREn,
        o_wsBufAddr     => s_wsBufRAddr,
        o_psBufEn       => s_psumBufREn,
        o_psBufAddr     => s_psumBufRAddr,
        o_outBufEn      => s_outBufWEn,
        o_outBufWe      => s_outBufWe(0),
        o_outBufAddr    => s_outBufWAddr,
        i_dmaDone       => s_dmaDone,
        o_queueDataIn   => s_queueDataIn,
        o_enqueueReq    => s_enqueuReq,
        i_queueFull     => s_queueFull
    );

    conv_engine : entity work.convolution_engine
    port map (
        clk             => clk,
        i_stall         => s_stall,
        i_clearAccum    => s_clearAccum,
        i_loadPartSum   => s_loadPartSum,
        i_enActivation  => s_enActivation,
        i_inBufData     => s_inBufRData,
        i_wgsBufData    => s_wsBufRData,
        i_psumBufData   => s_psumBufRData,
        o_outBufData    => s_outBufWData
    );

    mmu : entity work.mem_management_unit
    port map (
        clk             => clk,
        i_reset         => s_reset,

        i_addrInBuf     => s_inBufRAddr,
        i_addrWsBuf     => s_wsBufRAddr,
        i_addrPsBuf     => s_psumBufRAddr,
        i_addrOutBuf    => s_outBufWAddr,
        i_addrEn        => s_addrEn,
        o_stall         => s_stall,

        i_dmaQueueData  => s_queueDataIn,
        i_dmaEnqueue    => s_enqueuReq,
        o_dmaDone       => s_dmaDone,

        -- AXI4-lite master interface to CDMA IP
        o_araddrInBuf   => m00_axi_araddr,
        o_arvalidInBuf  => m00_axi_arvalid,
        i_arreadyInBuf  => m00_axi_arready,
        i_rdataInBuf    => m00_axi_rdata,
        i_rrespInBuf    => m00_axi_rresp,
        i_rvalidInBuf   => m00_axi_rvalid,
        o_rreadyInBuf   => m00_axi_rready,
        o_awaddrInBuf   => m00_axi_awaddr,
        o_awvalidInBuf  => m00_axi_awvalid,
        i_awreadyInBuf  => m00_axi_awready,
        o_wdataInBuf    => m00_axi_wdata,
        o_wvalidInBuf   => m00_axi_wvalid,
        i_wreadyInBuf   => m00_axi_wready,
        i_brespInBuf    => m00_axi_bresp,
        i_bvalidInBuf   => m00_axi_bvalid,
        o_breadyInBuf   => m00_axi_bready,

        -- AXI4-lite master interface to CDMA IP
        o_araddrWsBuf   => m01_axi_araddr,
        o_arvalidWsBuf  => m01_axi_arvalid,
        i_arreadyWsBuf  => m01_axi_arready,
        i_rdataWsBuf    => m01_axi_rdata,
        i_rrespWsBuf    => m01_axi_rresp,
        i_rvalidWsBuf   => m01_axi_rvalid,
        o_rreadyWsBuf   => m01_axi_rready,
        o_awaddrWsBuf   => m01_axi_awaddr,
        o_awvalidWsBuf  => m01_axi_awvalid,
        i_awreadyWsBuf  => m01_axi_awready,
        o_wdataWsBuf    => m01_axi_wdata,
        o_wvalidWsBuf   => m01_axi_wvalid,
        i_wreadyWsBuf   => m01_axi_wready,
        i_brespWsBuf    => m01_axi_bresp,
        i_bvalidWsBuf   => m01_axi_bvalid,
        o_breadyWsBuf   => m01_axi_bready,

        -- AXI4-lite master interface to CDMA IP
        o_araddrPsBuf   => m02_axi_araddr,
        o_arvalidPsBuf  => m02_axi_arvalid,
        i_arreadyPsBuf  => m02_axi_arready,
        i_rdataPsBuf    => m02_axi_rdata,
        i_rrespPsBuf    => m02_axi_rresp,
        i_rvalidPsBuf   => m02_axi_rvalid,
        o_rreadyPsBuf   => m02_axi_rready,
        o_awaddrPsBuf   => m02_axi_awaddr,
        o_awvalidPsBuf  => m02_axi_awvalid,
        i_awreadyPsBuf  => m02_axi_awready,
        o_wdataPsBuf    => m02_axi_wdata,
        o_wvalidPsBuf   => m02_axi_wvalid,
        i_wreadyPsBuf   => m02_axi_wready,
        i_brespPsBuf    => m02_axi_bresp,
        i_bvalidPsBuf   => m02_axi_bvalid,
        o_breadyPsBuf   => m02_axi_bready,

        -- AXI4-lite master interface to CDMA IP
        o_araddrOutBuf  => m03_axi_araddr,
        o_arvalidOutBuf => m03_axi_arvalid,
        i_arreadyOutBuf => m03_axi_arready,
        i_rdataOutBuf   => m03_axi_rdata,
        i_rrespOutBuf   => m03_axi_rresp,
        i_rvalidOutBuf  => m03_axi_rvalid,
        o_rreadyOutBuf  => m03_axi_rready,
        o_awaddrOutBuf  => m03_axi_awaddr,
        o_awvalidOutBuf => m03_axi_awvalid,
        i_awreadyOutBuf => m03_axi_awready,
        o_wdataOutBuf   => m03_axi_wdata,
        o_wvalidOutBuf  => m03_axi_wvalid,
        i_wreadyOutBuf  => m03_axi_wready,
        i_brespOutBuf   => m03_axi_bresp,
        i_bvalidOutBuf  => m03_axi_bvalid,
        o_breadyOutBuf  => m03_axi_bready
    );

    in_buffer : input_buffer
    port map (
        clka            => inBuf_clk,
        ena             => inBuf_wEn,
        wea             => inBuf_we(0 downto 0),
        addra           => inBuf_wAddr(16 downto 3),
        dina            => inBuf_wData,
        clkb            => clk,
        enb             => s_inBufREn,
        addrb           => s_inBufRAddr,
        doutb           => s_inBufRData
    );

    ws_buffer : weights_buffer
    port map (
        clka            => wsBuf_clk,
        ena             => wsBuf_wEn,
        wea             => wsBuf_we(0 downto 0),
        addra           => wsBuf_wAddr(17 downto 3),
        dina            => wsBuf_wData,
        clkb            => clk,
        enb             => s_wsBufREn,
        addrb           => s_wsBufRAddr,
        doutb           => s_wsBufRData
    );

    psum_buffer : partialSum_buffer
    port map (
        clka            => psumBuf_clk,
        ena             => psumBuf_wEn,
        wea             => psumBuf_we(0 downto 0),
        addra           => psumBuf_wAddr(15 downto 3),
        dina            => psumBuf_wData,
        clkb            => clk,
        enb             => s_psumBufREn,
        addrb           => s_psumBufRAddr,
        doutb           => s_psumBufRData
    );

    out_buffer : output_buffer
    port map (
        clka            => clk,
        ena             => s_outBufWEn,
        wea             => s_outBufWe,
        addra           => s_outBufWAddr,
        dina            => s_outBufWData,
        clkb            => outBuf_clk,
        enb             => outBuf_rEn,
        addrb           => outBuf_rAddr(15 downto 3),
        doutb           => outBuf_rData
    );

    instr_buffer : instruction_buffer
    port map (
        clka            => instrBuf_clk,
        ena             => instrBuf_wEn,
        wea             => instrBuf_we,
        addra           => instrBuf_wAddr(11 downto 3),
        dina            => instrBuf_wData,
        clkb            => clk,
        enb             => s_enInstr,
        addrb           => s_instrPtr,
        doutb           => s_instruction
    );


end arch;
