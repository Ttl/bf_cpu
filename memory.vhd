library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity memory is
    Generic (
        CONTENTS : string := "scripts/instructions.mif"
        );
    Port ( clk : in  STD_LOGIC;
           a1 : in  STD_LOGIC_VECTOR (12 downto 0);
           wd : in  STD_LOGIC_VECTOR (7 downto 0);
           d1 : out  STD_LOGIC_VECTOR (7 downto 0);
           we : in  STD_LOGIC);
end memory;

architecture Behavioral of memory is

type memtype is array(0 to 2**12-1) of std_logic_vector(7 downto 0);

impure function init_mem(mif_file_name : in string) return memtype is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(7 downto 0);
    variable temp_mem : memtype;
    variable i : integer := 0;
begin
        for j in 0 to memtype'length-1 loop
            readline(mif_file, mif_line);
            if not endfile(mif_file) then
                read(mif_line, temp_bv);
                temp_mem(i) := to_stdlogicvector(temp_bv);
            else
                temp_mem(j) := (others => '0');
            end if;
        end loop;
    return temp_mem;
end function;

signal mem : memtype := init_mem(CONTENTS);
begin

process(clk, we, a1, mem)
begin

if rising_edge(clk) then
    if we = '1' then
        mem(to_integer(unsigned(a1))) <= wd;
    end if;
end if;

d1 <= mem(to_integer(unsigned(a1)));

end process;
end Behavioral;

