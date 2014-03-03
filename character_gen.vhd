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
			  reset          : in std_logic;
           row            : in std_logic_vector(10 downto 0);
           column         : in std_logic_vector(10 downto 0);
           ascii_to_write : in std_logic_vector(7 downto 0);
           write_en       : in std_logic;
           r,g,b          : out std_logic_vector(7 downto 0)
         );
end character_gen;

architecture Behavioral of character_gen is

COMPONENT font_rom
	PORT(
		clk : IN std_logic;
		addr : IN std_logic_vector(10 downto 0);          
		data : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT char_screen_buffer
	PORT(
		clk : IN std_logic;
		we : IN std_logic;
		address_a : IN std_logic_vector(11 downto 0);
		address_b : IN std_logic_vector(11 downto 0);
		data_in : IN std_logic_vector(7 downto 0);          
		data_out_a : OUT std_logic_vector(7 downto 0);
		data_out_b : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

signal sel : std_logic_vector(2 downto 0);
signal row_sig : std_logic_vector(3 downto 0);
signal font_connector : std_logic_vector(10 downto 0);
signal output : std_logic;
signal data_from_font, b_data_signal : std_logic_vector(7 downto 0);
signal address_b_12_bit, counter, counter_helper : std_logic_vector(11 downto 0);
signal address_b_signal : std_logic_vector(13 downto 0);

begin

sel <= column(2 downto 0);

process(column, sel, clk)
begin

	case sel is
		when"000"=>
			output <= data_from_font(7);

		when"001"=>
			output <= data_from_font(6);

		when"010"=>
			output <= data_from_font(5);
			
		when"011"=>
			output <= data_from_font(4);
			
		when"100"=>
			output <= data_from_font(3);
			
		when"101"=>
			output <= data_from_font(2);
			
		when"110"=>
			output <= data_from_font(1);
			
		when"111"=>
			output <= data_from_font(0);
			
		when others=>
			
	end case;
end process;

r <= (others=>'1') when output = '1' else
		(others=>'0');
		
g<= (others=>'0');		
b<= (others=>'0');

font_connector <= b_data_signal(6 downto 0) & row_sig;
row_sig <= row(3 downto 0);

	Inst_font_rom: font_rom PORT MAP(
		clk => clk,
		addr => font_connector,
		data => data_from_font
	);
	
	Inst_char_screen_buffer: char_screen_buffer PORT MAP(
		clk => clk,
		we => write_en,
		address_a => counter,
		address_b => address_b_12_bit,
		data_in => ascii_to_write,
		data_out_a => open,
		data_out_b => b_data_signal
	);

address_b_signal <= std_logic_vector(((unsigned(column(10 downto 3))) + unsigned(row(10 downto 4)) * 80));
address_b_12_bit <= address_b_signal(11 downto 0);

counter_helper <= (others => '0') when reset = '1' else
						counter;

counter <= std_logic_vector(unsigned(counter_helper) + 1) when rising_edge(write_en) else
			  counter_helper;				


end Behavioral;

