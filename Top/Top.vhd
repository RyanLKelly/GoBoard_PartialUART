library IEEE;
use IEEE.std_logic_1164.all;

entity Top is
	port (
		i_Clk : in std_logic; -- Main system clock
		i_UART_RX : in std_logic; -- Serial port (COM4) receive signal
		i_Switch_1 : in std_logic; -- Use as 'reset' input
		o_Segment1_A : out std_logic; -- Left-hand seven segment display segments
		o_Segment1_B : out std_logic;
		o_Segment1_C : out std_logic;
		o_Segment1_D : out std_logic;
		o_Segment1_E : out std_logic;
		o_Segment1_F : out std_logic;
		o_Segment1_G : out std_logic;
		o_Segment2_A : out std_logic; -- Right-hand seven segment display segments
		o_Segment2_B : out std_logic;
		o_Segment2_C : out std_logic;
		o_Segment2_D : out std_logic;
		o_Segment2_E : out std_logic;
		o_Segment2_F : out std_logic;
		o_Segment2_G : out std_logic;
		o_UART_TX : out std_logic -- Serial port (COM4) transmit signal
	);
end entity Top;

architecture Behavior of Top is
    signal w_Debounced : std_logic;
	signal w_Word : std_logic_vector (7 downto 0);
begin
	DebouncerInst : entity work.Debouncer port map (
		i_Clock => i_Clk,
		i_Switch => i_Switch_1,
		o_Debounced => w_Debounced
	);
	UARTInst : entity work.UART 
	generic map (
		g_QtrTime => 54 -- 2 for testing, 54 for GoBoard implementation
	)
	port map (
    	i_Clock => i_Clk,
        i_UARTReceive => i_UART_RX,
        i_Reset => w_Debounced,
		o_UARTTransmit => o_UART_TX,
		o_Word => w_Word
     );
    Left7SDInstance : entity work.SevenSegmentDriver port map (
    	i_Clock => i_Clk,
        i_Value => w_Word (7 downto 4),
        o_Seg_A => o_Segment1_A,
        o_Seg_B => o_Segment1_B,
        o_Seg_C => o_Segment1_C,
        o_Seg_D => o_Segment1_D,
        o_Seg_E => o_Segment1_E,
        o_Seg_F => o_Segment1_F,
        o_Seg_G => o_Segment1_G
	);
    Right7SDInstance : entity work.SevenSegmentDriver port map (
     	i_Clock => i_Clk,
        i_value => w_Word (3 downto 0),
        o_Seg_A => o_Segment2_A,
        o_Seg_B => o_Segment2_B,
        o_Seg_C => o_Segment2_C,
        o_Seg_D => o_Segment2_D,
        o_Seg_E => o_Segment2_E,
        o_Seg_F => o_Segment2_F,
        o_Seg_G => o_Segment2_G
    );        
end architecture Behavior;