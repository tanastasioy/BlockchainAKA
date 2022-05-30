-- Entity name: modular_exponentiation
-- Author: Luis Gallet
-- Contact: luis.galletzambrano@mail.mcgill.ca
-- Date: March 8th, 2016
-- Description: Module responsible of performing encryption and decryption. It uses the
-- montgomery_multiplier.vhd to perform multiplication and modulo operations.

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity modular_exponentiation is

	generic(WIDTH_IN : integer := 128
	);
	port(	N :	  in unsigned(WIDTH_IN-1 downto 0); --Number
		Exp :	  in unsigned(WIDTH_IN-1 downto 0); --Exponent
		M :	  in unsigned(WIDTH_IN-1 downto 0); --Modulus
		enc_dec:  in std_logic;
		clk :	  in std_logic;
		reset :	  in std_logic;
		C : 	  out unsigned(WIDTH_IN-1 downto 0) --Output
	);
end entity;

architecture behavior of modular_exponentiation is 

constant zero : unsigned(WIDTH_IN-1 downto 0) := (others => '0');

constant K : unsigned(WIDTH_IN-1 downto 0) := "00000111101101000101100111100010110001011000100100100000100010010110010001011000000100111101010010101101100110010001101000110100";

--------------------------------------1024 bit constants-----------------------------------------------
--constant K : unsigned (WIDTH_IN-1 downto 0) := "0000001010100000001100001010001010110100011100011001101100010001000001111100111000001001000001001011010111111101001000111100111101010100011110110111110101101000100010000110011110010110101000011011000111111000010000101101110001010001111010011000001110011111100011110000010110100101010000110101000100011110101100110010001011100100001000001011111011101000011010110000000010001101001011100101000110111001110110100010101101110111000000110110011110101011110010100001011000111111111101000110000100100000110101001000001001110110101100100010011100001110111001111100010110110011010011001011000000111011101101100100001000001101001100100110110101111111001111101111010100100111010101111010001000010110000110111101110000010011110101100111111110010001010000101000111110101010001000011101100110100011010010001011000001110110111110110100101001011000010111001110010000001001000010001100110000101110111101100100111000110110001000100011111111011010001100110011101101100100000001110000000001000000001010101101010010001010010101000111000000111111"; --change to std_logic_vector
--constant M : unsigned (WIDTH_IN-1 downto 0) :="1000000110011101010001101100011101100110101011011110001011111011011111001101001101011000110011111000011111000101010011110010010111001100011011111011000011111101111000000011000101110101010000000111111111101000000100001100101101111111101011101100110110010000011001000100001001011011001010010001101010001101011000010110101010000010101001011000111111110000010101000101001111100010001110010100011111011010101000011100011110110111111000001100001011111010001001110001100010000010010110010001100110110110101000010010100111011111000000010011111101011100000111000111010001010111010010111001000000001101010110001101010101110001100010100001101111111010011100001010110011010001000110001101111110000111000100111101000000110011000001011000000110110110000000110110011011101111000111000101010101111110011110100001110111011101011001111000000000011101000000000100001011100001101011011011010110110111111001101100010010000000001011101101011100111000010110000101111010100010110001111011001001100110001110000010111011000010011001101011010100010001";
--constant enc_Exp : unsigned (WIDTH_IN-1 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001";
--constant dec_Exp : unsigned (WIDTH_IN-1 downto 0) := "0111001011101000111100101011010100011001100011010001001111101101000011011110111101111001100011110001001110111001100100111011111111011001000011010011010010000110111111110101101000011001101011111000001100110110010001001001110110000101101001110111110111001011100000110111011101101000110001100111101000101001110110011011000111001001111111011110101000101100100100010011011010000101000110110110111101011110100111111000101100100110101100111111011101101000001110110111110011111001001000100101010101000001111001001001011100101101110011010100000111110101010001000111101101101100000110011001010100101100000100010100110110000101100000111101100100011011011010101111111110000010110110101101110111010000110000001110101100110011010000000001111100110110100101010111111111111011110101011011001101000000111111010010101001100101000010001011101000001111110111110111010101010000100001001011011101101000010100101001111001000100100010001110111111101011111101100000001100110111110111000100100001011101111011001111110101101111011000110100111010011001";
-------------------------------------------------------------------------------------------------------

-------------------------------------512 bit constants------------------------------------------------
--constant K : unsigned (WIDTH_IN-1 downto 0) := "01000001000100010101100011101011101101011111101101111100001011010111110011010011000111000011011001011101011110011110101110110010011100011010111001110111101110000010100001001011101100000001010010010001010100010110010000111000011111111100000000011000111011010000100010000010110010001000010000001101110010010001001001100110100100110000010010000101011101111110000111001010111001000001110110100110000000100000110001000001011000111001010111111101010111111100011100100000100010100100010000110000011110101000010101111011";
--constant M : unsigned (WIDTH_IN-1 downto 0) := "10000011010000010011110100010110101100001100010010011111110101011001010111110100011000111101001110110100010101111110010110101001010000100101110110110011010111100111100001101010111001100011010001001001100001011011110101100000110011101001110010101101000100000011000100000111010000000001010000100101001011111111101010110100110011101100011000111011110100110001111010000101100000101010111110111001101100111110001001000111011101101110000111100100011010111000000011110110010110111000101111000111100100000000000001011011";
--constant enc_Exp : unsigned(WIDTH_IN-1 downto 0) := "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001";
--constant dec_Exp : unsigned(WIDTH_IN-1 downto 0) := "00100001111011111100111101001100101110111001110111001011001110011101110101010000110110000011001011010111110100010101011000110111010000100100101010011001111000110001011000111101100001011001001000000101011001001000100000000111101011001100010000010110100100011111010101111100011101111001100011001001101001100111111011101011010110110111011110011010011000100011100111100000111001001101001111011111100011101010000010011111010111101011101101010111001100100111000111011111101101011110010011001000111011000111111110001001";
-------------------------------------------------------------------------------------------------------

------------------------------------256 bit constants------------------------------------------------
--constant K : unsigned (WIDTH_IN-1 downto 0) := "0000101101110010100110101100001100101001101001111100011111101000011000101001011001001110110101000001110010010010110001100111001111100100010101001011111110111011111000111100011011101001010001101001011000100000011101110000101101010010100110001110010001001100";
--constant M : unsigned (WIDTH_IN-1 downto 0) := "1001010000001011000100100011011110000011010001100011101100010101010001101101100111111101101100110101101111101011000010101101111101001001011010101011110111000100100101000011101110001111010010000110101011011000011111010110111001010111001101100011101010000011";
--constant dec_Exp : unsigned(WIDTH_IN-1 downto 0) := "0011001000110111010001110010100010011001010110001011101100110101110011100110000010100111000100111010110110111100000111100001111101010111110101000010000111110110111111011101010001100011111000011111101111000110100110110101111111110010100000111111100100100001";
--constant enc_Exp : unsigned(WIDTH_IN-1 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001";
-------------------------------------------------------------------------------------------------------

--------------------------------------128 bit constants------------------------------------------------
--constant K : unsigned (WIDTH_IN-1 downto 0) := "00000110010001101110000100100000101111011101110010111101100011001010101111001011011010101000010100001011000100011101101000011110";
--constant M : unsigned (WIDTH_IN-1 downto 0) := "00000111101101000101100111100010110001011000100100100000100010010110010001011000000100111101010010101101100110010001101000110100";
constant dec_Exp : unsigned(WIDTH_IN-1 downto 0) := "01000010101011001010100010001100110110111100011011011001100101010000100001101100011101011101010010101111100011111011111101000001";
constant enc_Exp : unsigned(WIDTH_IN-1 downto 0) := "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000001";
-------------------------------------------------------------------------------------------------------

--------------------------------------32 bit constants------------------------------------------------
--constant K : unsigned (WIDTH_IN-1 downto 0) :=      "00000110010001101110000100100000";
--constant M : unsigned (WIDTH_IN-1 downto 0) :=    "10000100010001111000010010000101";
--constant dec_Exp : unsigned(WIDTH_IN-1 downto 0) := "00101010110001011001000101000101";
--constant enc_Exp : unsigned(WIDTH_IN-1 downto 0) := "00000000000000010000000000000001";
-------------------------------------------------------------------------------------------------------


-- Intermidiate signals
signal temp_A1,temp_A2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal temp_B1, temp_B2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal temp_d_ready, temp_d_ready2 : std_logic := '0';
signal temp_M1, temp_M2 : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');

signal latch_in, latch_in2 : std_logic := '0';

signal temp_M : unsigned(WIDTH_IN-1 downto 0) := (WIDTH_IN-1 downto 0 => '0');
signal temp_C : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');

-- FSM states
type STATE_TYPE is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
signal state: STATE_TYPE := s0;


component montgomery_multiplier
Generic(WIDTH_IN : integer := 8
	);
	Port(	A :	in unsigned(WIDTH_IN-1 downto 0);
		B :	in unsigned(WIDTH_IN-1 downto 0);
		N :	in unsigned(WIDTH_IN-1 downto 0);
		latch : in std_logic;
		clk :	in std_logic;
		reset :	in std_logic;
		data_ready : out std_logic;
		M : 	out unsigned(WIDTH_IN-1 downto 0)
	);
end component;

begin

-- Montgomery Multiplier components

mont_mult_1: montgomery_multiplier
	generic map(WIDTH_IN => WIDTH_IN)
	port map(
		A => temp_A1, 
		B => temp_B1, 
		N => temp_M,
		latch => latch_in, 
		clk => clk, 
		reset => reset,
		data_ready => temp_d_ready, 
		M => temp_M1 
		);

mont_mult_2: montgomery_multiplier
	generic map(WIDTH_IN => WIDTH_IN)
	port map(
		A => temp_A2, 
		B => temp_B2, 
		N => temp_M, 
		latch => latch_in2, 
		clk => clk, 
		reset => reset,
		data_ready => temp_d_ready2,  
		M => temp_M2 
		);


C <= temp_C;

sqr_mult : Process(clk, reset, N)

variable count : integer := 0;
variable shift_count : integer := 0;
variable temp_N : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
variable P : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
variable P_old : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
variable R : unsigned(WIDTH_IN-1 downto 0):= (WIDTH_IN-1 downto 0 => '0');
variable temp_Exp : unsigned(WIDTH_IN-1 downto 0);
variable temp_mod : unsigned(WIDTH_IN-1 downto 0);

begin

if reset = '1' then
	count := 0;
	shift_count := 0;
	temp_N := (others => '0');
	P := (others => '0');
	R := (others => '0');
	temp_Exp := (others => '0');
	temp_mod := (others => '0');	
	temp_M <= (others => '0');

	state <= s0;
	
elsif rising_edge(clk) then

case state is 
	
	-- Check if there are new inputs available 
	when s0 =>
	--(M = zero) OR (Exp = zero) OR
	if((N = zero)) OR ((temp_M = M)  AND (temp_N = N)) then
		state <= s0;
	else
		
		temp_mod := M;
		state <= s1;
	end if;

	-- If MSB of modulus is not 1 then shift it left until a 1 is found and count how many times it was shifted
	when s1 =>
	
	if(temp_mod(WIDTH_IN-1) = '1')then			
		
		if(enc_dec = '1')then
			temp_Exp := enc_Exp;
		else
			temp_Exp := dec_Exp;
		end if;
		--temp_Exp := Exp;
		temp_M <= M;
		temp_N := N;
		state <= s2;
	else
		temp_mod := (shift_left(temp_mod,natural(1)));
		shift_count := shift_count + 1;
		state <= s1;
	end if;

	-- Compute initial value of P and R	
	when s2 => 
	
	if(unsigned(K) > zero)then
		temp_A1 <= unsigned(K);
		temp_B1 <= temp_N;
	
		temp_A2 <= unsigned(K);
		temp_B2 <= to_unsigned(1,WIDTH_IN);	
	
		latch_in <= '1';
		latch_in2 <= '1';
		
		if(temp_d_ready = '0') AND (temp_d_ready2 = '0')then
			state <= s3;
		end if;
	else
		state <= s2;
	end if;

	-- Assign the results of the computations
	when s3 =>
	latch_in <= '0';
	latch_in2 <= '0';
	
	if((temp_d_ready = '1') AND (temp_d_ready2 = '1')) then
		P_old := temp_M1;
		R := temp_M2;
		state <= s4;
	end if; 

	-- Check Listing 1 in report. This operation is inside the for loop and it is always performed
	when s4 =>
		temp_A1 <= P_old;
		temp_B1 <= P_old;
		latch_in <= '1';

		if(temp_d_ready = '0')then
			state <= s5;
		end if;

	-- If LSB of the exponent is 1 then compute R, else go to state 8
	when s5 =>
	latch_in <= '0';
	
	if(temp_d_ready = '1')then
		P := temp_M1;
		if(temp_Exp(0) = '1')then
			state <= s6;
		else
			state <= s8;
		end if;
	end if;

	when s6 => 
		temp_A2 <= R;
		temp_B2 <= P_old;
		latch_in2 <= '1';

		if(temp_d_ready2 = '0')then
			state <= s7;
		end if;
		
	when s7 =>
		latch_in2 <= '0';
		if(temp_d_ready2 = '1') then
			R := temp_M2;
			state <= s8;
		end if;
	
	-- If the statement is true, it means that we have checked all bits in the exponent or exponent is zero and we compute the output
	when s8 =>
		if (count = (WIDTH_IN-1)-shift_count) OR (temp_Exp = zero) then
			temp_A1 <= to_unsigned(1,WIDTH_IN);
			temp_B1 <= R;			
			state <= s9;
			
		else    -- if the statement is false, then we shift the exponent right and increment count
			temp_Exp := (shift_right(temp_Exp, natural(1)));
			P_old := P;
			count := count + 1;
			state <= s4;
		end if;	
	
	when s9 =>
		
		latch_in <= '1';
		if(temp_d_ready ='0')then
			state <= s10;
		end if;

	when s10 =>
		latch_in <= '0';
		if(temp_d_ready = '1') then
			temp_C <= temp_M1;
			temp_Exp := (others => '0');
			count := 0;
			shift_count := 0;
			P := (others => '0');
			R := (others => '0');
			temp_mod := (others => '0');			
			
			state <= s0;
		end if;
		
	end case;
end if;		

end process sqr_mult;
 
end behavior;  