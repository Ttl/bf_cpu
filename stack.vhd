library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Stack used to store PC for jumps
entity stack is
    Port ( clk, reset : in  STD_LOGIC;
           push, pop : in  STD_LOGIC;
           pcin : in  STD_LOGIC_VECTOR (12 downto 0);
           pcout : out  STD_LOGIC_VECTOR (12 downto 0));
end stack;

architecture Behavioral of stack is

type stacktype is array(0 to 2**6-1) of std_logic_vector(12 downto 0);
signal mem : stacktype;

begin

process(clk, reset, push, pop, pcin, mem)
variable pointer : unsigned(5 downto 0);
begin

if rising_edge(clk) then
    if push = '1' then
        pointer := pointer + 1;
        mem(to_integer(pointer)) <= pcin;
    elsif pop = '1' then
        pointer := pointer - 1;
    end if;
end if;

pcout <= mem(to_integer(pointer));

if reset = '1' then
    pointer := to_unsigned(0, 6);
end if;
end process;

end Behavioral;

