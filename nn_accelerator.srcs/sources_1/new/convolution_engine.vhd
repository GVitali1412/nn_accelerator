library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity convolution_engine is
    generic (
        DATA_WIDTH      : positive := 8;
        NUMBER_CU       : positive := 64
    );
    port ( 
        clk             : in std_logic;
        i_start         : in std_logic;
        
        -- in bram
        in_bram_en      : out std_logic;
        in_bram_addr    : out std_logic_vector(17 downto 0);
        in_bram_rddata  : in std_logic_vector(7 downto 0);

        -- out bram
        out_bram_en     : out std_logic;
        out_bram_we     : out std_logic;
        out_bram_addr   : out std_logic_vector(8 downto 0);
        out_bram_wrdata : out std_logic_vector(1023 downto 0);

        -- weights bram
        w_bram_en       : out std_logic;
        w_bram_addr     : out std_logic_vector(8 downto 0);
        w_bram_rddata   : in std_logic_vector(1023 downto 0)
    );
end convolution_engine;

architecture arch of convolution_engine is

    signal s_clearAccum    : std_logic; 

begin

    convolution_controller : entity work.controller
    port map (
        clk             => clk,
        i_start         => i_start,
        o_clearAccum    => s_clearAccum,
        o_inBramEn      => in_bram_en,
        o_inBramAddr    => in_bram_addr,
        o_outBramEn     => out_bram_en,
        o_outBramWe     => out_bram_we,
        o_outBramAddr   => out_bram_addr,
        o_wgsBramEn     => w_bram_en,
        o_wgsBramAddr   => w_bram_addr
    );


    convolution_units : for i in 0 to NUMBER_CU-1 generate
        cu : entity work.compute_unit
        port map (
            clk             => clk,
            i_clearAccum    => s_clearAccum,
            i_enActivation  => '1',
            i_value         => signed(in_bram_rddata),
            i_weight        => signed(w_bram_rddata(DATA_WIDTH*(i+1)-1 
                                                    downto DATA_WIDTH*i)),
            std_logic_vector(o_result) => 
                out_bram_wrdata(DATA_WIDTH*(i+1)-1 downto DATA_WIDTH*i)
        );
    end generate;

    extra_output : if NUMBER_CU*DATA_WIDTH < 1024 generate
        out_bram_wrdata(1023 downto NUMBER_CU*DATA_WIDTH) <= (others => '0');
    end generate;

end arch;
