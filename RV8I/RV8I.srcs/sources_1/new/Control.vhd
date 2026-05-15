----------------------------------------------------------------------------------------------------
-- @module: Control
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Unidad de Control del procesador: Indica qué señales mandar a cada compoenente dependiendo de la instrucción recibida
-- @parameters:
            -- NON_R_INSTR (generic constant): Número de instrucciones que no sean de tipo R
            -- R_INSTR (generic constant): Número de instrucciones de tipo R
            -- SIGNAL_SIZE (generic constant): Número de señales a generar
            -- CLK (in): Señal de reloj
            -- Opcode (in): Código de operación de la instrucción
            -- Funct1, Funct2 (in): Códigos de función de la instrucción (ver formato de instrucción)
            -- Zero (in): Señal que indica si el resultado de la ALU es 0
            -- RegWrite (out): Indica si se debe escribir a registro (1) o no (0)
            -- WriteSel (out): Indica fuente de dato a escribir a registro (ver tabla en manual de usuario)
            -- PCCLR (out): Señal para limpiar el PC
            -- PCLD (out): Indica si se debe cargar al PC
            -- ResultSrc (out): Indica desde dónde hay loopback al Archivo de Registros (ver tabla en manual de usuario)
            -- MemWrite (out): Write Enable de Memoria de Datos
            -- ALUSrc (out): Indica si la fuente de la ALU es un registro (0) o el extensor de signo (1)
            -- ALUCtrl (out): Indica operación a realizar en la ALU (ver tabla en manual de usuario)
            -- ImmSrc (out): Indica cómo el Extensor de signo debe leer el valor de entrada (ver tabla en manual de usuario)
            -- PCSrc (out): Indica fuente de ingreso a PC (ver tabla en manual de usuario)
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control is
    generic(
        NON_R_INSTR : integer := 32;
        R_INSTR : integer := 7;
        SIGNAL_SIZE : integer := 15
    );
    Port ( CLK : in STD_LOGIC;
           Opcode : in STD_LOGIC_VECTOR (3 downto 0);
           Funct1 : in STD_LOGIC;
           Funct2 : in STD_LOGIC_VECTOR (1 downto 0);
           Zero : in STD_LOGIC;
           RegWrite, WriteSel, PCCLR, PCLD, ResultSrc,MemWrite,ALUSrc : out STD_LOGIC;
           ALUCtrl,ImmSrc : out STD_LOGIC_VECTOR (2 downto 0);
           PCSrc : out STD_LOGIC_VECTOR (1 downto 0));
end Control;

architecture Behavioral of Control is

-- ORDEN DE BITS: REGWRITE, WRITESEL, PCCLR, PCLD, PCSRC (2), RESULTSRC, MEMWRITE, ALUCTRL (3), ALUSRC, IMMSRC (3)

type MATRIZ_OP is array (0 TO NON_R_INSTR - 1) OF STD_LOGIC_VECTOR(SIGNAL_SIZE-1 downto 0);
constant MICROCODE_OP : MATRIZ_OP := (
    1 =>  "100100001111111", -- LI
    2 =>  "000100010000110", -- ST
    3 =>  "100100000001100", -- ADDI
    4 =>  "100100000101100", -- XORI
    5 =>  "100100001011000", -- SLLI
    6 =>  "000100000100101", -- BEQ: PCSrc indica usar siguiente instrucción por defecto. La corrección se hace en flanco de bajada
    7 =>  "100100001001100", -- SLTI
    8 =>  "110110000001100", -- JALR
    17 => "100100100000111", -- LD
    19 => "100100000011100", -- SUBI
    20 => "100100000111100", -- ANDI
    21 => "100100001101000", -- SRLI
    22 => "110110001111011", -- JAL
    others => (others => '0')
);

type MATRIZ_FUNCT is array (0 TO R_INSTR - 1) OF STD_LOGIC_VECTOR(SIGNAL_SIZE-1 downto 0);
constant MICROCODE_FUNCT : MATRIZ_FUNCT := (
    0 => "100100000000000", -- ADD
    1 => "100100000010000", -- SUB
    2 => "100100000100000", -- XOR
    3 => "100100000110000", -- AND
    4 => "100100001000000", -- SLT
    5 => "100100001010000", -- SLL
    6 => "100100001100000", -- SRL
    others => (others => '0')
);

begin
    
    RegWrite    <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 1) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 1);
    WriteSel    <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 2) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 2);
    PCCLR       <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 3) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 3);
    PCLD        <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 4) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 4);
    PCSRC       <= "01" when ((Funct1 & Opcode) = "00110" and Zero = '1') else
                   MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 5 downto SIGNAL_SIZE - 6) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 5 downto SIGNAL_SIZE - 6);
    ResultSrc   <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 7) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 7);
    MemWrite    <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 8) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 8);
    ALUCtrl     <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 9 downto SIGNAL_SIZE - 11) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 9 downto SIGNAL_SIZE - 11);
    ALUSrc      <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 12) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 12);
    ImmSrc      <= MICROCODE_FUNCT(to_integer(unsigned(Funct2 & Funct1)))(SIGNAL_SIZE - 13 downto SIGNAL_SIZE - 15) when opcode = "0000" else
                   MICROCODE_OP   (to_integer(unsigned(Funct1 & Opcode)))(SIGNAL_SIZE - 13 downto SIGNAL_SIZE - 15);
    
end Behavioral;
