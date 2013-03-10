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

signal tmp : std_logic_vector(7 downto 0);
begin

process(a, b, op)
begin
case op is

    when "00" =>
        tmp <= std_logic_vector(unsigned(a)+unsigned(b));
    when "01" =>
        tmp <= std_logic_vector(unsigned(a)+unsigned(b));
    when "10" =>
        tmp <= a;      
    when others =>
        tmp <= b;   
end case;
end process;

r <= tmp;
z <= '1' when tmp = x"00" else '0';

end Behavioral;

