library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bfconfig.all;

entity reg_file is
Port ( clk : in  STD_LOGIC;
       a1 : in  pointertype;
       wd : in  STD_LOGIC_VECTOR (7 downto 0);
       d1 : out  STD_LOGIC_VECTOR (7 downto 0);
       we : in  STD_LOGIC);
end reg_file;

architecture Behavioral of reg_file is

type memtype is array(0 to 2**REG_SIZE-1) of std_logic_vector(7 downto 0);
signal reg_mem : memtype := (others => (others => '0'));
begin

process(clk, we, a1, reg_mem)
begin

if rising_edge(clk) then
    if we = '1' then
        reg_mem(to_integer(unsigned(a1))) <= wd;
    end if;
end if;

d1 <= reg_mem(to_integer(unsigned(a1)));

end process;

end Behavioral;

