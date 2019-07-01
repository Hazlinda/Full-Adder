module full_adder_tb ;  
  reg [3:0] A, B, Cin;
  //reg [3:0] B, 
  //reg [3:0] Cin;		//in testbench do not using input and output
  wire [3:0] Sum, Cout;
  //wire Cout;		//just using the reg and wire

  	 initial begin 
 		   $dumpfile("dump.vcd"); // Dump waves 
   		 $dumpvars(1); //Rest of the code in the initial block   
 end   

  Full_adder FA (.a(A), .b(B), .cin(Cin), .sum(Sum), .cout(Cout)); //instantiate
  
  initial begin 
     A =1; B= 1; Cin = 1;
    #1
    A =4; B= 2; Cin = 0;
    #2
    A =3; B= 3; Cin = 1;
    #3
    A =4; B= 4; Cin = 0;
    #4
    A =2; B= 4; Cin = 1;
        #10 $finish;
  end 
endmodule
