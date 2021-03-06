library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bfconfig.all;

entity control is
    Port ( clk, reset : in  STD_LOGIC;
           d_jumpf : in  STD_LOGIC;
           d_jumpb : in STD_LOGIC;
           d_write : in STD_LOGIC;
           d_read : in STD_LOGIC;
           c_skip : out STD_LOGIC;
           alu_z : in STD_LOGIC;
           pc_out : out  pctype;
           uart_tx_end : in STD_LOGIC;
           uart_rx_ready : in STD_LOGIC);
end control;

architecture Behavioral of control is

-- It takes two cycles to reverse the direction
type modetype is (M_RESET, M_RUN, M_JUMPF1, M_JUMPF2, M_JUMPB1, M_RXWAIT);
signal mode, mode_next : modetype := M_RESET;

signal pc : pctype := (others => '0');
signal pc_next : std_logic_vector(INST_MEM_SIZE downto 0);
signal pc_cache, pc_cache_next : pctype;
signal pc_overflow : std_logic;
signal brackets, brackets_next : unsigned(7 downto 0);

-- PC stack signals
signal stack_push_notpop : std_logic;
signal stack_enable : std_logic;
signal stack_pc : pctype;

-- Jumpf cache signals
signal cache_push, cache_valid : std_logic;
signal cache_out : pctype;
signal cache_ready, cache_ready_next : std_logic;

-- Skip one instruction when skipping instructions with jumpf cache
signal skip, skip_next : std_logic;

--pragma synthesis_off
signal mispredict, mispredict_next  : unsigned(31 downto 0) := to_unsigned(0,32);
signal predict, predict_next : unsigned(31 downto 0) := to_unsigned(0,32);

signal cache_miss, cache_miss_next  : unsigned(31 downto 0) := to_unsigned(0,32);
signal cache_hit, cache_hit_next : unsigned(31 downto 0) := to_unsigned(0,32);
signal cache_ready_prev : std_logic;
--pragma synthesis_on
begin

-- Stack for storing the program counter for faster return from branches
pcstack : entity work.stack
    Port map( clk => clk,
              reset => reset,
              enable => stack_enable,
              push_notpop => stack_push_notpop,
              pcin => pc,
              pcout => stack_pc
              );

jumpf_cache: entity work.cache
    Generic map(WIDTH => INST_MEM_SIZE, -- Length of address
             DWIDTH => INST_MEM_SIZE, -- Length of one entry
             CACHE_SIZE => JUMPF_CACHE_SIZE) -- Log2 of number of entries in the cache
    Port map( clk => clk,
           reset => reset,
           addr => pc_cache,
           din => pc,
           push => cache_push,
           valid => cache_valid,
           dout => cache_out
           );

pc_out <= pc_next(INST_MEM_SIZE-1 downto 0);


process(clk, mode_next, pc_next, pc_cache_next)
begin
    if rising_edge(clk) then
        if reset = '1' then
            mode <= M_RESET;
        else
            mode <= mode_next;
        end if;
        -- Program ended enter infinite loop
        if pc_overflow = '1' then
            pc <= pc;
        else
            pc <= pc_next(INST_MEM_SIZE-1 downto 0);
        end if;
        pc_cache <= pc_cache_next;
        brackets <= brackets_next;
        cache_ready <= cache_ready_next;
        skip <= skip_next;
        
        --pragma synthesis_off
        predict <= predict_next;
        mispredict <= mispredict_next;
        cache_hit <= cache_hit_next;
        cache_miss <= cache_miss_next;
        cache_ready_prev <= cache_ready;
        --pragma synthesis_on

    end if;
end process;

process(mode, pc, d_jumpf, d_jumpb, d_write, d_read, 
    stack_pc, alu_z, pc_cache, uart_tx_end, uart_rx_ready,
    brackets, cache_valid, cache_ready, cache_out, skip)
    
begin

