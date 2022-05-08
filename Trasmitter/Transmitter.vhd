library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Transmitter is
	generic (
		g_QtrTime : integer range 0 to 54 := 54
	);
	port (
		i_Clock: in std_logic; -- system clock, assumed 25 MHz
		i_Reset: in std_logic; -- reset signal (0 is active)
		i_Word: in std_logic_vector (7 downto 0); -- input byte (Leftmost bit 7 is MSB)
		i_NewRxWordReady : in std_logic;  -- one-pulse signal indicating a new word to transmit it ready
		o_Bit: out std_logic -- GPIO pin value, receiving other UART's signal
	);
end entity Transmitter;

architecture Behavior of Transmitter is
	signal r_OutputBit : std_logic;
	signal r_TickCount : integer range 0 to 217;
	signal r_TxWord : std_logic_vector (7 downto 0);
	type StateType is (sInit, s0, s1, s2, s3, s4);
	signal r_State : StateType := sInit;
	signal r_TxCount : integer range 0 to 8;
    --signal DebugState : integer range 0 to 6 := 0;

begin
	o_Bit <= r_OutputBit; -- set to 1 for idle time between words
	process (i_Clock, i_Reset) is
	begin
		if (i_Reset = '1') then
			r_TickCount <= 1;
			r_TxWord <= "00000000";
			r_OutputBit <= '1'; -- set to 1 for idle time
			r_State <= s0;
            --DebugState <= 1;
            r_TxCount <= 0;
		elsif rising_edge(i_Clock) then
			case r_State is
				when sInit => -- initial state at system power-on
					r_OutputBit <= '1';
					r_TickCount <= 1;
					r_TxWord <= "00000000";
					r_State <= s0;
                    --DebugState <= 1;
					r_TxCount <= 0;
				when s0 => -- initial "transmitter ready" state
					r_TickCount <= 1;
					r_TxWord <= "00000000";
					r_State <= s0;
                    --DebugState <= 1;
					r_TxCount <= 0;
					r_OutputBit <= '1';
					if (i_NewRxWordReady = '1') then -- wait for the receiver to signal it finished receiving a new word
						r_TxWord <= i_Word;
						r_OutputBit <= '0';
						r_State <= s1;
                        --DebugState <= 2;
					end if;
				when s1 => -- delay one bit time
                    r_TickCount <= r_TickCount + 1;
					if (r_TickCount = (g_QtrTime + g_QtrTime + g_QtrTime + g_QtrTime)-1) then
						r_State <= s2;
                        --DebugState <= 3;
					else
						r_State <= s1;
                        --DebugState <= 2;
					end if;	
				when s2 => -- initiate each of the data bits, or the stop bit
					if (r_TxCount < 8) then -- initiate next data bit value
						r_OutputBit <= r_TxWord(r_TxCount);
                        r_TickCount <= 1;
						r_TxCount <= r_TxCount + 1;
                        r_State <= s3; -- and enter "one bit-time hold/delay" state
						--DebugState <= 4;
					else -- initiate a stop bit
                        r_OutputBit <= '1';
						r_TickCount <= 1;
                        r_TxCount <= 0;
						r_State <= s4; -- "stop bit" hold state
                        --DebugState <= 5;
					end if;	
				when s3 => -- complete a 1-bit-time delay, for each initiated data bit
					if (r_TickCount = (g_QtrTime + g_QtrTime + g_QtrTime + g_QtrTime)-1) then -- wait 1 bit time
						r_TickCount <= r_TickCount + 1;
						r_State <= s2;
                        --DebugState <= 3;
					else
						r_TickCount <= r_TickCount + 1;
						r_State <= s3;
                        --DebugState <= 4;
					end if;
				when s4 => -- complete a 1-bit-time delay for the stop bit
					if (r_TickCount = (g_QtrTime + g_QtrTime + g_QtrTime + g_QtrTime)) then
						r_State <= s0;
                        --DebugState <= 1;
                        r_TickCount <= 1;
					else
						r_State <= s4;
                        --DebugState <= 5;
						r_TickCount <= r_TickCount + 1;
					end if;
				when others => -- should never have to be reached
					r_State <= s0;
                    --DebugState <= 1;
			end case;
		end if;
	end process;
end architecture Behavior;
	
