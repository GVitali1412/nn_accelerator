library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--library UNISIM;
--use UNISIM.VComponents.all;

entity stall_generator is
    generic (
        SLOT_ID_BITS    : natural
    );
    port (
        clk             : in std_logic;
        o_stall         : out std_logic;

        i_slotId        : in std_logic_vector(SLOT_ID_BITS-1 downto 0);
        i_slotIdEn      : in std_logic;

        i_slotIdUpdate  : in std_logic_vector(SLOT_ID_BITS-1 downto 0);
        i_slotIdUpEn    : in std_logic;
        i_slotValid     : in std_logic
    );
end stall_generator;

architecture arch of stall_generator is

    signal r_slots          : std_logic_vector((2**SLOT_ID_BITS)-1 downto 0) 
                                := (others => '0');

    signal s_slotIdx        : integer range 0 to (2**SLOT_ID_BITS)-1;
    signal s_slotIdxUpdate  : integer range 0 to (2**SLOT_ID_BITS)-1;

begin

    s_slotIdx <= to_integer(unsigned(i_slotId));
    s_slotIdxUpdate <= to_integer(unsigned(i_slotIdUpdate));

    process (clk)
    begin
        if rising_edge(clk) then
            if i_slotIdUpEn = '1' then
                r_slots(s_slotIdxUpdate) <= i_slotValid;
            end if;
        end if;
    end process;

    o_stall <= '1' when i_slotIdEn = '1' 
                        and r_slots(s_slotIdx) = '0' 
               else '0';

end arch;
