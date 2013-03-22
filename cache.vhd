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

type cache_type_data is array(0 to 2**CACHE_SIZE-1) of std_logic_vector(DWIDTH-1 downto 0);
type cache_type_tag is array(0 to 2**CACHE_SIZE-1) of std_logic_vector(WIDTH-1 downto CACHE_SIZE);

signal last_used : std_logic_vector(2**CACHE_SIZE-1 downto 0);
signal valid0, valid1 : std_logic_vector(2**CACHE_SIZE-1 downto 0);

signal cache0_d, cache1_d : cache_type_data;
signal cache0_t, cache1_t : cache_type_tag;

begin

process(clk, reset, addr, din, push)
begin

if rising_edge(clk) then
    
    if reset = '1' then
        for I in 0 to 2**CACHE_SIZE-1 loop
            valid0(to_integer(to_unsigned(I, CACHE_SIZE))) <= '0';
            valid1(to_integer(to_unsigned(I, CACHE_SIZE))) <= '0';
        end loop;
    end if;
    
    -- Write to free location or replace randomly
    if push = '1' then
        if valid0(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) = '0' then
            cache0_t(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= addr(WIDTH-1 downto CACHE_SIZE);
            cache0_d(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= din;
            valid0(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '1';
            last_used(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '0';
        elsif valid1(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) = '0' then
            cache1_t(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= addr(WIDTH-1 downto CACHE_SIZE);
            cache1_d(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= din;
            valid1(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '1';
            last_used(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '1';
        else
            -- Both locations already occupied so decide least recently used
            if last_used(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) = '0' then
                cache1_t(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= addr(WIDTH-1 downto CACHE_SIZE);
                cache1_d(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= din;
                valid1(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '1';
                last_used(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '1';
            else
                cache0_t(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= addr(WIDTH-1 downto CACHE_SIZE);
                cache0_d(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= din;
                valid0(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '1';
                last_used(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) <= '0';
            end if;
        end if;
    end if;
    
    -- Set output if tag matches and entry is valid
    if valid0(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) = '1'  
            and cache0_t(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) = addr(WIDTH-1 downto CACHE_SIZE) then
        valid <= '1';
        dout <= cache0_d(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0))));
    elsif valid1(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) = '1'  
            and cache1_t(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0)))) = addr(WIDTH-1 downto CACHE_SIZE) then
        valid <= '1';
        dout <= cache1_d(to_integer(unsigned(addr(CACHE_SIZE-1 downto 0))));
    else
        valid <= '0';
        dout <= (others => '-'); 
    end if;
    
end if;
end process;

end Behavioral;

