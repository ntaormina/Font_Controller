----------------------------------------------------------------------------------
--C2C Nik Taormina
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity font_rom is
    port(
           clk: in std_logic;
           addr: in std_logic_vector(10 downto 0);
           data: out std_logic_vector(7 downto 0)
         );
end font_rom;

architecture Behavioral of font_rom is

begin


end Behavioral;

