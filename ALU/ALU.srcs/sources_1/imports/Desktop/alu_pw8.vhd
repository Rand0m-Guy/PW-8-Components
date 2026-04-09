----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.04.2026 20:12:11
-- Design Name: 
-- Module Name: alu_pw8 - alu
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_pw8 is
    generic ( N : INTEGER:=8 );
    Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
           B : in STD_LOGIC_VECTOR (N-1 downto 0);
           ALU_ctrl : in STD_LOGIC_VECTOR (2 downto 0);
           zero : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR (N-1 downto 0));
end alu_pw8;

architecture alu of alu_pw8 is
signal res: std_logic_vector(N-1 downto 0);
begin
    process(A, B, ALU_ctrl)
    begin
        case ALU_ctrl is
            when "000" => res <= std_logic_vector(signed(A) + signed(B));
            when "001" => res <= std_logic_vector(signed(A) - signed(B));
            when "010" => res <= A XOR B;
            when "011" => res <= A AND B;
            when "100" => 
                if signed(A) < signed(B) then
                    res <= std_logic_vector(TO_UNSIGNED(1, N));
                else 
                    res <= (others => '0');
                end if;
            when "101" => res <= std_logic_vector(shift_left(unsigned(A), TO_INTEGER(unsigned(B))));
            when "110" => res <= std_logic_vector(shift_right(unsigned(A), TO_INTEGER(unsigned(B))));
            when others => res <= (others => '0');
       end case;
    end process;
    AluRES <= res;
    Zero   <= '1' when res = std_logic_vector(to_unsigned(0, N)) else '0';
end alu;
