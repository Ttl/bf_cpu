library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.bfconfig.all;
use ieee.numeric_std.all;

entity datapath is
    Port ( clk, reset : in  STD_LOGIC;
           c_skip : in STD_LOGIC;
           d_alutoreg : in  STD_LOGIC;
           d_alua : in STD_LOGIC_VECTOR(1 downto 0);
           d_alub : in STD_LOGIC_VECTOR(1 downto 0);
           d_aluop : in STD_LOGIC_VECTOR(1 downto 0);
           readdata : in STD_LOGIC_VECTOR(7 downto 0);
           writedata : out STD_LOGIC_VECTOR(7 downto 0);
           alu_z : out STD_LOGIC);
end datapath;

architecture Behavioral of datapath is

signal alua_out : pointertype;
signal alub_out : std_logic_vector(7 downto 0);
signal alu_result : pointertype;

-- Pointer to registers
signal pointer : pointertype := (others => '0');
-- Register output from address pointed by pointer
signal mem : std_logic_vector(7 downto 0);

signal reg_write : std_logic;

constant zeros : std_logic_vector(REG_SIZE-1 downto 8) := (others => '0');

begin

-- d_alua
-- 00 : mem(pointer)
-- 01 : pointer
-- 10 : read from input
-- 11 : illegal

-- d_alub
-- 00 : 0
-- 01 : 1
-- 10 : -1
-- 11 : illegal

-- d_alutoreg
-- 0 : write alu result to mem(pointer)
-- 1 : write alu result to pointer

process(clk, reset)
begin
if reset = '1' then
    pointer <= (others => '0');
elsif rising_edge(clk) then
    if d_alutoreg = '1' and c_skip = '0' then
        pointer <= alu_result;
    else
        pointer <= pointer;
    end if;
end if;
end process;

alua_out <= zeros&mem when d_alua = "00" else
            pointer when d_alua = "01" else
            zeros&readdata;

alub_out <= x"00" when d_alub = "00" else
            x"01" when d_alub = "01" else
            x"FF";

reg_write <= (not d_alutoreg and not c_skip);

regs : entity work.reg_file
Port map( clk => clk,
       a1 => pointer,
       wd => alu_result(7 downto 0),
       d1 => mem,
       we => reg_write
       );
       
alu1 : entity work.alu
    Port map ( a => alua_out,
           b => alub_out,
           op => d_aluop,
           r => alu_result,
           z => alu_z);

writedata <= mem;

end Behavioral;

