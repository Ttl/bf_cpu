-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cpu_tb IS
END cpu_tb;

ARCHITECTURE behavior OF cpu_tb IS 

signal clk, reset, tx, rx : std_logic;

-- Clock period definitions
constant clk_period : time := 10 ns;
   
BEGIN
-- Component Instantiation
      uut: entity work.cpu
      Generic map ( INSTRUCTIONS => "scripts/instructions.mif"
      )
      Port map(clk => clk,
               reset => reset,
               tx => tx,
               rx => rx
      );

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
    tx <= '0';
    wait for 100 ns; -- wait until global set/reset completes
    reset <= '0';
    

    wait; -- will wait forever
 END PROCESS tb;
--  End Test Bench 

END;
