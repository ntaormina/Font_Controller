Font_Controller
===============
Introduction
============
The purpose of this lab was to use the VGA driver created in lab one to make a font ontroller tat used an asii database to display araters to a sreen. Tis was done wit onatination and multiplexing.

Implementation
==============




`atlys_lab_font_ontroller.vhd`
-This is the main top level implementation where `vga_sync.vhd`, `dvid.vhd`, `input_to_pulse` and `arater_gen.vhd`  are instantiated. They are all interconnected with signals created here. The component looks like this:

```vhdl
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

Inst_character_gen: character_gen PORT MAP(
		clk => pixel_clk,
		blank => blank_sig_2,
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

```

`vga_sync.vhd`
-This is where v_sync and h_sync are connected to each other. Their main connection is the completed signal. The output blank is high when either vertical or horizontal are blank and v_completed is 1 when v_sync is completed.

```vhdl
entity vga_sync is
    port ( clk         : in  std_logic;
           reset       : in  std_logic;
           h_sync      : out std_logic;
           v_sync      : out std_logic;
           v_completed : out std_logic;
           blank       : out std_logic;
           row         : out unsigned(10 downto 0);
           column      : out unsigned(10 downto 0)
     );
end vga_sync;
```

`h_sync_gen.vhd`
-This generates the horizontal row of synchronization signals. It switches between 5 states: active_video, front_porch, sync_pulse, back_porch, completed. It sets blank low when in active video, h_sync low when in the sync_pulse, and completed high when in completed_state. It contains three flip-flops that govern next state logic, next count logic, and count reseting.

```vhdl
entity h_sync_gen is
    port ( clk       : in  std_logic;
           reset     : in  std_logic;
           h_sync    : out std_logic;
           blank     : out std_logic;
           completed : out std_logic;
           column    : out unsigned(10 downto 0)
     );
end h_sync_gen;
```

`v_sync_gen.vhd`
-This generates the vertical row of synchronization signals. It switches between 5 states: active_video, front_porch, sync_pulse, back_porch, completed. It sets blank low when in active video, h_sync low when in the sync_pulse, and completed high when in completed_state. It contains three flip-flops that govern next state logic, next count logic, and count reseting. It is very similar to h_sync but only operates while h_completed it high. h_sync and v_sync alternate.

```vhdl
entity v_sync_gen is
    port ( clk         : in  std_logic;
           reset       : in std_logic;
			  h_blank     : in std_logic;
           h_completed : in std_logic;
           v_sync      : out std_logic;
           blank       : out std_logic;
           completed   : out std_logic;
           row         : out unsigned(10 downto 0)
     );
end v_sync_gen;
```

`arater_gen.vhd`
-This signal sets values to r, g and b to display certain colors on the display. The higher the number the brighter the color. This is where the font_rom and sreen_buffer work togeter to determine wi pixels are filled in. Te onnetions are below.

```vhdl
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

```



`Input_to_pulse.vhd`
This handles the debouncing of the buttons with a button state machine that has three states: waiting, press, and depress. It waits in press for 55000 clock cycles before heading to depress. 

```vhdl
entity Input_to_pulse is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           button_in : in  STD_LOGIC;
           button_out : out  STD_LOGIC);
end Input_to_pulse;
```

`Font_rom.d`
Tis is a table of wat olumn and row are ig for ea arater.

```vhdl
entity font_rom is
   port(
      clk: in std_logic;
      addr: in std_logic_vector(10 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end font_rom;
```

Test/Debug
==========
-Te metodology I took in making tis lab was by implementing eeryting one step at a time as best as I understood it.

-Te first time I tested te lab by ooking it up to te dmi it worked

-I ten added in te button and swit logi and it worked but te text was leaing artifats eery time you anged from one arater to anoter. To fix tis I added delays in te top leel to _syn, _syn, and blank and in arater gen to olumn and row.

-Te ontroller ten worked perfetly and was syned orretly



Conclusion
==========
From this lab I definitely took away that FPGAs are extremely ersatile and an do a multitude of funtions. It was ool to see ow a basi font ontroller worked. Next time I will make more simulations and test benes.



Documentation
=============
Capt Branflower, C2C Michael Bentley, and C2C John Miller gave me advice 
on ways they solved the problems they encountered, mainly how to concatinate for address b.  John showed me that you could use a elper function to do te conatination for adress b. Captain Branflower suggested I add in delays to fix te problem of leaing artifats in my text editor. Miael sowed me ow to implement te delays for _syn, 
All of this advice lead to my completion of the lab and all credit is given to those who had the ideas and contributed them to me.
