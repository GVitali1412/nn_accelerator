
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;


entity start_module is
    port (
        clk             : in std_logic;
        rstn            : in std_logic;
        start           : out std_logic
    );
end start_module;

architecture arch of start_module is

begin

    process(clk)
        variable starting       : std_logic := '0';
        variable counter        : integer range 0 to 1000 := 0;
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                starting := '1';
            end if;
            if starting = '1' and counter < 1000 then
                counter := counter + 1;
            end if;
        end if;
        
        if counter = 999 then
            start <= '1';
        else 
            start <= '0';
        end if;
    end process;

end arch;
