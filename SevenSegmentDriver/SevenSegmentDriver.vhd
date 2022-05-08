library IEEE;
use IEEE.std_logic_1164.all;

entity SevenSegmentDriver is
    port (
        i_Clock : in std_logic;
        i_Value : in std_logic_vector(3 downto 0); -- Leftmost (bit 3) is MSB
        o_Seg_A : out std_logic; -- Letters represent common 7SD labels as shown on Google images
		o_Seg_B : out std_logic;
		o_Seg_C : out std_logic;
		o_Seg_D : out std_logic;
		o_Seg_E : out std_logic;
		o_Seg_F : out std_logic;
		o_Seg_G : out std_logic
    );
end entity SevenSegmentDriver;

architecture Behavior of SevenSegmentDriver is
    signal r_Seg_A : std_logic;
	signal r_Seg_B : std_logic;
	signal r_Seg_C : std_logic;
	signal r_Seg_D : std_logic;
	signal r_Seg_E : std_logic;
	signal r_Seg_F : std_logic;
	signal r_Seg_G : std_logic;
begin
	o_Seg_A <= not r_Seg_A; -- 7SD segments illuminate when LOW (i.e., ACTIVE LOW, oddly)
	o_Seg_B <= not r_Seg_B;
	o_Seg_C <= not r_Seg_C;
	o_Seg_D <= not r_Seg_D;
	o_Seg_E <= not r_Seg_E;
	o_Seg_F <= not r_Seg_F;
	o_Seg_G <= not r_Seg_G;
	
    process(i_Clock) is
    begin
        if rising_edge(i_Clock) then
            case i_Value is -- illuminate 0 through F as appropriate
				when "0000" =>
					r_Seg_A <= '1';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '0';
				when "0001" =>
					r_Seg_A <= '0';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '0';
					r_Seg_E <= '0';
					r_Seg_F <= '0';
					r_Seg_G <= '0';
				when "0010" =>
					r_Seg_A <= '1';
					r_Seg_B <= '1';
					r_Seg_C <= '0';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '0';
					r_Seg_G <= '1';
				when "0011" =>
					r_Seg_A <= '1';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '1';
					r_Seg_E <= '0';
					r_Seg_F <= '0';
					r_Seg_G <= '1';
				when "0100" =>
					r_Seg_A <= '0';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '0';
					r_Seg_E <= '0';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "0101" =>
					r_Seg_A <= '1';
					r_Seg_B <= '0';
					r_Seg_C <= '1';
					r_Seg_D <= '1';
					r_Seg_E <= '0';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "0110" =>
					r_Seg_A <= '1';
					r_Seg_B <= '0';
					r_Seg_C <= '1';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "0111" =>
					r_Seg_A <= '1';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '0';
					r_Seg_E <= '0';
					r_Seg_F <= '0';
					r_Seg_G <= '0';
				when "1000" =>
					r_Seg_A <= '1';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "1001" =>
					r_Seg_A <= '1';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '0';
					r_Seg_E <= '0';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "1010" => -- A
					r_Seg_A <= '1';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '0';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "1011" => -- B
					r_Seg_A <= '0';
					r_Seg_B <= '0';
					r_Seg_C <= '1';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "1100" => -- C
					r_Seg_A <= '1';
					r_Seg_B <= '0';
					r_Seg_C <= '0';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '0';
				when "1101" => -- D
					r_Seg_A <= '0';
					r_Seg_B <= '1';
					r_Seg_C <= '1';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '0';
					r_Seg_G <= '1';
				when "1110" => -- E
					r_Seg_A <= '1';
					r_Seg_B <= '0';
					r_Seg_C <= '0';
					r_Seg_D <= '1';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '1';
				when "1111" => -- F
					r_Seg_A <= '1';
					r_Seg_B <= '0';
					r_Seg_C <= '0';
					r_Seg_D <= '0';
					r_Seg_E <= '1';
					r_Seg_F <= '1';
					r_Seg_G <= '1';					
				when others => -- No possible other values, in reality
					r_Seg_A <= '0';
					r_Seg_B <= '0';
					r_Seg_C <= '0';
					r_Seg_D <= '0';
					r_Seg_E <= '0';
					r_Seg_F <= '0';
					r_Seg_G <= '0';
			end case;
         end if;
    end process;
end architecture Behavior;