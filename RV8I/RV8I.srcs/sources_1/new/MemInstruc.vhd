----------------------------------------------------------------------------------------------------
-- @module: MemInstruc
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Memoria de Instrucción
-- @parameters:
            -- N (generic constant): Número de bits a direccionar en memoria
            -- INSTR_SIZE (generic constant): Número de bits de datos a guardar 
            -- A (in): Dirección de memoria en la que se lee un valor
            -- RD (out): Valor de memoria leído
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemInstruc is
    generic(
        N : integer := 8;
        INSTR_SIZE : integer := 16 
    );
    Port ( A : in STD_LOGIC_VECTOR (N-1 downto 0);
           RD : out STD_LOGIC_VECTOR (INSTR_SIZE-1 downto 0));
end MemInstruc;

architecture Behavioral of MemInstruc is

type MATRIZ is array (0 TO 2**N - 1) OF STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
-- FIBONACCI
constant MEM_INSTR : MATRIZ := (
    "0000000000010001",
    "0000000100100001",
    "0000001000110001",
    "0000110001000001",
    "0001000100010000",
    "0100100100000010",
    "0001000100100000",
    "0100101000000010",
    "0001001100110011",
    "0010001100100110",
    "0000010010000110",
    "0000000000000011",
    others => (others => '0')
);

-- CONTADOR
--constant MEM_INSTR : MATRIZ := (
--    "0000011100010001",
--    "0000000100100001",
--    "0001000100010000",
--    "0000000101010010",
--    "0000001010000110",
--    others => (others => '0')
--);

-- CHECADOR DE PARIDAD
--constant MEM_INSTR : MATRIZ := (
--    "0000000000010001",
--    "0000000100100001",
--    "0000000000110001",
--    "0000100110110100",
--    "0001001101000110",
--    "1111000000110001",
--    "0000101100100010",
--    "0000101010000110",
--    "0000111100110001",
--    "0000101100100010",
--    "0001000100010000",
--    "0000001010000110",
--    others => (others => '0')
--);

-- Operaciones de prueba
--constant MEM_INSTR : MATRIZ := (
--    "0000010100010001",
--    "0000100101100010",
--    "0000111010100001",
--    "0000101000100100",
--    "0000101010110000",
--    "1001001101000000",
--    "0000101100100010",
--    "0000110000110010",
--    others => (others => '0')
--);

-- PROGRAMA DE PRUEBA
--constant MEM_INSTR : MATRIZ := (
--    "0000000100010001",
--    "1000000100100001",
--    "0000000000110001",
--    "0000010001000001",
--    "0001000100010101",
--    "0001001010100101",
--    "0000000100000010",
--    "0000001000010010",
--    "0000001100100010",
--    "0000010000111000",
--    others => (others => '0')
--);

begin
    RD <= MEM_INSTR(to_integer(unsigned(A)));
end Behavioral;
