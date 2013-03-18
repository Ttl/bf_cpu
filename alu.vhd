library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bfconfig.all;

entity alu is
    Port ( a : in  pointertype;
           b : in  STD_LOGIC_VECTOR (7 downto 0);
           op : in  STD_LOGIC_VECTOR (1 downto 0);
           r : out  pointertype;
           z : out STD_LOGIC);
end alu;

architecture Behavioral of alu is

signal tmp : pointertype;
signal sign_ext : std_logic_vector(REG_SIZE-1 downto 8);
begin

process(a, b, op)
variable sign_ext : std_logic_vector(REG_SIZE-1 downto 8);
begin
sign_ext := (others => b(7));
case op is

    when "00" =>
        tmp <= std_logic_vector(unsigned(a)+unsigned(sign_ext&b));
    when "01" =>
        tmp <= std_logic_vector(unsigned(a)+unsigned(sign_ext&b));
    when "10" =>
        tmp <= a;      
    when others =>
        tmp <= sign_ext&b;   
end case;
end process;

r <= tmp;
z <= '1' when unsigned(tmp(7 downto 0)) = 0 else '0';

end Behavioral;

