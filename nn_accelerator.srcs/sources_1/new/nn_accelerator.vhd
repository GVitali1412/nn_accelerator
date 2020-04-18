library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity nn_accelerator is
    port (
        clk             : in std_logic;
        rstn            : in std_logic;
        
        -- Control interface
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
        
        -- in block ram interface
        s01_axi_awaddr  : in std_logic_vector(17 downto 0);
        s01_axi_awprot  : in std_logic_vector(2 downto 0);
        s01_axi_awvalid : in std_logic;
        s01_axi_awready : out std_logic;
        s01_axi_wdata   : in std_logic_vector(31 downto 0);
        s01_axi_wstrb   : in std_logic_vector(3 downto 0);
        s01_axi_wvalid  : in std_logic;
        s01_axi_wready  : out std_logic;
        s01_axi_bresp   : out std_logic_vector(1 downto 0);
        s01_axi_bvalid  : out std_logic;
        s01_axi_bready  : in std_logic;
        s01_axi_araddr  : in std_logic_vector(17 downto 0);
        s01_axi_arprot  : in std_logic_vector(2 downto 0);
        s01_axi_arvalid : in std_logic;
        s01_axi_arready : out std_logic;
        s01_axi_rdata   : out std_logic_vector(31 downto 0);
        s01_axi_rresp   : out std_logic_vector(1 downto 0);
        s01_axi_rvalid  : out std_logic;
        s01_axi_rready  : in std_logic;
        
        -- out block ram interface
        s02_axi_awaddr  : in std_logic_vector(15 downto 0);
        s02_axi_awprot  : in std_logic_vector(2 downto 0);
        s02_axi_awvalid : in std_logic;
        s02_axi_awready : out std_logic;
        s02_axi_wdata   : in std_logic_vector(31 downto 0);
        s02_axi_wstrb   : in std_logic_vector(3 downto 0);
        s02_axi_wvalid  : in std_logic;
        s02_axi_wready  : out std_logic;
        s02_axi_bresp   : out std_logic_vector(1 downto 0);
        s02_axi_bvalid  : out std_logic;
        s02_axi_bready  : in std_logic;
        s02_axi_araddr  : in std_logic_vector(15 downto 0);
        s02_axi_arprot  : in std_logic_vector(2 downto 0);
        s02_axi_arvalid : in std_logic;
        s02_axi_arready : out std_logic;
        s02_axi_rdata   : out std_logic_vector(31 downto 0);
        s02_axi_rresp   : out std_logic_vector(1 downto 0);
        s02_axi_rvalid  : out std_logic;
        s02_axi_rready  : in std_logic;
        
        -- weights block ram interface
        s03_axi_awaddr  : in std_logic_vector(15 downto 0);
        s03_axi_awprot  : in std_logic_vector(2 downto 0);
        s03_axi_awvalid : in std_logic;
        s03_axi_awready : out std_logic;
        s03_axi_wdata   : in std_logic_vector(31 downto 0);
        s03_axi_wstrb   : in std_logic_vector(3 downto 0);
        s03_axi_wvalid  : in std_logic;
        s03_axi_wready  : out std_logic;
        s03_axi_bresp   : out std_logic_vector(1 downto 0);
        s03_axi_bvalid  : out std_logic;
        s03_axi_bready  : in std_logic;
        s03_axi_araddr  : in std_logic_vector(15 downto 0);
        s03_axi_arprot  : in std_logic_vector(2 downto 0);
        s03_axi_arvalid : in std_logic;
        s03_axi_arready : out std_logic;
        s03_axi_rdata   : out std_logic_vector(31 downto 0);
        s03_axi_rresp   : out std_logic_vector(1 downto 0);
        s03_axi_rvalid  : out std_logic;
        s03_axi_rready  : in std_logic
    );
end nn_accelerator;

