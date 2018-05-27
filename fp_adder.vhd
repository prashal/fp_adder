library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity fp_adder is
  port(A      : in  std_logic_vector(31 downto 0);
       B      : in  std_logic_vector(31 downto 0);
       clk    : in  std_logic;
       reset  : in  std_logic;
       start  : in  std_logic;
       done   : out std_logic;
       sum : out std_logic_vector(31 downto 0)
       );
end fp_adder;

architecture mixed of fp_adder is
  type ST is (WAIT_STATE, ALIGN_STATE, ADDITION_STATE, NORMALIZE_STATE, OUTPUT_STATE);
  signal state : ST := WAIT_STATE;

  ---Internal Signals latched from the inputs
  signal A_mantissa, B_mantissa : std_logic_vector (24 downto 0);
  signal A_exp, B_exp           : std_logic_vector (8 downto 0);
  signal A_sgn, B_sgn           : std_logic;
  
  --Internal signals for Output   
  signal sum_exp: std_logic_vector (8 downto 0);
  signal sum_mantissa           : std_logic_vector (24 downto 0);
  signal sum_sgn           : std_logic;

begin
  
  Control_Unit : process (clk, reset) is
    variable diff : signed(8 downto 0);
  begin
    if(reset = '1') then
      state <= WAIT_STATE;                 --start in wait state
      done    <= '0';
    elsif rising_edge(clk) then
      case state is
        when WAIT_STATE =>
          if (start = '1') then            --wait till start request startes high
            A_sgn      <= A(31);
            A_exp      <= '0' & A(30 downto 23);	--One bit is added for signed subtraction
            A_mantissa <= "01" & A(22 downto 0);	--Two bits are added extra, one for leading 1 and other one for storing carry
            B_sgn      <= B(31);
            B_exp      <= '0' & B(30 downto 23);	
            B_mantissa <= "01" & B(22 downto 0);
            state    <= ALIGN_STATE;
          else
            state <= WAIT_STATE;    
          end if;
        when ALIGN_STATE =>  --Compare exponent and align it
          --If any num is greater by 2**24, we skip the addition.
          if unsigned(A_exp) > unsigned(B_exp) then
			--B needs downshifting
            diff := signed(A_exp) - signed(B_exp);  --Small Alu
            if diff > 23 then
              sum_mantissa <= A_mantissa;  --B insignificant relative to A
			  sum_exp <= A_exp;
              sum_sgn      <= A_sgn;
              state      <= OUTPUT_STATE;   --start latch A as output
            else       
			  --downshift B to equilabrate B_exp to A_exp
			  sum_exp <= A_exp;
              B_mantissa(24-to_integer(diff) downto 0)  <= B_mantissa(24 downto to_integer(diff));
              B_mantissa(24 downto 25-to_integer(diff)) <= (others => '0');
              state                                   <= ADDITION_STATE;
            end if;
          elsif unsigned(A_exp) < unsigned(B_exp)  then   --A_exp < B_exp. A needs downshifting
            diff := signed(B_exp) - signed(A_exp);  -- Small Alu
            if diff > 23 then
              sum_mantissa <= B_mantissa;  --A insignificant relative to B
              sum_sgn      <= B_sgn;
              sum_exp      <= B_exp; 
              state      <= OUTPUT_STATE;   --start latch B as output
            else       
			  --downshift A to equilabrate A_exp to B_exp
              sum_exp <= B_exp;
              A_mantissa(24-to_integer(diff) downto 0)  <= A_mantissa(24 downto to_integer(diff));
              A_mantissa(24 downto 25-to_integer(diff)) <= (others => '0');
              state                                   <= ADDITION_STATE;
            end if;
		  else				-- Both exponent is equal. No need to mantissa shift
		    sum_exp <= A_exp;
            state <= ADDITION_STATE;          
          end if;
        when ADDITION_STATE =>                    --Mantissa addition
          state <= NORMALIZE_STATE;
          if (A_sgn xor B_sgn) = '0' then  --signs are the same. Just add them
            sum_mantissa <= std_logic_vector((unsigned(A_mantissa) + unsigned(B_mantissa)));	--Big Alu
            sum_sgn      <= A_sgn;      --both nums have same sign
          --Else subtract smaller from larger and use sign of larger
          elsif unsigned(A_mantissa) >= unsigned(B_mantissa) then
            sum_mantissa <= std_logic_vector((unsigned(A_mantissa) - unsigned(B_mantissa)));	--Big Alu
            sum_sgn      <= A_sgn;
          else
            sum_mantissa <= std_logic_vector((unsigned(B_mantissa) - unsigned(A_mantissa)));	--Big Alu
            sum_sgn      <= B_sgn;
          end if;

        when NORMALIZE_STATE =>  --Normalization. 
          if unsigned(sum_mantissa) = TO_UNSIGNED(0, 25) then
			--The sum is 0
            sum_mantissa <= (others => '0');  
            sum_exp        <= (others => '0');
            state      <= OUTPUT_STATE;  
          elsif(sum_mantissa(24) = '1') then  --If sum overflowed we downshift and are done.
            sum_mantissa <= '0' & sum_mantissa(24 downto 1);  --shift the 1 down
            sum_exp        <= std_logic_vector((unsigned(sum_exp)+ 1));
            state      <= OUTPUT_STATE;
          elsif(sum_mantissa(23) = '0') then  --in this case we need to upshift
			  --This iterates the normalization shifts, thus can take many clocks.
			  sum_mantissa <= sum_mantissa(23 downto 0) & '0';	
			  sum_exp <= std_logic_vector((unsigned(sum_exp)-1));
			  state<= NORMALIZE_STATE; --keep shifting till  leading 1 appears
          else
            state <= OUTPUT_STATE;  --leading 1 already there. Latch output
          end if;
        when OUTPUT_STATE =>
          sum(22 downto 0)  <= sum_mantissa(22 downto 0);
          sum(30 downto 23) <= sum_exp(7 downto 0);
          sum(31) <= sum_sgn;
          done              <= '1';     -- signal done
          if (start = '0') then         -- stay in the state till request ends i.e start is low
            done    <= '0';
            state <= WAIT_STATE;
          end if;
        when others => 
			state <= WAIT_STATE;      --Just in case.
      end case;
    end if;
  end process;

end mixed;