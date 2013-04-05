library IEEE;
use IEEE.STD_LOGIC_1164.all;

package bfconfig is

    -- Sizes are log2 of full sizes
    constant INST_MEM_SIZE : integer := 14;
    constant JUMPF_CACHE_SIZE : integer := 3;
    constant STACK_SIZE : integer := 8;
    constant REG_SIZE : integer := 9;
    
    subtype pctype is std_logic_vector(INST_MEM_SIZE-1 downto 0);
    subtype pointertype is std_logic_vector(REG_SIZE-1 downto 0);


end bfconfig;

package body bfconfig is

 
end bfconfig;