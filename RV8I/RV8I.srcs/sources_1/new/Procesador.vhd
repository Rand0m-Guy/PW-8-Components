----------------------------------------------------------------------------------------------------
-- @module: Procesador
-- @authors: Macias Huerta Pablo Isaac, Pérez Bárcenas Juan Rubén
-- @description: Módulo que conecta e incorpora todos los componentes individuales del procesador
-- @parameters:
            -- OSC_CLK (in): Señal de reloj que proviene del oscilador de la tarjeta
            -- CLR (in):     Hace reset a la memoria de instrucción
            -- A (inout):    Dirección de memoria de datos en la que se guarda/lee un valor
            -- WD (inout):   Valor a guardar en la memoria de datos
----------------------------------------------------------------------------------------------------

library IEEE;
library WORK;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.Paquete.ALL;

entity Procesador is
    generic (
        N : INTEGER := 8;
        INSTR_SIZE : INTEGER := 16;
        Imm_Slice : INTEGER := 12
     ); 
    Port ( OSC_CLK, CLR : in STD_LOGIC;
           A, WD : inout STD_LOGIC_VECTOR (N-1 downto 0)
           --PC_OUT_TEST : out STD_LOGIC_VECTOR (N-1 downto 0);
           --MICRO_INSTR_TEST: out STD_LOGIC_VECTOR (14 downto 0);
           --INSTR_TEST : out STD_LOGIC_VECTOR (15 downto 0);
           --RD1_TEST, RD2_TEST : out std_logic_vector (7 downto 0);
           --A1_TEST, A2_TEST, A3_TEST : out std_logic_vector (2 downto 0);
           --WD3_TEST : out std_logic_vector (7 downto 0)
           );
end Procesador;

architecture Behavioral of Procesador is
    signal CLK : STD_LOGIC;
    signal Instr : STD_LOGIC_VECTOR(INSTR_SIZE-1 downto 0);
    
    signal RD1, RD2 : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal ImmExt : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal DataMem_Out : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal PC_Out : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal ALURes : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal PCPlus : STD_LOGIC_VECTOR(N-1 downto 0);
    signal PCTarget : STD_LOGIC_VECTOR(N-1 downto 0);
    
    -- Señales de Unidad de Control
    signal RegWrite, WriteSel, PCCLR, PCLD, ResultSrc,MemWrite,ALUSrc,Zero : STD_LOGIC := '0';
    signal PCSrc : STD_LOGIC_VECTOR (1 downto 0);
    signal ALUCtrl,ImmSrc : STD_LOGIC_VECTOR (2 downto 0);
    
    -- Señales de MUX
    signal muxToWD3 : STD_LOGIC_VECTOR(N-1 downto 0);
    signal muxToPCNext : STD_LOGIC_VECTOR(N-1 downto 0);
    signal muxToAlu : STD_LOGIC_VECTOR(N-1 downto 0);
    signal response : STD_LOGIC_VECTOR(N-1 downto 0);
    
    -- PCCLR push button
    signal trashSignal : STD_LOGIC;
begin
    
    process(CLK, CLR) begin
        if(rising_edge(CLK)) then
            PCCLR <= CLR;
        end if;
    end process;
    
    -- TEST
    --PC_OUT_TEST <= PC_Out;
    --MICRO_INSTR_TEST <= RegWrite & WriteSel & PCCLR & PCLD & PCSrc & ResultSrc & MemWrite & ALUCtrl & ALUSrc & ImmSrc;
    --INSTR_TEST <= Instr;
    --RD1_TEST <= RD1;
    --RD2_TEST <= RD2;
    --WD3_TEST <= muxToWD3;
    --A1_TEST  <= Instr(10 downto 8);
    --A2_TEST  <= Instr(13 downto 11);
    --A3_TEST  <= Instr(6 downto 4);
    
    
    A <= ImmExt;
    WD <= RD1;
    
    PCPlus <= std_logic_vector(unsigned(PC_Out) + 1);
    PCTarget <= std_logic_vector(signed(PC_Out) + signed(ImmExt));
    
    muxToWD3 <= response WHEN WriteSel = '0' ELSE PCPlus;
    
    muxToPCNext <= PCPlus WHEN PCSrc = "00" ELSE
             PCTarget When PCSrc = "01" ELSE
             ALURes when PCSrc = "10" ELSE (others => '0');
    
    muxToAlu <= RD2 when ALUSrc = '0' else ImmExt;
    
    response <= ALURes when ResultSrc = '0' else DataMem_Out;
    
    DivFrecuencia : Divisor PORT MAP (
        OSC_CLK => OSC_CLK,
        CLR => CLR,
        CLK => CLK
    );
    
    ArchivoRegistros : ArchReg PORT MAP (
        CLK => CLK,
        WE3 => RegWrite,
        A1  => Instr(10 downto 8), 
        A2  => Instr(13 downto 11),
        A3  => Instr(6 downto 4),
        WD3 => muxToWD3,
        RD1 => RD1,
        RD2 => RD2
    );
    
    UnidadControl : Control PORT MAP(
        CLK       => CLK,
        Opcode    => Instr(3 downto 0),
        Funct1    => Instr(7),
        Funct2    => Instr(15 downto 14),
        Zero      => Zero,
        RegWrite  => RegWrite,
        WriteSel  => WriteSel,
        PCCLR     => trashSignal,
        PCLD      => PCLD,
        ResultSrc => ResultSrc,
        MemWrite  => MemWrite,
        ALUSrc    => ALUSrc,
        ALUCtrl   => ALUCtrl,
        ImmSrc    => ImmSrc,
        PCSrc     => PCSrc
    );
    
    ExtensorSigno : Extensor PORT MAP(
        imm    => Instr(15 downto 4),
        immSrc => ImmSrc,
        immExt => ImmExt
    );
    
    MemoriaDatos : MemDatos PORT MAP(
        CLK => CLK,
        WE  => MemWrite,
        A   => ImmExt,
        WD  => RD1,
        RD  => DataMem_Out
    );
    
    MemoriaInstruccion : MemInstruc PORT MAP(
        A  => PC_Out,
        RD => Instr
    );
    
    PC : PC_pw8 PORT MAP(
        PCNext => muxToPCNext,
        LD     => PCLD,
        CLR    => PCCLR,
        CLK    => CLK,
        PC_out => PC_Out
    );
    
    ALU : alu_pw8 PORT MAP(
        A        => RD1,
        B        => muxToAlu,
        ALU_ctrl => ALUCtrl,
        zero     => Zero,
        ALURes   => ALURes
    );
end Behavioral;