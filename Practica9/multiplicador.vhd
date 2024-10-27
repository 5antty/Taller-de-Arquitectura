entity mul4 is
	port(A:Bit_vector(3 downto 0); B:Bit_vector(3 downto 0); STB: in Bit; CLK: in Bit; DoneM: out Bit; Res: out Bit_vector(7 downto 0));
end mul4;

architecture struct of mul4 is

	-- Declaro el registro acumulador
	component Latch8
		port(D: in Bit_Vector(7 downto 0); CLK: in Bit; Pre: in Bit; Clr: in Bit; Q: out Bit_Vector(7 downto 0)); 
	end component;		   
	--Señal donde se guarda lo acumulado
	Signal ACC: Bit_vector(7 downto 0);	
	Signal Pre: Bit;
	
	--Declaro el sumador de 8 bits
	component Adder8
		port(A, B: in Bit_vector; Cin: in Bit; Cout: out Bit; Sum: out Bit_vector); 
		--port(QB, ACC
	end component;	  			  
	--Señales del sumador
	Signal Sum: Bit_vector(7 downto 0);
	Signal Cin, Cout: Bit := '0';	   
	
	--Declaro componente Shifter
	component ShiftN
		port (CLK: in Bit; 
        CLR: in Bit; 
        LD: in Bit; 
        SH: in Bit; 
        DIR: in Bit; 
		D: in Bit_Vector; 
		Q: out Bit_Vector);	 
	end component;	 
	--Señales de los shifter
	signal SH: Bit;
	Signal QA: Bit_vector(7 downto 0);
	Signal QB: Bit_vector(7 downto 0);
	
	--Declaro FSM 
	component Controller	
		port (STB, CLK, LSB, Stop: in  Bit; Init, Shift, Add, Done: out  Bit);
	end component; 
	
	--Señales de FSM
	Signal Init, Stop, Add, Done: Bit;	   

begin	  
	--Mapeo de señales
	SHA: ShiftN port map (CLK, '0', Init, SH, '0', A, QA);  
	SHB: ShiftN port map (CLK, '0', Init, SH, '1', B, QB);	
	L8: Latch8 port map (Sum, CLK, Pre, Init, ACC);
	ADD8: Adder8 port map (QB, ACC, Cin, Cout, Sum);	 
	FSM: Controller port map (STB, CLK, QA(0), Stop, Init, SH, Add, Done); 	

	--Stimulus
	StimulusFSM: process
	variable Val: Bit_vector(7 downto 0);
	begin  
		wait for 10 ns;
		wait until CLK'Event and CLK='1';
		Val:= QA;	
		loop
            Stop <=	not (Val(7) or Val(6) or Val(5) or Val(4) or Val(3) or Val(2) or Val(1) or Val(0));
            wait until CLK'Event and CLK='1';
            exit when Done = '1'; -- aca salgo del loop, esto pasa cuando stop=1 y se llega a EndS
            if SH = '1' then
            	Val := '0' & Val(7 downto 1); --Desplazamiento a derecha
            end if;
        end loop;	   
		DoneM <= Done; 
		Res <= ACC;
        wait;
	end process;  
	
end;