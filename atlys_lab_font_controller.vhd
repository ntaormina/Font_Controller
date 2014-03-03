----------------------------------------------------------------------------------
--C2C Nik Taormina
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity atlys_lab_font_controller is
    port ( 
             clk    : in  std_logic; -- 100 MHz
             reset  : in  std_logic;
             start  : in  std_logic;
             switch : in  std_logic_vector(7 downto 0);
             led    : out std_logic_vector(7 downto 0);
             tmds   : out std_logic_vector(3 downto 0);
             tmdsb  : out std_logic_vector(3 downto 0)
         );
end atlys_lab_font_controller;

architecture Behavioral of atlys_lab_font_controller is

COMPONENT character_gen
	PORT(
		clk : IN std_logic;
		blank : IN std_logic;
		reset : IN std_logic;
		row : IN std_logic_vector(10 downto 0);
		column : IN std_logic_vector(10 downto 0);
		ascii_to_write : IN std_logic_vector(7 downto 0);
		write_en : IN std_logic;          
		r : OUT std_logic_vector(7 downto 0);
		g : OUT std_logic_vector(7 downto 0);
		b : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	

	
	COMPONENT vga_sync
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		h_sync : OUT std_logic;
		v_sync : OUT std_logic;
		v_completed : OUT std_logic;
		blank : OUT std_logic;
		row : OUT unsigned(10 downto 0);
		column : OUT unsigned(10 downto 0)
		);
	END COMPONENT;
	
	COMPONENT input_to_pulse
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		input : IN std_logic;          
		pulse : OUT std_logic
		);
	END COMPONENT;

	
		signal row_connector, column_connector : unsigned(10 downto 0);
	
	signal red_sig, green_sig, blue_sig : std_logic_vector(7 downto 0);
	signal enable_connector, pixel_clk, serialize_clk, serialize_clk_n, h_sync_sig, v_sync_sig, v_completed, blank_sig, red_s, green_s, blue_s, clock_s:std_logic;

begin

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
            );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

    -- TODO: VGA component instantiation
	 

	Inst_character_gen: character_gen PORT MAP(
		clk => pixel_clk,
		blank => blank_sig,
		reset => reset,
		row => std_logic_vector(row_connector),
		column => std_logic_vector(column_connector),
		ascii_to_write => switch,
		write_en => enable_connector,
		r => red_sig,
		g => green_sig,
		b => blue_sig
	);
	
	
	Inst_vga_sync: vga_sync PORT MAP(
		clk => pixel_clk,
		reset => reset,
		h_sync => h_sync_sig,
		v_sync => v_sync_sig,
		v_completed => open,
		blank => blank_sig,
		row => row_connector,
		column => column_connector
	);
	
	Inst_input_to_pulse: input_to_pulse PORT MAP(
		clk => pixel_clk,
		reset => reset,
		input => start,
		pulse => enable_connector
	); 


    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red_sig,
                green_p   => green_sig,
                blue_p    => blue_sig,
                blank     => blank_sig,
                hsync     => h_sync_sig,
                vsync     => v_sync_sig,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );


	

end Behavioral;

