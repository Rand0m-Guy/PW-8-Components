library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."log2";
use IEEE.math_real."floor";

entity ArchReg is
    generic ( N : INTEGER := 8 ); -- N DEBE SER POTENCIA DE 2
    Port ( CLK : in STD_LOGIC;
           WE3 : in STD_LOGIC;
           -- Como sólo se usa al inicio de la declaración, sigue siendo sintetizable
           A1,A2,A3 : in STD_LOGIC_VECTOR (integer(floor(log2(real(N - 1)))) downto 0); -- Número de bits para direccionar N registros
           WD3 : in STD_LOGIC_VECTOR (N-1 downto 0);
           RD1,RD2 : out STD_LOGIC_VECTOR (N-1 downto 0));
end ArchReg;

architecture Comportamiento of ArchReg is

type MATRIZ is array (0 TO N-1) OF STD_LOGIC_VECTOR(N-1 downto 0);
signal REGISTROS: MATRIZ := (others => (others => '0')); -- Inicializamos archivo de registros en cero

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if WE3='1' and unsigned(A3) /= 0 then -- Escritura, ignorando registro 0
                REGISTROS(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if; 
    end process;
    
    -- Proceso de lectura asíncrono
    RD1 <= REGISTROS(to_integer(unsigned(A1)));
    RD2 <= REGISTROS(to_integer(unsigned(A2)));

end Comportamiento;
