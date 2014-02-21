--------------------------------------
--C2C Nik Taormina
--This module debounces buttons by delaying in the press state
--------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity input_to_pulse is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC;
           pulse : out  STD_LOGIC);
end input_to_pulse;

architecture Behavioral of input_to_pulse is

type button_type is (waiting, press, depress);
signal button_reg, button_next : button_type;
signal button, button_next_sig : std_logic;
signal count, count_next: unsigned(19 downto 0);

begin

--count flip flop and logic


--button flip flop
process(clk, reset)
begin

	if(reset = '1') then
		button_reg <= waiting;
	elsif(rising_edge(clk)) then
		button_reg <= button_next;
	end if;
	
end process;	

--button state machine and delay
process(count, button_reg, input)
begin

button_next <= button_reg;

case button_reg is
	when waiting =>
		if(input = '1') then
			button_next <= press;
		end if;	
	when press =>
		if( input = '0') then 
			button_next <= depress;
		end if;	
	when depress =>
		button_next <= waiting;
end case;

end process;	

process(button_reg)
begin

--sets signal to one when button is released
case button_reg is
	when waiting =>
		button_next_sig <= '0';
	when press =>
		button_next_sig <= '0';
	when depress =>
		button_next_sig <= '1';
end case;

end process;	


--output logic
pulse <= button_next_sig;



--If a count needs to be implemented the logic is below
process(clk, reset, button_next, count)
begin

	if(reset = '1') then
		count <= to_unsigned(0, 20);
	elsif(rising_edge(clk)) then
		count <= count_next;
	end if;
	
	if(button_next = press) then
		count_next <= count + 1;
	else
		count_next <= to_unsigned(0,20);
	end if;	

end process;
	


end Behavioral;