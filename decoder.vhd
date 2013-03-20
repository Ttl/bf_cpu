library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Decoder reads the instruction from RAM and outputs
-- the datapath control signals for executing that
-- instruction

entity decoder is
    Port ( instr : in  STD_LOGIC_VECTOR(7 downto 0);
           d_alutoreg : out STD_LOGIC;
           d_alua : out STD_LOGIC_VECTOR(1 downto 0);
           d_alub : out STD_LOGIC_VECTOR(1 downto 0);
           d_write : out STD_LOGIC;
           d_read : out STD_LOGIC;
           d_aluop : out STD_LOGIC_VECTOR(1 downto 0);
           d_jumpf : out STD_LOGIC;
           d_jumpb : out STD_LOGIC
           );
end decoder;

architecture Behavioral of decoder is

begin


process(instr)
begin


-- d_aluop
-- 00 : add
-- 01 : illegal
-- 10 : pass a
-- 11 : pass b

-- d_alutoreg
-- 0 : write alu result to mem(pointer)
-- 1 : write alu result to pointer

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

-- d_write
-- 1 : write alu result to output

d_alutoreg <= '0';
d_alub <= "00";
d_alua <= "00";
d_write <= '0';
d_read <= '0';
d_aluop <= "00";
d_jumpf <= '0';
d_jumpb <= '0';

case instr is
    
    -- <
    when x"3C" =>
        d_alutoreg <= '1';
        d_alua <= "01";
        d_alub <= "10";
    
    -- >
    when x"3E" =>
        d_alutoreg <= '1';
        d_alua <= "01";
        d_alub <= "01";
    
    -- +
    when x"2B" =>
        d_alub <= "01";
    
    -- -
    when x"2D" =>
        d_alub <= "10";
    
    -- .
    when x"2E" =>
        d_write <= '1';
    
    -- ,
    when x"2C" =>
        d_read <= '1';
        d_alua <= "11";
        
    -- [
    when x"5B" =>
        d_jumpf <= '1';
        
    -- ]
    when x"5D" =>
        d_jumpb <= '1';
        
    when others =>
        -- nop
        
end case;

end process;

end Behavioral;