architecture arch of nn_accelerator is
    
    -- temporary start signal
    signal start : std_logic;

    signal in_bram_en_a     : std_logic;
    signal in_bram_we_a     : std_logic_vector(3 downto 0);
    signal in_bram_addr_a   : std_logic_vector(17 downto 0);
    signal in_bram_wrdata_a : std_logic_vector(31 downto 0);
    signal in_bram_en_b     : std_logic;
    signal in_bram_addr_b   : std_logic_vector(17 downto 0);
    signal in_bram_rddata_b : std_logic_vector(7 downto 0);

    signal out_bram_en_a    : std_logic;
    signal out_bram_we_a    : std_logic_vector(0 downto 0);
    signal out_bram_addr_a  : std_logic_vector(8 downto 0);
    signal out_bram_wrdata_a: std_logic_vector(1023 downto 0);
    signal out_bram_en_b    : std_logic;
    signal out_bram_addr_b  : std_logic_vector(15 downto 0);
    signal out_bram_rddata_b: std_logic_vector(31 downto 0);

    signal w_bram_en_a      : std_logic;
    signal w_bram_we_a      : std_logic_vector(3 downto 0);
    signal w_bram_addr_a    : std_logic_vector(15 downto 0);
    signal w_bram_wrdata_a  : std_logic_vector(31 downto 0);
    signal w_bram_en_b      : std_logic;
    signal w_bram_addr_b    : std_logic_vector(8 downto 0);
    signal w_bram_rddata_b  : std_logic_vector(1023 downto 0);

    component in_bram
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(3 downto 0);
            addra           : in std_logic_vector(15 downto 0);
            dina            : in std_logic_vector(31 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(17 downto 0);
            doutb           : out std_logic_vector(7 downto 0)
        );
    end component;

    component out_bram
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(0 downto 0);
            addra           : in std_logic_vector(8 downto 0);
            dina            : in std_logic_vector(1023 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(13 downto 0);
            doutb           : out std_logic_vector(31 downto 0)
        );
    end component;

    component weights_bram
        port (
            clka            : in std_logic;
            ena             : in std_logic;
            wea             : in std_logic_vector(0 downto 0);
            addra           : in std_logic_vector(13 downto 0);
            dina            : in std_logic_vector(31 downto 0);
            clkb            : in std_logic;
            enb             : in std_logic;
            addrb           : in std_logic_vector(8 downto 0);
            doutb           : out std_logic_vector(1023 downto 0)
        );
    end component;

    component in_bram_controller
        port (
            s_axi_aclk      : in std_logic;
            s_axi_aresetn   : in std_logic;
            s_axi_awaddr    : in std_logic_vector(17 downto 0);
            s_axi_awprot    : in std_logic_vector(2 downto 0);
            s_axi_awvalid   : in std_logic;
            s_axi_awready   : out std_logic;
            s_axi_wdata     : in std_logic_vector(31 downto 0);
            s_axi_wstrb     : in std_logic_vector(3 downto 0);
            s_axi_wvalid    : in std_logic;
            s_axi_wready    : out std_logic;
            s_axi_bresp     : out std_logic_vector(1 downto 0);
            s_axi_bvalid    : out std_logic;
            s_axi_bready    : in std_logic;
            s_axi_araddr    : in std_logic_vector(17 downto 0);
            s_axi_arprot    : in std_logic_vector(2 downto 0);
            s_axi_arvalid   : in std_logic;
            s_axi_arready   : out std_logic;
            s_axi_rdata     : out std_logic_vector(31 downto 0);
            s_axi_rresp     : out std_logic_vector(1 downto 0);
            s_axi_rvalid    : out std_logic;
            s_axi_rready    : in std_logic;
            bram_rst_a      : out std_logic;
            bram_clk_a      : out std_logic;
            bram_en_a       : out std_logic;
            bram_we_a       : out std_logic_vector(3 downto 0);
            bram_addr_a     : out std_logic_vector(17 downto 0);
            bram_wrdata_a   : out std_logic_vector(31 downto 0);
            bram_rddata_a   : in std_logic_vector(31 downto 0)
        );
    end component;

    component out_bram_controller
        port (
            s_axi_aclk      : in std_logic;
            s_axi_aresetn   : in std_logic;
            s_axi_awaddr    : in std_logic_vector(15 downto 0);
            s_axi_awprot    : in std_logic_vector(2 downto 0);
            s_axi_awvalid   : in std_logic;
            s_axi_awready   : out std_logic;
            s_axi_wdata     : in std_logic_vector(31 downto 0);
            s_axi_wstrb     : in std_logic_vector(3 downto 0);
            s_axi_wvalid    : in std_logic;
            s_axi_wready    : out std_logic;
            s_axi_bresp     : out std_logic_vector(1 downto 0);
            s_axi_bvalid    : out std_logic;
            s_axi_bready    : in std_logic;
            s_axi_araddr    : in std_logic_vector(15 downto 0);
            s_axi_arprot    : in std_logic_vector(2 downto 0);
            s_axi_arvalid   : in std_logic;
            s_axi_arready   : out std_logic;
            s_axi_rdata     : out std_logic_vector(31 downto 0);
            s_axi_rresp     : out std_logic_vector(1 downto 0);
            s_axi_rvalid    : out std_logic;
            s_axi_rready    : in std_logic;
            bram_rst_a      : out std_logic;
            bram_clk_a      : out std_logic;
            bram_en_a       : out std_logic;
            bram_we_a       : out std_logic_vector(3 downto 0);
            bram_addr_a     : out std_logic_vector(15 downto 0);
            bram_wrdata_a   : out std_logic_vector(31 downto 0);
            bram_rddata_a   : in std_logic_vector(31 downto 0)
        );
    end component;

    component weights_bram_controller
        port (
            s_axi_aclk      : in std_logic;
            s_axi_aresetn   : in std_logic;
            s_axi_awaddr    : in std_logic_vector(15 downto 0);
            s_axi_awprot    : in std_logic_vector(2 downto 0);
            s_axi_awvalid   : in std_logic;
            s_axi_awready   : out std_logic;
            s_axi_wdata     : in std_logic_vector(31 downto 0);
            s_axi_wstrb     : in std_logic_vector(3 downto 0);
            s_axi_wvalid    : in std_logic;
            s_axi_wready    : out std_logic;
            s_axi_bresp     : out std_logic_vector(1 downto 0);
            s_axi_bvalid    : out std_logic;
            s_axi_bready    : in std_logic;
            s_axi_araddr    : in std_logic_vector(15 downto 0);
            s_axi_arprot    : in std_logic_vector(2 downto 0);
            s_axi_arvalid   : in std_logic;
            s_axi_arready   : out std_logic;
            s_axi_rdata     : out std_logic_vector(31 downto 0);
            s_axi_rresp     : out std_logic_vector(1 downto 0);
            s_axi_rvalid    : out std_logic;
            s_axi_rready    : in std_logic;
            bram_rst_a      : out std_logic;
            bram_clk_a      : out std_logic;
            bram_en_a       : out std_logic;
            bram_we_a       : out std_logic_vector(3 downto 0);
            bram_addr_a     : out std_logic_vector(15 downto 0);
            bram_wrdata_a   : out std_logic_vector(31 downto 0);
            bram_rddata_a   : in std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- temporary start module
    start_mod : entity work.start_module
    port map (
        clk             => clk,
        rstn            => rstn,
        start           => start
    );
    

    in_block_ram : in_bram
    port map (
        clka            => clk,
        ena             => in_bram_en_a,
        wea             => in_bram_we_a,
        addra           => in_bram_addr_a(17 downto 2),
        dina            => in_bram_wrdata_a,
        clkb            => clk,
        enb             => in_bram_en_b,
        addrb           => in_bram_addr_b,
        doutb           => in_bram_rddata_b
    );

    out_block_ram : out_bram
    port map (
        clka            => clk,
        ena             => out_bram_en_a,
        wea             => out_bram_we_a,
        addra           => out_bram_addr_a,
        dina            => out_bram_wrdata_a,
        clkb            => clk,
        enb             => out_bram_en_b,
        addrb           => out_bram_addr_b(15 downto 2),
        doutb           => out_bram_rddata_b
    );
  
    weights_block_ram : weights_bram
    port map (
        clka            => clk,
        ena             => w_bram_en_a,
        wea(0)          => w_bram_we_a(0),
        addra           => w_bram_addr_a(15 downto 2),
        dina            => w_bram_wrdata_a,
        clkb            => clk,
        enb             => w_bram_en_b,
        addrb           => w_bram_addr_b,
        doutb           => w_bram_rddata_b
    );
  
    in_bram_axictrl : in_bram_controller
    port map (
        s_axi_aclk      => clk,
        s_axi_aresetn   => rstn,
        s_axi_awaddr    => s01_axi_awaddr,
        s_axi_awprot    => s01_axi_awprot,
        s_axi_awvalid   => s01_axi_awvalid,
        s_axi_awready   => s01_axi_awready,
        s_axi_wdata     => s01_axi_wdata,
        s_axi_wstrb     => s01_axi_wstrb,
        s_axi_wvalid    => s01_axi_wvalid,
        s_axi_wready    => s01_axi_wready,
        s_axi_bresp     => s01_axi_bresp,
        s_axi_bvalid    => s01_axi_bvalid,
        s_axi_bready    => s01_axi_bready,
        s_axi_araddr    => s01_axi_araddr,
        s_axi_arprot    => s01_axi_arprot,
        s_axi_arvalid   => s01_axi_arvalid,
        s_axi_arready   => s01_axi_arready,
        s_axi_rdata     => s01_axi_rdata,
        s_axi_rresp     => s01_axi_rresp,
        s_axi_rvalid    => s01_axi_rvalid,
        s_axi_rready    => s01_axi_rready,
        bram_rst_a      => open,
        bram_clk_a      => open,
        bram_en_a       => in_bram_en_a,
        bram_we_a       => in_bram_we_a,
        bram_addr_a     => in_bram_addr_a,
        bram_wrdata_a   => in_bram_wrdata_a,
        bram_rddata_a   => (others => '0')
    );
  
    out_bram_axictrl : out_bram_controller
    port map (
        s_axi_aclk      => clk,
        s_axi_aresetn   => rstn,
        s_axi_awaddr    => s02_axi_awaddr,
        s_axi_awprot    => s02_axi_awprot,
        s_axi_awvalid   => s02_axi_awvalid,
        s_axi_awready   => s02_axi_awready,
        s_axi_wdata     => s02_axi_wdata,
        s_axi_wstrb     => s02_axi_wstrb,
        s_axi_wvalid    => s02_axi_wvalid,
        s_axi_wready    => s02_axi_wready,
        s_axi_bresp     => s02_axi_bresp,
        s_axi_bvalid    => s02_axi_bvalid,
        s_axi_bready    => s02_axi_bready,
        s_axi_araddr    => s02_axi_araddr,
        s_axi_arprot    => s02_axi_arprot,
        s_axi_arvalid   => s02_axi_arvalid,
        s_axi_arready   => s02_axi_arready,
        s_axi_rdata     => s02_axi_rdata,
        s_axi_rresp     => s02_axi_rresp,
        s_axi_rvalid    => s02_axi_rvalid,
        s_axi_rready    => s02_axi_rready,
        bram_rst_a      => open,
        bram_clk_a      => open,
        bram_en_a       => out_bram_en_b,
        bram_we_a       => open,
        bram_addr_a     => out_bram_addr_b,
        bram_wrdata_a   => open,
        bram_rddata_a   => out_bram_rddata_b
    );
  
    weights_bram_axictrl : weights_bram_controller
    port map (
        s_axi_aclk      => clk,
        s_axi_aresetn   => rstn,
        s_axi_awaddr    => s03_axi_awaddr,
        s_axi_awprot    => s03_axi_awprot,
        s_axi_awvalid   => s03_axi_awvalid,
        s_axi_awready   => s03_axi_awready,
        s_axi_wdata     => s03_axi_wdata,
        s_axi_wstrb     => s03_axi_wstrb,
        s_axi_wvalid    => s03_axi_wvalid,
        s_axi_wready    => s03_axi_wready,
        s_axi_bresp     => s03_axi_bresp,
        s_axi_bvalid    => s03_axi_bvalid,
        s_axi_bready    => s03_axi_bready,
        s_axi_araddr    => s03_axi_araddr,
        s_axi_arprot    => s03_axi_arprot,
        s_axi_arvalid   => s03_axi_arvalid,
        s_axi_arready   => s03_axi_arready,
        s_axi_rdata     => s03_axi_rdata,
        s_axi_rresp     => s03_axi_rresp,
        s_axi_rvalid    => s03_axi_rvalid,
        s_axi_rready    => s03_axi_rready,
        bram_rst_a      => open,
        bram_clk_a      => open,
        bram_en_a       => w_bram_en_a,
        bram_we_a       => w_bram_we_a,
        bram_addr_a     => w_bram_addr_a,
        bram_wrdata_a   => w_bram_wrdata_a,
        bram_rddata_a   => (others => '0')
    );

end arch;
