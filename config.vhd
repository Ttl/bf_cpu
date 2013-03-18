library IEEE;
use IEEE.STD_LOGIC_1164.all;

package bfconfig is

    constant INST_MEM_SIZE : integer := 14;
    constant JUMPF_CACHE_SIZE : integer := 12; -- Log2 of cache size
    constant STACK_SIZE : integer := 8;
    
    subtype pctype is std_logic_vector(INST_MEM_SIZE-1 downto 0);


end bfconfig;

package body bfconfig is

 
end bfconfig;