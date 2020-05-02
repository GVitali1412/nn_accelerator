library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity axi4lite_controls is
    generic ( AXI_ADDR_WIDTH : positive := 4 );
    port (
        clk             : in std_logic;
        rstn            : in std_logic;
        -- Registers
        i_rstReg        : in std_logic;
        o_reg0          : out std_logic_vector(31 downto 0);
        o_reg1          : out std_logic_vector(31 downto 0);
        o_reg2          : out std_logic_vector(31 downto 0);
        o_reg3          : out std_logic_vector(31 downto 0);
        -- Write address
        axi_awaddr      : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        -- Write address valid
        axi_awvalid     : in std_logic;
        -- Write address ready
        axi_awready     : out std_logic;
        -- Write data
        axi_wdata       : in std_logic_vector(31 downto 0);
        -- Write strobes
        axi_wstrb       : in std_logic_vector(3 downto 0);
        -- Write valid
        axi_wvalid      : in std_logic;
        -- Write read
        axi_wready      : out std_logic;
        -- Write response
        axi_bresp       : out std_logic_vector(1 downto 0);
        -- Write response valid
        axi_bvalid      : out std_logic;
        -- Write response ready
        axi_bready      : in std_logic;
        -- Read address
        axi_araddr      : in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        -- Read address valid
        axi_arvalid     : in std_logic;
        -- Read address ready
        axi_arready     : out std_logic;
        -- Read data
        axi_rdata       : out std_logic_vector(31 downto 0);
        -- Read response
        axi_rresp       : out std_logic_vector(1 downto 0);
        -- Read valid
        axi_rvalid      : out std_logic;
        -- Read ready
        axi_rready      : in std_logic
    );
end axi4lite_controls;

architecture arch of axi4lite_controls is

    signal reg0             : std_logic_vector(31 downto 0);
    signal reg1             : std_logic_vector(31 downto 0);
    signal reg2             : std_logic_vector(31 downto 0);
    signal reg3             : std_logic_vector(31 downto 0);

    signal s_awready        : std_logic;
    signal s_wready         : std_logic;
    signal s_bvalid	        : std_logic;

    signal s_awaddr         : std_logic_vector(3 downto 0);

    signal s_awen           : std_logic;
    signal s_regWrEn        : std_logic;


begin

    o_reg0 <= reg0;
    o_reg1 <= reg1;
    o_reg2 <= reg2;
    o_reg3 <= reg3;

    axi_awready <= s_awready;
    axi_wready <= s_wready;
    axi_bvalid <= s_bvalid;

    process (clk)
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                s_awen <= '1';
                s_awready <= '0';
                s_wready <= '0';

            else
                if axi_awvalid = '1' and axi_wvalid = '1' 
                    and s_awen = '1' and s_awready = '0' and s_wready = '0'
                then
                    s_awen <= '0';
                    s_awready <= '1';
                    s_wready <= '1';
                    s_awaddr <= axi_awaddr;

                elsif axi_bready = '1' and s_bvalid = '1' then
                    s_awen <= '1';
                    s_awready <= '0';
                    s_wready <= '0';

                else
                    s_awready <= '0';
                    s_wready <= '0';

                end if;
            end if;
        end if;
    end process;

    s_regWrEn <= s_wready and axi_wvalid and s_awready and axi_awvalid;

    process (clk)
        variable locAddr    : std_logic_vector(AXI_ADDR_WIDTH-3 downto 0);
    begin
        if rising_edge(clk) then
            if rstn = '0' or i_rstReg = '1' then
                reg0 <= (others => '0');
                reg1 <= (others => '0');
                reg2 <= (others => '0');
                reg3 <= (others => '0');
            else
                locAddr := s_awaddr(AXI_ADDR_WIDTH-1 downto 2);
                if (s_regWrEn = '1') then
                    case locAddr is
                        when "00" =>
                            for byte in 0 to 3 loop
                                if axi_wstrb(byte) = '1' then
                                    reg0(byte*8+7 downto byte*8) <=
                                        axi_wdata(byte*8+7 downto byte*8);
                                end if;
                            end loop;

                        when "01" =>
                            for byte in 0 to 3 loop
                                if axi_wstrb(byte) = '1' then
                                    reg1(byte*8+7 downto byte*8) <=
                                        axi_wdata(byte*8+7 downto byte*8);
                                end if;
                            end loop;

                        when "10" =>
                            for byte in 0 to 3 loop
                                if axi_wstrb(byte) = '1' then
                                    reg2(byte*8+7 downto byte*8) <=
                                        axi_wdata(byte*8+7 downto byte*8);
                                end if;
                            end loop;
                        
                        when "11" =>
                            for byte in 0 to 3 loop
                                if axi_wstrb(byte) = '1' then
                                    reg3(byte*8+7 downto byte*8) <=
                                        axi_wdata(byte*8+7 downto byte*8);
                                end if;
                            end loop;
                        when others =>
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- Write response channel

    axi_bresp <= "00";

    process (clk)
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                s_bvalid <= '0';
            else
                if axi_awvalid = '1' and axi_wvalid = '1'
                    and s_bvalid = '0' and s_awready = '1' and s_wready = '1'
                then
                    s_bvalid <= '1';
                
                elsif axi_bready = '1' and s_bvalid = '1' then
                    s_bvalid <= '0';

                end if;
            end if;
        end if;
    end process;


    -- For now read transactions are not implemented
    axi_arready <= '0';
    axi_rdata <= (others => '0');
    axi_rresp <= "00";
    axi_rvalid <= '0';

end arch;
