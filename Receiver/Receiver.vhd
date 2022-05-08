-- Last updated 2021 05 12

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Receiver is
	generic (
		g_QtrTime : in integer range 0 to 54 := 54 -- 1/4 bit time; use 2 for testbench, 54 for the HW implementation
	);
	port (
		i_Clock: in std_logic; -- system clock, assumed 25 MHz
		i_Bit: in std_logic; -- GPIO pin value, receiving other UART's signal
		i_Reset: in std_logic; -- reset signal (0 is active)
        o_Word: out std_logic_vector (7 downto 0); -- output byte; leftmost bit 7 is MSB
		o_NewRxWordReady : out std_logic  -- 1-clock high pulse used to signal that a new receieved word is ready
	);
end entity Receiver;

architecture Behavior of Receiver is
	signal r_Word : std_logic_vector (7 downto 0); -- holds most recent valid received word, linked to output
	type StateType is (sInit, sIdle, sQtrDelay, sHalfDelay, sReceive, sValidate);
	signal r_State : StateType; -- register holding the machine's current state
    --signal r_DebugState : integer range 0 to 5;
	signal r_TickCount : integer range 0 to 217; -- increments clock ticks up to 1 bit time (at 115200 bps)
												-- 25e6 ticks/sec * (1/115200) sec/bit = ~217 cyc/bit
	signal r_RxCount : integer range 0 to 8; -- count the number of bits received of a given word
	signal r_TempWord : std_logic_vector (7 downto 0);  -- records 8 bit word, received serially bit by bit
	signal r_NewRxWordReady : std_logic;  -- provides data to Receiver's respective output pin
		
begin
	o_Word <= r_Word;
	o_NewRxWordReady <= r_NewRxWordReady;
	process (i_Clock, i_Reset) is
	begin
		if (i_Reset = '1') then  -- IF reset signal asserted, reset registers and set state machine to idle state
			r_TickCount <= 1;
			r_RxCount <= 0;
			r_Word <= "00000000";
			r_State <= sIdle;
            --r_DebugState <= 1;
			r_NewRxWordReady <= '0';			
		elsif rising_edge(i_Clock) then
			case r_State is
				when sInit => -- initialize on boot (state 0), pass through only per power-on, reset registers
					r_TickCount <= 1;
					r_RxCount <= 0;
					r_TempWord <= "00000000";
					r_State <= sIdle;
                    --r_DebugState <= 1;
					r_NewRxWordReady <= '0';
				when sIdle =>  -- idle, receiver is ready (state 1)
                	r_TickCount <= 1;
                    r_RxCount <= 0;
					r_TempWord <= "00000000";
					r_NewRxWordReady <= '0';
					if (i_Bit = '0') then  -- indicates possible start bit transition
						r_State <= sQtrDelay;  -- next step is to wait 1/4 bit time
                        --r_DebugState <= 2;
					else
						r_State <= sIdle; 
                        --r_DebugState <= 1;
					end if;	
				when sQtrDelay => -- delay through 1/4 bit time (state 2)
					if (r_TickCount = g_QtrTime) then  -- aligned to first quarter-bit-time
						if (i_Bit = '0') then  -- sample current input value, if a zero
                        	r_State <= sHalfDelay;  -- valid start bit, continue with next sample delay
                            --r_DebugState <= 3;
                            r_TickCount <= r_TickCount + 1;
                        else  -- invalid start bit
                        	r_State <= sIdle;  -- reset state machine to idle state
                        	--r_DebugState <= 1;
                            r_TickCount <= 1;
                        end if;
					else  -- not yet at quarter bit sample point
						r_State <= sQtrDelay;
                        --r_DebugState <= 2;
                        r_TickCount <= r_TickCount + 1;
					end if;
				when sHalfDelay => -- delay thru 1/2 bit time (state 3)
					if (r_TickCount = g_QtrTime + g_QtrTime) then  -- aligned to half-bit time
						if (i_Bit = '0') then  -- sample current input value, if a zero
                        	r_State <= sReceive;  -- valid start bit, continue with next sample delay
                            --r_DebugState <= 4;
                            r_TickCount <= 1;  -- re-align bit timer to mid-bit position
                        else  -- invalid start bit
                        	r_State <= sIdle;  -- go back to idle state
                        	--r_DebugState <= 1;
                            r_TickCount <= 1;
                        end if;
					else  -- not yet at half-bit sample point
						r_State <= sHalfDelay;
                        --r_DebugState <= 3;
                        r_TickCount <= r_TickCount + 1;
					end if;
				when sReceive => -- begin receiving data (state 4)
					if (r_TickCount = (g_QtrTime + g_QtrTime + g_QtrTime + g_QtrTime)) then
                        -- aligned to middle of bit time
                        r_TickCount <= 1;
                        if (r_RxCount = 8) then
                        	r_TickCount <= 1;
                            r_State <= sValidate;
                            --r_DebugState <= 5;
                        else
							r_TempWord(r_RxCount) <= i_Bit;
							r_RxCount <= r_RxCount + 1;
                            r_TickCount <= 1;
                        	r_State <= sReceive;
                        	--r_DebugState <= 4;
                        end if;
					else
						r_State <= sReceive;
                        --r_DebugState <= 4;
                        r_TickCount <= r_TickCount + 1;
					end if;
				when sValidate => -- verify stop bit (state 5)
					if (i_Bit = '1') then -- treat as a valid stop bit
						r_Word <= r_TempWord;  -- pass received word to output
                        r_NewRxWordReady <= '1';  -- signal new word is ready
					end if;
	                r_State <= sIdle;  -- re-start receiving state machine
    	            --r_DebugState <= 1;
               		r_TickCount <= 1;
				when others => -- should never have to be reached
					r_State <= sIdle;
                    --r_DebugState <= 1;
			end case;
		end if;
	end process;
end architecture Behavior;
	
