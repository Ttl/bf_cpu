library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
    Port ( clk, reset : in  STD_LOGIC;
           branch : out  STD_LOGIC;
           pc : out  STD_LOGIC_VECTOR (12 downto 0));
end control;

architecture Behavioral of control is

begin


end Behavioral;

