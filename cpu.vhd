library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

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
signal d_alua, d_alub, d_aluop : std_logic_vector(1 downto 0);
signal d_write : std_logic;
signal d_jumpf, d_jumpb : std_logic;

signal pc : std_logic_vector(12 downto 0);

-- RAM signals
signal i_wd : std_logic_vector(7 downto 0) := (others => '0');
signal i_we : std_logic := '0';

-- Datapath signals
signal readdata, writedata : std_logic_vector(7 downto 0);
signal alu_z : std_logic;

-- UART signals
signal uart_tx_busy : std_logic;
signal uart_rx_ready : std_logic;

-- Control signals
signal c_skip : std_logic;
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
           d_aluop => d_aluop,
           d_jumpf => d_jumpf,
           d_jumpb => d_jumpb
           );

control1 : entity work.control
    Port map( clk => clk,
           reset => reset,
           d_jumpf => d_jumpf,
           d_jumpb => d_jumpb,
           c_skip => c_skip,
           alu_z => alu_z,
           pc_out => pc,
           uart_tx_busy => uart_tx_busy
           );

datapath1 : entity work.datapath
    Port map( clk => clk,
           reset => reset,
           c_skip => c_skip,
           d_alutoreg => d_alutoreg,
           d_alua => d_alua,
           d_alub => d_alub,
           d_aluop => d_aluop,
           d_write => d_write,
           readdata => readdata,
           writedata => writedata,
           alu_z => alu_z);     

uart1 : entity work.uart
Generic map(
	CLK_FREQ => 100,
	SER_FREQ => 20000000,
	PARITY_BIT => false
)
Port map (
	clk	=> clk,
	rst	=> reset,
	rx => rx,
	tx => tx,
	tx_req => d_write and not c_skip,
	tx_busy => uart_tx_busy,
	tx_data	=> writedata,
	rx_ready => uart_rx_ready,
	rx_data	=> readdata
);
           
end Behavioral;

