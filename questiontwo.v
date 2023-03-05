module questiontwo(clock, PC, IR, MBR, MAR);
input clock;
output PC, IR, MBR, MAR;
reg [11:0] IR, MBR;
reg [5:0] PC,MAR;
reg [11:0] Memory [0:63];
reg [11:0] R[3:0];
reg [2:0] state;

parameter load = 3'b000, store = 3'b001, add = 3'b010, sub =3'b011, mul = 3'b100, div = 3'b101;

initial begin 
	// program
	Memory [10] = 12'h01F;
	Memory [11] = 12'h820;
	Memory [12] = 12'h41E;
	Memory [13] = 12'h0A1;
	Memory [14] = 12'h6A2;
	Memory [15] = 12'hA41;
	Memory [16] = 12'h223;
	
	// data at byte address
	Memory [30] = 12'h803;
	Memory [31] = 12'h003;
	Memory [32] = 12'h005;
	Memory [33] = 12'h008;
	Memory [34] = 12'h004;
	Memory [35] = 12'h000;
	
	
	
	//set the program counter to the start of the program
	PC = 10; state = 0;
end


always @ (posedge clock) begin 
if (PC < 30) begin
case (state)
0: begin 
	MAR <= PC;
	state = 1;
	end
1:  begin // fetch the instruction from memory
	IR <= Memory[MAR];
	PC <= PC + 1;
	state = 2; //next state
	end
2: begin // instruction decode
	MAR <= IR[5:0];
	state = 3;
	end
3: begin // operand fetch
	state = 4;
	case (IR[11:8])
		load : MBR <= Memory[MAR];
	   store : R[IR[8:6]] <= MBR ;
		 add : MBR <= Memory[MAR];
	     sub : MBR <= Memory[MAR];
		 mul : MBR <= Memory[MAR];
		 div : MBR <= Memory[MAR]; 
	   endcase 
	   end
4: begin // R/M Parameter
	MAR <= IR[6:5];
		state = 5;
	end
5: begin
	MAR <= IR[8:6]; // destination register address
		state = 6;
	end

6: begin //excute
		if (IR[11:8] == 3'h2) begin   // add 
			R[IR[8:6]] <= R[IR[8:6]] + MBR;
				state = 0;
		end
		else if (IR[11:8] == 3'h0) begin  // load
					R[IR[8:6]] <= MBR; 
						state = 0; //next state
		end 
		else if (IR[11:8] == 3'h1) begin  // store 
					R[IR[8:6]] <= MBR; 
						state = 0;
		end
		else if (IR[11:8] == 3'h3) begin  // sub 
					R[IR[8:6]] <= R[IR[8:6]] - MBR;
						state = 0; //next state
		end 
		else if (IR[11:8] == 3'h4) begin  // mul
					R[IR[8:6]] <= R[IR[8:6]] * MBR;
						state = 0; //next state
		end 
		else if (IR[11:8] == 3'h5) begin  // div 
					R[IR[8:6]] <= R[IR[8:6]] / MBR;
						state = 0; //next state
		end 
	end
	endcase 
end 
else if (PC >= 30) begin
case (state)
0: begin 
	MAR <= PC;
	state = 1;
	end
1:  begin // fetch the data from memory
	IR <= Memory[MAR];
	PC <= PC + 1;
	state = 2; //next state
	end
2: begin // instruction decode
	MAR <= IR[10:0];
	state = 3;
	end
3: begin // 
	MBR <= Memory[MAR];
	
		state = 4;
	end
4: begin // sign bit
	if (IR[11:10] == 0) begin
			MBR <= MBR * 1 ;
			state = 0;
	end
	else if (IR[11:10] == 1) begin
			MBR <= MBR * -1 ;
			state = 0;
	end
end
endcase 
end
end
endmodule 