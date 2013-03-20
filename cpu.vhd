library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.bfconfig.all;
--pragma synthesis_off
use IEEE.NUMERIC_STD.ALL;
--pragma synthesis_on

entity cpu is
    Generic ( INSTRUCTIONS : string := "scripts/instructions.mif"
            );
    Port ( clk, reset : in  STD_LOGIC;
           tx : out  STD_LOGIC;
           rx : in  STD_LOGIC);
end cpu;

architecture Behavioral of cpu is

signal instr : std_logic_vector(7 downto 0);

-- Decoder signals
signal d_alutoreg : std_logic;
signal d_alua, d_alub : std_logic_vector(1 downto 0);
signal d_write, d_read : std_logic;
signal d_jumpf, d_jumpb : std_logic;

signal pc : pctype;

-- RAM signals
constant i_wd : std_logic_vector(7 downto 0) := (others => '0');
constant i_we : std_logic := '0';

-- Datapath signals
signal readdata, writedata : std_logic_vector(7 downto 0);
signal alu_z : std_logic;

-- UART signals
signal uart_tx_req : std_logic;
signal uart_tx_end : std_logic;
signal uart_rx_ready : std_logic;

-- Control signals
signal c_skip : std_logic;

-- Execute state signals
signal e_alutoreg, e_skip : std_logic;
signal e_alua, e_alub : std_logic_vector(1 downto 0);

--pragma synthesis_off
-- Currently executing instruction
signal instr_ex : std_logic_vector(7 downto 0);
--pragma synthesis_on
begin

instr_mem : entity work.memory
    Generic map(
        CONTENTS => INSTRUCTIONS
        )
    Port map( clk => clk,
           a1 => pc,
           wd => i_wd,
           d1 => instr,
           we => i_we);
           
decoder1 : entity work.decoder
    Port map( instr => instr,
           d_alutoreg => d_alutoreg,
           d_alua => d_alua,
           d_alub => d_alub,
           d_write => d_write,
           d_read => d_read,
           d_jumpf => d_jumpf,
           d_jumpb => d_jumpb
           );

control1 : entity work.control
    Port map( clk => clk,
           reset => reset,
           d_jumpf => d_jumpf,
           d_jumpb => d_jumpb,
           d_write => d_write,
           d_read => d_read,
           c_skip => c_skip,
           alu_z => alu_z,
           pc_out => pc,
           uart_tx_end => uart_tx_end,
           uart_rx_ready => uart_rx_ready
           );

process(clk)
begin
if rising_edge(clk) then
    e_alutoreg <= d_alutoreg;
    e_alua <= d_alua;
    e_alub <= d_alub;
    e_skip <= c_skip;
    --pragma synthesis_off
    instr_ex <= instr;
    --pragma synthesis_on
end if;
end process;

datapath1 : entity work.datapath
    Port map( clk => clk,
           reset => reset,
           c_skip => e_skip,
           d_alutoreg => e_alutoreg,
           d_alua => e_alua,
           d_alub => e_alub,
           readdata => readdata,
           writedata => writedata,
           alu_z => alu_z);     

uart_tx_req <= d_write and not c_skip;

--pragma synthesis_off
-- Print sent data
process
begin
wait until uart_tx_req = '1';
wait until rising_edge(clk);
wait until rising_edge(clk);
if to_integer(unsigned(writedata)) > 31 and to_integer(unsigned(writedata)) < 127 then
    report "Sent ASCII: "&character'image(character'val(to_integer(unsigned(writedata))));
else
    report "Sent Dec: "&integer'image(to_integer(unsigned(writedata)));
end if;
wait until uart_tx_end = '1';

end process;
--pragma synthesis_on

uart1 : entity work.uart
Generic map(
	CLK_FREQ => 100,
	SER_FREQ => 1000000,
	PARITY_BIT => false
)
Port map (
	clk	=> clk,
	rst	=> reset,
	rx => rx,
	tx => tx,
	tx_req => uart_tx_req,
	tx_end => uart_tx_end,
	tx_data	=> writedata,
	rx_ready => uart_rx_ready,
	rx_data	=> readdata
);
           
end Behavioral;