stack_push_notpop <= '0';
cache_push <= '0';
cache_ready_next <= '0';
c_skip <= '0';
brackets_next <= brackets;
pc_next <= std_logic_vector(unsigned('0'&pc)+1);
pc_overflow <= pc_next(INST_MEM_SIZE);
-- Save next PC so we can get back where we were
-- if jump was predicted incorrectly
pc_cache_next <= pc_cache;
mode_next <= M_RUN;
skip_next <= '0';
stack_enable <= '0';
case mode is
    
    when M_RESET =>
        pc_cache_next <= (others => '0');
        brackets_next <= to_unsigned(0,8);
        c_skip <= '1';
        pc_next <= (others => '0');
        mode_next <= M_RUN;
        if d_write = '1' then
            mode_next <= M_RUN;
        elsif d_read = '1' then
            mode_next <= M_RXWAIT;
        elsif d_jumpf = '1' then
            mode_next <= M_JUMPF2;
        -- ] shouldn't never be first instruction
        end if;
    
    when M_JUMPF1 =>
        if d_jumpf = '1' then
            -- Two consecutive jumps, we need to push both of them to stack
            stack_push_notpop <= '1';
            stack_enable <= '1';
            brackets_next <= brackets + 1;
        end if;
        if alu_z = '1' then
            c_skip <= '1';
            stack_push_notpop <= '0';
            stack_enable <= '1';
            mode_next <= M_JUMPF2;
        else
             -- Infinite loop, but do what we are told to do
            if d_jumpb = '1' then
                pc_next <= '0'&pc_cache;
            end if;
            mode_next <= M_RUN;
        end if;

        
    when M_JUMPF2 =>
        -- Readying cache takes two clock cycles
        cache_ready_next <= '1';
        mode_next <= M_JUMPF2;
        c_skip <= '1';
        if d_jumpf = '1' then
            brackets_next <= brackets + 1;
        elsif d_jumpb = '1' then
            brackets_next <= brackets - 1;
            if brackets = 0 then
                -- Store jump end address to speed up future jumps
                cache_push <= '1';
                mode_next <= M_RUN;
            end if;
        end if;
        if cache_valid = '1' and cache_ready = '1' then
            -- Skip the next instruction
            --pragma synthesis_off
            cache_hit_next <= cache_hit+1;
            cache_miss_next <= cache_miss;
            --pragma synthesis_on
            
            skip_next <= '1';
            mode_next <= M_RUN;
            pc_next <= '0'&cache_out;
        --pragma synthesis_off
        elsif cache_ready = '1' and cache_ready_prev = '0' then
            -- We need to check previous cache_ready value
            -- to avoid double counting
            cache_hit_next <= cache_hit;
            cache_miss_next <= cache_miss+1;
        --pragma synthesis_on
        end if;
        
    when M_JUMPB1 =>
        mode_next <= M_RUN;
        if alu_z = '1' then
            --pragma synthesis_off
             mispredict_next <= mispredict + 1;
             predict_next <= predict;
            --pragma synthesis_on
            stack_push_notpop <= '0';
            stack_enable <= '1';
            c_skip <= '1';
            -- Necessary
            skip_next <= '1';
            pc_next <= '0'&pc_cache;
        else
            --pragma synthesis_off
             mispredict_next <= mispredict;
             predict_next <= predict + 1;
            --pragma synthesis_on
        end if;
        
    when M_RUN =>
        brackets_next <= to_unsigned(0,8);
        if d_jumpf = '1' then
            -- Jump forward
            pc_cache_next <= pc;
            mode_next <= M_JUMPF1;
            stack_push_notpop <= '1';
            stack_enable <= '1';
        elsif d_jumpb = '1' and skip = '0' then
            pc_cache_next <= pc;
            pc_next <= '0'&stack_pc;
            -- We need to check alu_z on the next cycle
            mode_next <= M_JUMPB1;
        elsif d_write = '1' then
            if uart_tx_end = '0' then
                c_skip <= '1';
                pc_next <= '0'&pc;
                mode_next <= M_RUN;
            else
                mode_next <= M_RUN;
            end if;
        elsif d_read = '1' then
            pc_next <= '0'&pc;
            mode_next <= M_RXWAIT;
        end if;
    
    when M_RXWAIT =>
        pc_next <= '0'&pc;
        mode_next <= M_RXWAIT;
        if uart_rx_ready = '1' then
            pc_next <= std_logic_vector(unsigned('0'&pc)+1);
            mode_next <= M_RUN;
        end if;
        
end case;


            
end process;

end Behavioral;

