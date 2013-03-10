library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port ( a : in  STD_LOGIC_VECTOR (7 downto 0);
           b : in  STD_LOGIC_VECTOR (7 downto 0);
           op : in  STD_LOGIC_VECTOR (1 downto 0);
           r : out  STD_LOGIC_VECTOR (7 downto 0);
           z : out STD_LOGIC);
end alu;

architecture Behavioral of alu is

begin

process(a, b, op)
begin
case op is

    when "00" =>
        r <= std_logic_vector(unsigned(a)+unsigned(b));
    when "01" =>
        r <= std_logic_vector(unsigned(a)+unsigned(b));
    when "10" =>
        r <= a;      
    when "11" =>
        r <= b;   
end case;
end process;

z <= '1' when r = (others => '0') else '0';

end Behavioral;

