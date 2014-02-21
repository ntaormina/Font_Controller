----------------------------------------------------------------------------------
--C2C Nik Taormina
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity char_screen_buffer is -- Dual-port RAM template from synthesis guide (minor mods)
    port ( clk        : in std_logic;
           we         : in std_logic;                     -- write enable
           address_a  : in std_logic_vector(11 downto 0); -- write address, primary port
           address_b  : in std_logic_vector(11 downto 0); -- dual read address
           data_in    : in std_logic_vector(7 downto 0);  -- data input
           data_out_a : out std_logic_vector(7 downto 0); -- primary data output
           data_out_b : out std_logic_vector(7 downto 0)  -- dual output port
         );
end char_screen_buffer;



architecture behavioral of char_screen_buffer is
    signal address_a_reg : std_logic_vector(11 downto 0);
    signal address_b_reg : std_logic_vector(11 downto 0);

    type ram_type is array (4096-1 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type :=
    (
        (others => x"41")
    );
    -- x"00", x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A", x"0B", x"0C", x"0D", x"0E", x"0F"
begin

    process (clk) is
    begin
        if rising_edge(clk) then
            if (we = '1') then
                RAM(to_integer(unsigned(address_a))) <= data_in;
            end if;

            address_a_reg <= address_a;
            address_b_reg <= address_b;
        end if;
    end process;

    data_out_a <= RAM(to_integer(unsigned(address_a_reg)));
    data_out_b <= RAM(to_integer(unsigned(address_b_reg)));




end Behavioral;

