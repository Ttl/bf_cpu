library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bfconfig.all;

-- Stack used to store PC for jumps
entity stack is
    Port ( clk, reset : in  STD_LOGIC;
           enable : in STD_LOGIC;
           push_notpop : in  STD_LOGIC;
           pcin : in  pctype;
           pcout : out  pctype);
end stack;

architecture Behavioral of stack is

type stacktype is array(0 to 2**STACK_SIZE-1) of pctype;
signal mem : stacktype;

signal async_read : pctype;
signal enable_delay : std_logic;
signal mem_out : pctype;
begin

process(clk, reset, push_notpop, enable, pcin, mem)
variable pointer : unsigned(STACK_SIZE-1 downto 0);
begin
if reset = '1' then
        pointer := to_unsigned(0, STACK_SIZE);

elsif rising_edge(clk) then
        enable_delay <= enable;
        if enable = '1' then
            if push_notpop = '1' then
                -- Push
                pointer := pointer + 1;
                mem(to_integer(pointer)) <= pcin;
                async_read <= pcin;
            else
                -- Pop
                pointer := pointer - 1;
            end if;
        end if;
mem_out <= mem(to_integer(pointer));
end if;

end process;

pcout <= async_read when enable_delay = '1' else mem_out;
end Behavioral;

