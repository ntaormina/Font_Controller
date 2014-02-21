----------------------------------------------------------------------------------
--C2C Nik Taormina
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;
entity character_gen is
    port ( clk            : in std_logic;
           blank          : in std_logic;
           row            : in std_logic_vector(10 downto 0);
           column         : in std_logic_vector(10 downto 0);
           ascii_to_write : in std_logic_vector(7 downto 0);
           write_en       : in std_logic;
           r,g,b          : out std_logic_vector(7 downto 0)
         );
end character_gen;

architecture Behavioral of character_gen is

begin


end Behavioral;

