module Full_adder (a,b,cin, sum, cout );
  
  input [3:0] a, b, cin;
  output [3:0] sum, cout;
  
  assign {cout,sum} =cin+a+b;
  
endmodule
