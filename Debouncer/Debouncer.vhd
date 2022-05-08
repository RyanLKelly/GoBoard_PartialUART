library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Debouncer is
    port (
        i_Clock : in std_logic;
        i_Switch : in std_logic;
        o_Debounced : out std_logic -- output changes only after button state stabilizes
    );
	constant STABLE_CYCLES : INTEGER := 262143;
    --constant STABLE_CYCLES : INTEGER := 10;
end entity Debouncer;

architecture Behavior of Debouncer is
    type STATE_TYPE is (sInit, s0, s1);
    signal r_State : STATE_TYPE;
    signal r_Count : integer range 0 to 262143; -- 0 to 2^18-1; i.e., 18-bit int
    signal r_Prev : std_logic; -- registered button state
    signal r_Output : std_logic; -- registered output, wired to output port
    --signal r_Debug_State : integer range 0 to 2;
begin
    o_Debounced <= r_Output;
    process(i_Clock) is
    begin
        if rising_edge(i_Clock) then
        	case r_State is
            	when sInit => -- boot up state, one time thru
                	r_Count <= 1;
                    r_Prev <= '0';
                    r_Output <= '0';
                    r_State <= s0;
                    --r_Debug_State <= 1;
                when s0 => -- not debouncing, idling
                    if (i_Switch /= r_Prev) then
                    	r_State <= s1; -- enter penalty timer
                        --r_Debug_State <= 2;
                    else
                    	r_State <= s0;
                        --r_Debug_State <= 1;
                    end if;
                	r_Prev <= i_Switch;
                when s1 => -- debouncing state
                	if (r_Count = STABLE_CYCLES) then -- stable
                    	r_Output <= i_Switch;  -- finally connect to output
                        r_Count <= 1;  -- reset for idle state
                        r_State <= s0; -- move to idle state (not debouncing)
                        --r_Debug_State <= 1;
                    elsif (r_Prev = i_Switch) then  -- stable for this cycle
                    	r_Count <= r_Count + 1;  -- give it 1 tick 'credit'
                        r_State <= s1;  -- repeat debouncing state 'loop'
                        --r_Debug_State <= 2; 
                        r_Prev <= i_Switch; -- store current input as next sample pt
                    else  -- fresh disagreement between last value and current input
                    	r_Count <= 1;  -- reset penalty timer
                        r_State <= s1; 
                        --r_Debug_State <= 2;  -- repeat debouncing state 'loop'
                        r_Prev <= i_Switch;  -- store current input as next sample pt
                    end if;
                when others =>
                	r_Count <= 1;
                    r_Prev <= '0';
                    r_Output <= '0';
                    r_State <= s0;
                    --r_Debug_State <= 1;
			end case;
		end if;
    end process;
end architecture Behavior;