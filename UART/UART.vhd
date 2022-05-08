library IEEE;
use IEEE.std_logic_1164.all;

entity UART is
	generic (
		g_QtrTime : in integer range 0 to 54 := 54
	);
	port (
		i_Clock : in std_logic; -- Main system clock
		i_UARTReceive : in std_logic;
		i_Reset : in std_logic; -- Use as 'reset' input
		o_UARTTransmit : out std_logic;
		o_Word : out std_logic_vector (7 downto 0) -- TODO: Remove this later, and instead drive the 7SDs from the UART transmitter (when I complete it)
	);
end entity UART;

architecture Behavior of UART is
	signal w_NewRxWordReady : std_logic;
	signal w_Word : std_logic_vector (7 downto 0);
	signal w_Bit : std_logic;
begin
	o_UARTTransmit <= w_Bit;
	o_Word <= w_Word;
	
	UARTRxInst : entity work.Receiver 
	generic map (
		g_QtrTime => g_QtrTime
	)
	port map (
    	i_Clock => i_Clock,
        i_Bit => i_UARTReceive,
        i_Reset => i_Reset,
        o_Word => w_Word,
		o_NewRxWordReady => w_NewRxWordReady
    );
	
	UARTTxInst : entity work.Transmitter
	generic map (
		g_QtrTime => g_QtrTime
	)
	port map (
		i_Clock => i_Clock,
		i_Reset => i_Reset,
		i_Word => w_Word,
		i_NewRxWordReady => w_NewRxWordReady,
		o_Bit => o_UARTTransmit
	);
end architecture Behavior;