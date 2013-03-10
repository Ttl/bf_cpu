library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    Port ( instr : in  STD_LOGIC_VECTOR(7 downto 0);
           d_jumpf : out  STD_LOGIC;
           d_jumpb : out  STD_LOGIC;
           d_add : out  STD_LOGIC;
           d_sub : out  STD_LOGIC;
           d_inc : out STD_LOGIC;
           d_dec : out STD_LOGIC;
           d_imm : out  STD_LOGIC_VECTOR (7 downto 0);
           d_read : out  STD_LOGIC;
           d_write : out  STD_LOGIC;
           d_step : out STD_LOGIC_VECTOR(3 downto 0));
end decoder;

architecture Behavioral of decoder is

begin
d_jumpf <= '0';
d_jumpb <= '0';
d_add <= '0';
d_sub <= '0';
d_inc <= '0';
d_dec <= '0';
d_imm <= (others => '0');
d_read <= '0';
d_write <= '0';
d_step <= "0001";

process(instr)
begin

case instr is
    
    -- <
    when x"3C" =>
        d_dec <= '1';
    
    -- >
    when x"3E" =>
        d_inc <= '1';
    
    -- +
    when x"2B" =>
        d_add <= '1';
    
    -- -
    when x"2D" =>
        d_sub <= '1';
    
    -- .
    when x"2E" =>
        d_write <= '1';
    
    -- ,
    when x"2C" =>
        d_read <= '1';
        
    -- [
    when x"5B" =>
        d_jumpf <= '1';
        
    -- ]
    when x"5D" =>
        d_jumpb <= '1';
        
end case;

end process;

end Behavioral;

