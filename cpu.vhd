library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity cpu is
    Generic ( INSTRUCTIONS : string := "scripts/instructions.mif"
            );
    Port ( clk, reset : in  STD_LOGIC;
           tx : out  STD_LOGIC;
           rx : in  STD_LOGIC);
end cpu;

architecture Behavioral of cpu is

signal instr : std_logic_vector(7 downto 0);

-- Decoder signals
signal d_alutoreg : std_logic;
signal d_alua, d_alub, d_aluop : std_logic_vector(1 downto 0);
signal d_write : std_logic;
signal d_jumpf, d_jumpb : std_logic;

signal pc : std_logic_vector(12 downto 0);

-- RAM signals
signal i_wd : std_logic_vector(7 downto 0) := (others => '0');
signal i_we : std_logic := '0';

begin

instr_mem : entity work.memory
    Generic map(
        CONTENTS => INSTRUCTIONS
        )
    Port map( clk => clk,
           a1 => pc,
           wd => i_wd,
           d1 => instr,
           we => i_we);
           
decoder1 : entity work.decoder
    Port map( instr => instr,
           d_alutoreg => d_alutoreg,
           d_alua => d_alua,
           d_alub => d_alub,
           d_write => d_write,
           d_aluop => d_aluop,
           d_jumpf => d_jumpf,
           d_jumpb => d_jumpb
           );
        
end Behavioral;

