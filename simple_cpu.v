


/*

 An implementation of a simple CPU which knows how to add/subtract.
 I was learning how to use Verilog...
  
 Reference for myself:
 https://stackoverflow.com/questions/34849832/when-exactly-to-use-assign-keyword-and-when-to-use-operators

*/



`define INSTRUCTION_COUNT 4

// The number of clock cycles you want this to run
`define CYCLES 9



module alu(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire op,
    output reg [15:0] C
    );
    
    always @(*) begin
        case (op)
            0:  C = A + B;
            1:  C = A - B;
            default: C = 16'dz;
        endcase
    end

endmodule


module cpu;
   reg 	      clk;
   reg [16:0] mem [0:31]; // instruction or control memory
   reg [15:0] r[0:7];     // registers
   reg [15:0] PC;
   
   wire [16:0] instruction;

   wire [2:0] ar1;
   wire [2:0] ar2;
   wire [2:0] aw;
   wire       we;
   wire [2:0] nzp;
   wire [2:0] nextPC;

   wire [15:0] aluOpA;
   wire [15:0] aluOpB;
   wire [15:0] aluOut;

   assign instruction = mem[PC];
   assign ar1 = instruction[15:13];   // Address Read1
   assign ar2 = instruction[12:10]; 
   assign aluOpA = r[instruction[15:13]];
   assign aluOpB = r[instruction[12:10]];
   assign aw = instruction[9:7];      // Address Write
   assign we = instruction[6];        // Write Enable
   assign nzp = instruction[5:3];
   assign nextPC = instruction[2:0];
   
   
   alu alu(aluOpA, aluOpB, instruction[16], aluOut);
   
   always #5 clk <= ~clk;

   initial begin
      clk = 0;
      PC = -1;

      $display("Loading program...");
      $readmemb("program_bin.txt", mem, 0, `INSTRUCTION_COUNT-1);
      $display("Setting up register file...");
      $readmemb("register_content.txt", r);
      

      repeat (`CYCLES) begin
	 @(posedge clk);
	 
	 if ( (nzp[0]==1 && aluOut >0) || (nzp[1]==1 && aluOut==0) || (nzp[2]==1 && aluOut <0) )
	   PC <= nextPC;
	 else 
	   PC <= PC + 1;
	 
	 if (we==1)
	   r[aw] <= aluOut;
	 
	 #1 $display("\nR0=%0d, R1=%0d, R2=%0d, R3=%0d, R4=%0d, R5=%0d, R6=%0d, R7=%0d", r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7]);
	   //$display("\nZ=%0d, One=%0d, A=%0d, B=%0d, C=%0d", r[0], r[1], r[2], r[3], r[4]);
	 
	 $display("%0t PC=%0d, I=%b, nzp=%b, RA1=%d, RA2=%d, WA=%d, WE=%b, OpA=%0d, OpB=%0d, Out=%0d, nextPC=%d", $time, PC, instruction, nzp, ar1, ar2, aw, we, aluOpA, aluOpB, aluOut, nextPC);
      end
      $finish;
      
   end
   
   

   
endmodule

