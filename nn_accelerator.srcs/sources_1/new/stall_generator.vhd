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

        i_slotIdValid   : in std_logic_vector(SLOT_ID_BITS-1 downto 0);
        i_slotValidEn   : in std_logic;
        
        i_slotIdInvalid : in std_logic_vector(SLOT_ID_BITS-1 downto 0);
        i_slotInvalidEn : in std_logic
    );
end stall_generator;

architecture arch of stall_generator is

    signal r_slots          : std_logic_vector((2**SLOT_ID_BITS)-1 downto 0) 
                                := (others => '0');

    signal s_slotIdx        : integer range 0 to (2**SLOT_ID_BITS)-1;
    signal s_slotIdxValid   : integer range 0 to (2**SLOT_ID_BITS)-1;
    signal s_slotIdxInvalid : integer range 0 to (2**SLOT_ID_BITS)-1;

begin

    s_slotIdx <= to_integer(unsigned(i_slotId));
    s_slotIdxValid <= to_integer(unsigned(i_slotIdValid));
    s_slotIdxInvalid <= to_integer(unsigned(i_slotIdInvalid));

    process (clk)
    begin
        if rising_edge(clk) then
            if i_slotValidEn = '1' then
                r_slots(s_slotIdxValid) <= '1';
            end if;
            if i_slotInvalidEn = '1' then
                r_slots(s_slotIdxInvalid) <= '0';
            end if;
        end if;
    end process;

    o_stall <= '1' when i_slotIdEn = '1' 
                        and r_slots(s_slotIdx) = '0' 
               else '0';

end arch;
