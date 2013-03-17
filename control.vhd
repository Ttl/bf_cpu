library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
    Port ( clk, reset : in  STD_LOGIC;
           d_jumpf : in  STD_LOGIC;
           d_jumpb : in STD_LOGIC;
           c_skip : out STD_LOGIC;
           alu_z : in STD_LOGIC;
           pc_out : out  STD_LOGIC_VECTOR (12 downto 0);
           uart_tx_busy : in STD_LOGIC);
end control;

architecture Behavioral of control is

-- It takes two cycles to reverse the direction
type modetype is (M_RUN, M_JUMPB1, M_JUMPB2, M_JUMPF1, M_JUMPF2);
signal mode : modetype;

signal pc : std_logic_vector(12 downto 0) := (others => '0');
signal pc_next : std_logic_vector(12 downto 0);

signal sync_reset : std_logic;

--pragma synthesis_off
signal mode_debug : modetype;
signal match_bracket_debug : signed(7 downto 0);
--pragma synthesis_on
begin

-- Assing outgoing PC
pc_out <= pc;

-- Mode control
process(clk, reset, d_jumpf, d_jumpb)
-- Variable for counting brackets, add on jumpf, sub on jumpb
variable match_brackets : signed(7 downto 0) := to_signed(0,8);
begin
if reset = '1' then
    mode <= M_RUN;
    sync_reset <= '1';
    match_brackets := to_signed(0,8);
    c_skip <= '1';
elsif rising_edge(clk) then
    sync_reset <= '0';
    c_skip <= '1';
    -- If UART is busy we need to wait until it's available again
    if uart_tx_busy = '1' then
        pc <= pc;
    else
        if mode = M_JUMPF1 then
            pc <= std_logic_vector(unsigned(pc)+1);
            mode <= M_JUMPF2;
        elsif mode = M_JUMPB1 then
            pc <= std_logic_vector(unsigned(pc)-1);
            mode <= M_JUMPB2;
        elsif mode = M_RUN then
            c_skip <= '0';
            pc <= std_logic_vector(unsigned(pc)+1);
            match_brackets := to_signed(0,8);
            if d_jumpf = '1' and alu_z = '1' then
                mode <= M_JUMPF1;
                c_skip <= '1';
            end if;    
            if d_jumpb = '1' and alu_z = '0' then
                pc <= std_logic_vector(unsigned(pc)-2);
                mode <= M_JUMPB1;
                c_skip <= '1';
            end if;
        elsif mode = M_JUMPF2 then
            pc <= std_logic_vector(unsigned(pc)+1);
            if d_jumpb = '1' then
                if match_brackets = to_signed(0,8) then
                    mode <= M_RUN;
                else
                    match_brackets := match_brackets - 1;
                end if;
            end if;
            if d_jumpf = '1' then
                match_brackets := match_brackets + 1;
            end if;
        elsif mode = M_JUMPB2 then
            pc <= std_logic_vector(unsigned(pc)-1);
            if d_jumpf = '1' then
                if match_brackets = to_signed(0,8) then
                    pc <= std_logic_vector(unsigned(pc)+1);
                    mode <= M_RUN;
                else
                    match_brackets := match_brackets + 1;
                end if;
            end if;
            if d_jumpb = '1' then
                match_brackets := match_brackets - 1;
            end if;
        end if;
    end if;
    
--pragma synthesis_off
mode_debug <= mode;
match_bracket_debug <= match_brackets;
--pragma synthesis_on
end if;


end process;

end Behavioral;

