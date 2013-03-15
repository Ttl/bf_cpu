library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control is
    Port ( clk, reset : in  STD_LOGIC;
           d_jumpf : in  STD_LOGIC;
           d_jumpb : in STD_LOGIC;
           c_skip : out STD_LOGIC;
           alu_z : in STD_LOGIC;
           pc_out : out  STD_LOGIC_VECTOR (12 downto 0));
end control;

architecture Behavioral of control is

type modetype is (M_RUN, M_JUMPB, M_JUMPF);
signal mode : modetype := M_RUN;

signal pc : std_logic_vector(12 downto 0) := (others => '0');
signal pc_next : std_logic_vector(12 downto 0);
begin

-- Assign next PC
pc_next <= std_logic_vector(unsigned(pc)+1) when mode = M_RUN or mode = M_JUMPF else
           std_logic_vector(unsigned(pc)-1);

-- Assing outgoing PC
pc_out <= pc;

-- Skip instruction when mode is not M_RUN
c_skip <= '0' when mode = M_RUN else '1';

-- PC flip flop
process(clk, reset)
begin
if reset = '1' then
    pc <= (others => '0');
end if;
if rising_edge(clk) then
    pc <= pc_next;
end if;
end process;

-- mode control
process(clk, reset, d_jumpf, d_jumpb)
-- Variable for counting brackets, add on jumpf, sub on jumpb
variable match_brackets : signed(7 downto 0) := to_signed(0,8);
begin
if reset = '1' then
    mode <= M_RUN;
    match_brackets := to_signed(0,8);
end if;
if rising_edge(clk) then
    -- If we get jump instruction and ALU result is zero find the other end of jump
    if mode = M_RUN then
        match_brackets := to_signed(0,8);
        if d_jumpf = '1' and alu_z = '1' then
            mode <= M_JUMPF;
        end if;    
        if d_jumpb = '1' and alu_z = '0' then
            mode <= M_JUMPB;
        end if;
    elsif mode = M_JUMPF then
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
    elsif mode = M_JUMPB then
        if d_jumpf = '1' then
            if match_brackets = to_signed(0,8) then
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
end process;

end Behavioral;

