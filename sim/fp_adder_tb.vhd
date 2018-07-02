library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;
 
entity fp_adder_tb is
end fp_adder_tb;
 
architecture behavior of fp_adder_tb is 
	 
component fp_adder is
  port(A      : in  std_logic_vector(31 downto 0);
       B      : in  std_logic_vector(31 downto 0);
       clk    : in  std_logic;
       reset  : in  std_logic;
       start  : in  std_logic;
       done   : out std_logic;
       sum : out std_logic_vector(31 downto 0)
       );
end component;	 
	 
signal tb_Reset : std_logic := '0';
signal tb_Clock : std_logic := '0';
signal tb_start : std_logic := '0';
signal tb_A, tb_B : std_logic_vector(31 downto 0);
signal tb_done : std_logic := '0';
signal tb_sum : std_logic_vector(31 downto 0);

signal tb_fileSum : std_logic_vector(31 downto 0);


-- Clock period definitions
constant period : time := 10 ns;    

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: fp_adder 
		PORT MAP (
			A				=> tb_A,
			B				=> tb_B,
			reset			=> tb_Reset,
			clk				=> tb_Clock,
			start		=> tb_start,
			done		=> tb_done,

			sum	=> tb_sum
      );
		
  --  Test Bench Statements
	process is	
	begin
		tb_Clock <= '0';
		wait for period/2;
		tb_Clock <= '1';
		wait for period/2;
	end process;
	
	process is	
	begin
		tb_Reset <= '1';
		wait for 10*period;
		tb_Reset <= '0';
		wait;   
	end process;
		
	Checking: process is						
		file FIA: TEXT open READ_MODE is "a.txt";    
		file FIB: TEXT open READ_MODE is "b.txt";    
		file FIC: TEXT open READ_MODE is "sum.txt";  
		file FO: TEXT open WRITE_MODE is "summary.txt";  
		variable Line_A, Line_B, Line_C, L: LINE;
		variable v_OK: boolean;
		variable var_A, var_B, var_C : std_logic_vector(31 downto 0);
	begin
		tb_start <= '0';
		wait for 20*period;
		write(L, string'("EQUATION                  MATLAB    VHDL      Match"));		
        WRITELINE(FO, L);
		while not (ENDFILE(FIA) or ENDFILE(FIB) or  ENDFILE(FIC)) loop
			READLINE(FIA, Line_A);
			READLINE(FIB, Line_B);
			READLINE(FIC, Line_C);
			HREAD(Line_A, var_A);
			HREAD(Line_B, var_B);
			HREAD(Line_C, var_C);
			tb_A <= var_A;
            tb_B <= var_B;
            tb_fileSum <= var_C;
			tb_start <= '1';
			wait until rising_edge(tb_Clock);
			wait until rising_edge(tb_done);
			tb_start <= '0';
			if tb_fileSum = tb_sum then
				v_OK :=True;
			else
				v_OK :=False;
			end if;
            HWRITE(L, var_A, Left, 10);
            write(L, string'(" + "));
            HWRITE(L, Var_B, Left, 10);
            write(L, string'(" = "));
			HWRITE(L, tb_sum, Left, 10);
			HWRITE(L, tb_fileSum, Left, 10);
			WRITE(L, v_OK, Left, 10);			
			WRITELINE(FO, L);
			wait until falling_edge(tb_done);
		end loop;
		wait;
	end process;
	
end;
