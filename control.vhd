library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
    Port ( clk, reset : in  STD_LOGIC;
           d_jumpf : in  STD_LOGIC;
           d_jumpb : in STD_LOGIC;
           d_write : in STD_LOGIC;
           d_read : in STD_LOGIC;
           c_skip : out STD_LOGIC;
           alu_z : in STD_LOGIC;
           pc_out : out  STD_LOGIC_VECTOR (12 downto 0);
           uart_tx_end : in STD_LOGIC;
           uart_rx_ready : in STD_LOGIC);
end control;

architecture Behavioral of control is

-- It takes two cycles to reverse the direction
type modetype is (M_RESET, M_RUN, M_JUMPF1, M_JUMPF2, M_JUMPB1, M_TXWAIT, M_RXWAIT);
signal mode, mode_next : modetype := M_RESET;

signal pc : std_logic_vector(12 downto 0) := (others => '0');
signal pc_next, pc_cache, pc_cache_next : std_logic_vector(12 downto 0);

-- PC stack signals
signal stack_push, stack_pop : std_logic;
signal stack_pc : std_logic_vector(12 downto 0);

begin

-- Stack for storing the program counter for faster return from branches
pcstack : entity work.stack
    Port map( clk => clk,
              reset => reset,
              push => stack_push,
              pop => stack_pop,
              pcin => pc,
              pcout => stack_pc
              );

pc_out <= pc_next;


process(clk, mode_next, pc_next, pc_cache_next)
begin
    if rising_edge(clk) then
        if reset = '1' then
            mode <= M_RESET;
        else
            mode <= mode_next;
        end if;
        pc <= pc_next;
        pc_cache <= pc_cache_next;
    end if;
end process;

process(mode, pc, d_jumpf, d_jumpb, d_write, d_read, stack_pc, alu_z, pc_cache, uart_tx_end, uart_rx_ready)
begin

stack_push <= '0';
stack_pop <= '0';
c_skip <= '0';
pc_next <= std_logic_vector(unsigned(pc)+1);
-- Save next PC so we can get back where we were
-- if jump was predicted incorrectly
pc_cache_next <= pc_cache;
mode_next <= M_RUN;
case mode is
    
    when M_RESET =>
        c_skip <= '1';
        pc_next <= (others => '0');
        stack_push <= '0';
        stack_pop <= '0';
        mode_next <= M_RUN;
        if d_write = '1' then
            mode_next <= M_TXWAIT;
        elsif d_read = '1' then
            mode_next <= M_RXWAIT;
        elsif d_jumpf = '1' then
            mode_next <= M_JUMPF2;
        -- ] shouldn't never be first instruction
        end if;
    
    when M_JUMPF1 =>
        mode_next <= M_JUMPF2;
        
    when M_JUMPF2 =>
        if d_jumpb = '1' then
            mode_next <= M_RUN;
        end if;
        
    when M_JUMPB1 =>
        mode_next <= M_RUN;
        if alu_z = '1' then
            stack_pop <= '1';
            c_skip <= '1';
            pc_next <= std_logic_vector(unsigned(pc_cache)+1);
        end if;
        
    when M_RUN =>
        if d_jumpf = '1' then
            -- Jump forward
            if alu_z = '1' then
                mode_next <= M_JUMPF1;
                c_skip <= '1';
            else
                stack_push <= '1';
            end if;
        elsif d_jumpb = '1' then
            pc_cache_next <= pc;
            pc_next <= stack_pc;
            c_skip <= '1';
            -- We need to check the alu_z on next cycle
            mode_next <= M_JUMPB1;
        elsif d_write = '1' then
            mode_next <= M_TXWAIT;
        end if;
        
    when M_TXWAIT =>
        pc_next <= pc;
        c_skip <= '1';
        mode_next <= M_TXWAIT;
        if uart_tx_end = '1' then
            mode_next <= M_RUN;
        end if;
    
    when M_RXWAIT =>
        pc_next <= pc;
        c_skip <= '1';
        mode_next <= M_RXWAIT;
        if uart_rx_ready = '1' then
            mode_next <= M_RUN;
        end if;
        
end case;
end process;

end Behavioral;

