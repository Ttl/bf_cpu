LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.all;

ENTITY cpu_rot13_tb IS
END cpu_rot13_tb;

ARCHITECTURE behavior OF cpu_rot13_tb IS 

signal clk, reset, tx, rx : std_logic;

-- Clock period definitions
constant clk_period : time := 10 ns;

signal uart_tx_req, uart_tx_end, uart_rx_ready : std_logic;
signal uart_tx_data, uart_rx_data : std_logic_vector(7 downto 0);
BEGIN
-- Component Instantiation
      uut: entity work.cpu
      Generic map ( INSTRUCTIONS => "scripts/rot13.mif"
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
        wait until uart_rx_ready = '1';
        wait for clk_period;
        assert uart_rx_data = x"4E" report "First msg incorrect" severity failure;
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

-- Send character
    uart_tx_req <= '1';
    uart_tx_data <= x"41"; -- A
    wait for clk_period;
    uart_tx_req <= '0';
    wait until uart_tx_end = '1';
    wait for 1999us;
    assert uart_rx_data /= x"4E" report "Completed succesfully" severity failure;
    assert false report "Invalid rx_data" severity failure;
    
    wait; -- will wait forever
 END PROCESS tb;
--  End Test Bench 

END;
