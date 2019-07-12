# Adder

# Full Adder

A full adder is a digital circuit that performs addition. Full adders are implemented with logic gates in hardware. A full adder adds three one-bit binary numbers, two operands and a carry bit. The adder outputs two numbers, a sum and a carry bit. For this module have 3 input and 2 outputs.

# 'ADDER' TestBench Without Monitor, Agent and Scoreboard 

Adder module

      module adder(
        input clk,
        input reset,
        input [3:0] a,
        input [3:0] b,
        input valid,
        output [6:0] c); 
  
        reg [6:0] tmp_c;
  
        //Reset 
        always @(posedge reset) 
          tmp_c <= 0;
   
        // addition operation
        always @(posedge clk) 
          if (valid)    tmp_c <= a + b;
          assign c = tmp_c;

      endmodule

Testbench coding:

      //including interfcae and testcase files
      `include "interface.sv"
      //Particular testcase can be run by uncommenting, and commenting the rest
      `include "random_test.sv"

      module tbench_top;
        //clock and reset signal declaration
        bit clk;
        bit reset;
  
        //clock generation
        always #5 clk = ~clk;
  
        //reset Generation
        initial begin
          reset = 1;
          #5 reset =0;
        end
  
        //creatinng instance of interface, inorder to connect DUT and testcase
        intf i_intf(clk,reset);
  
        //Testcase instance, interface handle is passed to test as an argument
        test t1(i_intf);
  
        //DUT instance, interface signals are connected to the DUT ports
        adder DUT (
        .clk(i_intf.clk),
        .reset(i_intf.reset),
        .a(i_intf.a),
        .b(i_intf.b),
        .valid(i_intf.valid),
        .c(i_intf.c)
        );
  
        //enabling the wave dump
        initial begin 
        $dumpfile("dump.vcd"); $dumpvars;
          end
        endmodule

Class Driver:

        class driver;
  
            //used to count the number of transactions
            int no_transactions;
            //creating virtual interface handle
            virtual intf vif;
   
            //creating mailbox handle
            mailbox gen2driv;
   
            //constructor
            function new(virtual intf vif,mailbox gen2driv);
                //getting the interface
                this.vif = vif;
                //getting the mailbox handles from  environment
                this.gen2driv = gen2driv;
            endfunction
   
            //Reset task, Reset the Interface signals to default/initial values
           task reset;
            wait(vif.reset);
            $display("[ DRIVER ] ----- Reset Started -----");
                  vif.a <= 0;
                  vif.b <= 0;
                  vif.valid <= 0;
                  wait(!vif.reset);
            $display("[ DRIVER ] ----- Reset Ended   -----");
           endtask
   
            //drivers the transaction items to interface signals
           task main;
            forever begin
            transaction trans;
            gen2driv.get(trans);
            @(posedge vif.clk);
            vif.valid <= 1;
            vif.a     <= trans.a;
            vif.b     <= trans.b;
            @(posedge vif.clk);
            vif.valid <= 0;
            trans.c   <= vif.c;
            @(posedge vif.clk);
            trans.display("[ Driver ]");
            no_transactions++;
            end
          endtask
           
      endclass
