library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cache is
    Generic (WIDTH : natural := 13; -- Length of address
             DWIDTH : natural := 13; -- Length of one entry
             CACHE_SIZE : natural := 4); -- Log2 of number of entries in the cache
    Port ( clk, reset : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           din : in  STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           push : in  STD_LOGIC;
           valid : out  STD_LOGIC;
           dout : out  STD_LOGIC_VECTOR (WIDTH-1 downto 0));
end cache;

architecture Behavioral of cache is

type cache_entry is
  record
     tag : std_logic_vector(WIDTH-1 downto CACHE_SIZE);
     data : std_logic_vector(DWIDTH-1 downto 0);
     valid : std_logic;
  end record;
  
type cache_type is array(0 to 2**CACHE_SIZE-1) of cache_entry;

signal cache_mem : cache_type := (others => (valid => '0', others => (others => '-')));
begin

process(clk, reset, addr, din, push, cache_mem)
begin

if rising_edge(clk) then
    if reset = '1' then
        for I in 0 to 2**CACHE_SIZE-1 loop
            cache_mem(to_integer(to_unsigned(I, CACHE_SIZE))).valid <= '0';
        end loop;
    end if;
    
    -- Write to current location
    if push = '1' then
        cache_mem(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))).tag <= addr(WIDTH-1 downto CACHE_SIZE);
        cache_mem(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))).data <= din;
        cache_mem(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))).valid <= '1';
    end if;
    
    -- Set output if tag matches and entry is valid
    if cache_mem(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))).valid = '1' and cache_mem(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))).tag = addr(WIDTH-1 downto CACHE_SIZE) then
        valid <= '1';
        dout <= cache_mem(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))).data;
    else
        valid <= '0';
        dout <= (others => '-');
    end if;
end if;
end process;

end Behavioral;

