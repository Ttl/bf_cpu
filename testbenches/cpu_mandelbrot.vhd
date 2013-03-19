-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.all;

ENTITY cpu_mandelbrot_tb IS
END cpu_mandelbrot_tb;

ARCHITECTURE behavior OF cpu_mandelbrot_tb IS 

signal clk, reset, tx, rx : std_logic;

-- Clock period definitions
constant clk_period : time := 10 ns;

signal uart_tx_req, uart_tx_end, uart_rx_ready : std_logic;
signal uart_tx_data, uart_rx_data : std_logic_vector(7 downto 0);

type testvectors is array(0 to 6191) of std_logic_vector(7 downto 0);

impure function init_mem(mif_file_name : in string) return testvectors is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(7 downto 0);
    variable temp_mem : testvectors;
begin
        for j in 0 to testvectors'length-1 loop
            readline(mif_file, mif_line);
            read(mif_line, temp_bv);
            temp_mem(j) := to_stdlogicvector(temp_bv);
        end loop;
    return temp_mem;
end function;

signal vectors : testvectors := init_mem("testbenches/mandelbrot.mif");

BEGIN
-- Component Instantiation
      uut: entity work.cpu
      Generic map ( INSTRUCTIONS => "scripts/mandelbrot.mif"
      )
      Port map(clk => clk,
               reset => reset,
               tx => rx,
               rx => tx
      );

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
        tx_data	=> uart_tx_data,
        rx_ready => uart_rx_ready,
        rx_data	=> uart_rx_data
    );

    -- Print received bytes
    uart_process : process
    begin
        wait until uart_rx_ready = '1';
        wait for clk_period;
        if to_integer(unsigned(uart_rx_data)) > 31 and to_integer(unsigned(uart_rx_data)) < 127 then
            report "Received ASCII: "&character'image(character'val(to_integer(unsigned(uart_rx_data))));
        else
            report "Received Dec: "&integer'image(to_integer(unsigned(uart_rx_data)));
        end if;
    end process;
    
    -- Test received bytes
    test_process : process
    begin
        for i in 0 to 6191 loop
            wait until uart_rx_ready = '1';
            wait for clk_period;
            assert uart_rx_data = vectors(i) report "Message "&integer'image(i)&" incorrect" severity note;
        end loop;
        wait until uart_rx_ready = '1';
        assert false report "Received too many messages" severity failure;
    end process;
    
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
   
--  Test Bench Statements
 tb : PROCESS
 BEGIN
    reset <= '1';
    uart_tx_req <= '0';
    wait for 100 ns; -- wait until global set/reset completes
    reset <= '0';
    
    wait; -- will wait forever
 END PROCESS tb;
--  End Test Bench 

END;
