# Adder

# Full Adder

A full adder is a digital circuit that performs addition. Full adders are implemented with logic gates in hardware. A full adder adds three one-bit binary numbers, two operands and a carry bit. The adder outputs two numbers, a sum and a carry bit. For this module have 3 input and 2 outputs.



            ///////////
            ///////////
            //// DUT //
            ///////////
            ///////////

            module adder (
                  input clk,
                  input reset'
                  input [3:0] a,
                  input [3:0] b,
                  input valid,
                  output [6:0] c );

            reg [6:0] tmp_c;

            //reset
            always @ (posedge reset)
	           tmp_c<=0;

            //addition operator
            always @ (posedge clk)
	            if (valid) tmp_c <=a+b;

	            assign c = tmp_c;

            endmodule
	    
	    
	    

            ////////////////
            ////////////////
            //interface.sv//
            ////////////////
            ////////////////

            interface intf(input logic clk,reset);

            ////////////////////////
            //declaring the signal//
            ////////////////////////
            logic valid;
            logic [3:0] a;
            logic [3:0] b;
            logic [6:0] c;

            endinterface





            //////////////////
            //////////////////
            //transaction.sv//
            //////////////////
            //////////////////

            class transaction;

            ///////////////////////////////////
            //declaring the transaction items//
            ///////////////////////////////////
            rand bit [3:0] a;
            rand bit [3:0] b;
                 bit [6:0] c;

            function void display(string name);
	            $display("%s", name);
	            $display("a = %0d, b = %0d",a,b);
	            $display("c = %0d", c);
            endfunction
            endclass





            //////////////////
            //////////////////
            //generator.sv////
            //////////////////
            //////////////////

            class generator;

            ///////////////////////////////////
            //declaring the transaction class//
            ///////////////////////////////////
            rand transaction trans;

            ////////////////////////////////////////////////////
            //repeat count to specify number items to generate//
            ////////////////////////////////////////////////////
            int repeat_count

            /////////////////////////////////////////////////////
            //mailbox to generate and send the packet to driver//
            /////////////////////////////////////////////////////
            mailbox gen2driv;

            ///////////////////////////////////////////
            //event to indicate the end of trasaction//
            ///////////////////////////////////////////
            event ended;

            //////////////////
            //constructor ////
            //////////////////

            //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.

            function new (mailbox gen2driv); 
	            this.gen2driv = gen2driv;
            endfunction

            ////////
            //Task//
            ////////

            task main();
	            repeat(repeat_count) begin
		            trans = new();
		            if( !trans.randomize()) $fatal("Gen::trans randomization failed");
		            trans.display("[Generator]");
		            gen2driv.put(trans);
	            end
	            ->ended; //trigering indicates the end of generation
            endtask
            endclass






            //////////////
            //////////////
            //Driver.sv///
            //////////////
            //////////////

            class driver;

            ////////////////////////////////////////////
            //used to count the number of transactions//
            ////////////////////////////////////////////

            int no_transaction;

            /////////////////////////////////////
            //creating virtual interface handle//
            /////////////////////////////////////

            virtual intf vif;

            ///////////////////////////
            //creating mailbox handle//
            ///////////////////////////
            mailbox gen2driv;

            ///////////////
            //constructor//
            ///////////////

            function new(virtual intf vif, mailbox gen2driv);
	            this.vif=vif; //getting the interface
	            this.gen2driv = gen2driv; //getting the mailbox handles from environment
            endfunction

            /////////////////////////////////////////////////////////////////////
            //Reset task, Reset the Interface signals to default/initial values//
            /////////////////////////////////////////////////////////////////////
            task reset;
	            wait (vif.reset);
	            $display("[DRIVER] ---Reset Started---");
	            vif.a <= 0;
	            vif.b <= 0;
	            vif.valid <= 0;
	            wait(!vif.reset);
	            $display("[DRIVER] ---Reset Ended---");
            endtask

            //////////////////////////////////////////////////////
            //drivers the transaction items to interface signals//
            //////////////////////////////////////////////////////
            task main;
	            forever begin
		            transaction trans;
		            gen2driv.get(trans);
		            @(posedge vif.clk);
		            vif.valid <= 1;
		            vif.a <= trans.a;
		            vif.b <= trans.b;
		            @(posedge vif.clk);
		            vif.valid <= 0;
		            trans.c = vif.c;
		            @(posedge vif.clk);
		            trans.display("[Driver]");
		            no_transaction++;
	            end
            endtask
            endclass






            ////////////////
            ////////////////
            //monitor.sv////
            ////////////////
            ////////////////

            class monitor;

            /////////////////////////////////////
            //creating virtual interface handle//
            /////////////////////////////////////
            virtual intf vif;

            ///////////////////////////
            //creating mailbox handle//
            ///////////////////////////
            mailbox mon2scb;

            ///////////////
            //constructor//
            ///////////////
            function new(virtual intf vif, mailbox mon2scb);
	            this.vif = vif;  //getting the iterface
	            this.mon2scb = mon2scb;  //getting the mailbox handles from environment
            endfunction

            //////////////////////////////////////////////////////////////////
            //Samples the interface signal and send the packet to scoreboard//
            //////////////////////////////////////////////////////////////////
            task main;
	            forever begin
		            transaction trans;
		            trans = new();
		            @(posedge vif.clk);
		            wait(vif.valid);
		            trans.a = vif.a;
		            trans.b = vif.b;
		            @(posedge vif.clk);
		            trans.c = vif.c;
		            @(posedge vif.clk);
		            mon2scb.put(trans);
		            trans.display("[Monitor]");
	            end
            endtask
            endclass






            ///////////////////
            ///////////////////
            //scoreboard.sv////
            ///////////////////
            ///////////////////

            class scoreboard;

            ///////////////////////////
            //creating mailbox handle//
            ///////////////////////////
            mailbox mon2scb;

            ////////////////////////////////////////////
            //used to count the number of transactions//
            ////////////////////////////////////////////
            int no_transaction;

            ///////////////
            //constructor//
            ///////////////
            function new(mailbox mon2scb);
	            this.mon2scb = mon2scb;//getting the mailbox handles from  environment 
            endfunction

            ///////////////////////////////////////////////////////
            //Compares the Actual result with the expected result//
            ///////////////////////////////////////////////////////
                task main;
	            transaction trans;
	            forever begin
		            mon2scb.get(trans);
		            if((trans.a+trans.b) == trans.c);
		            $display("Result is as Expected");
	            else
		            $error("Wrong Result.\n\tExpeced: %0d Actual: %0d", (trans.a+trans.b),trans.c);
	            no_transaction++;
	            trans.display("[Scoreboard]");
                    end
                 endtask
            endclass
	    
	    
	    
	    
	    
	    
	    

	    //////////////////
	    //////////////////
            //Environment.sv//
            //////////////////
            //////////////////

            `include "transaction.sv"
            `include "generator.sv"
            `include "driver.sv"
            `include "monitor.sv"
            `include "scoreboard.sv"
             class environment;

             /////////////////////////////////////
             ///generator and driver instance/////
             /////////////////////////////////////
             generator gen;
             driver driv;
             monitor mon;
             scoreboard scb;

             ///////////////////////////////
             ///mailbox handles/////////////
             ///////////////////////////////
             mailbox gen2driv;
             mailbox mon2scb;

             ////////////////////////////////
             ////virtual interface///////////
             ////////////////////////////////
             virtual intf vif;

             /////////////////////////////////
             ////constructor//////////////////
             /////////////////////////////////
	     	function new(virtual intf vif);
			this.vif = vif;  //get the interface from test
	
			//////////////////////////////////////
			////creating the mailbox /////////////
			//////////////////////////////////////
			gen2driv = new();
			mon2scb = new();

			//////////////////////////////////////
			////creating generator and driver////
			//////////////////////////////////////
			gen  = new(gen2driv);
			driv = new(vif, gen2driv);
			mon  = new(vif, mon2scb);
			scb  = new(mon2scb);

		endfunction

		task pre_test();
			driv.reset();
		endtask

		task test();
			fork
				gen.main();
				driv.main();
				mon.main();
				scb.main();
			join_any
		endtask
	
		////////////////////////////
		///////run task/////////////
		////////////////////////////
		task run;
			pre_test();
			test();
			post_test();
			$finish;
		endtask
	
	    endclass




            ////////////////
            ////////////////
            //testbench.sv//
            ////////////////
            ////////////////

            ////////////////////////
            //including interface //
            ////////////////////////
            `include "interface.sv"
            `include "random_test.sv"

            module tbench_top;

            //////////////////////////////////////
            //clock and reset signal declaration//
            //////////////////////////////////////
            bit clk;
            bit reset;

            ////////////////////
            //clock generation//
            ////////////////////
            always #5 clk= ~clk;

            ////////////////////
            //reset generation//
            ////////////////////
            initial begin
	            reset = 1;
	            #5 reset =0;
            end

            //////////////////////////////////
            //creating instance of interface//
            //////////////////////////////////
            intf i_intf(clk,reset);  

            /////////////////////////////////
            //creating instance of testcase//
            /////////////////////////////////
            test t1(i_intf);

            /////////////////////////
            //creating DUT instance//
            /////////////////////////
            adder DUT (
	            .clk(i_intf.clk),
	            .reset(i_intf.reset),
	            .a(i_intf.a),
	            .b(i_intf.b),
	            .valid(i_intf.valid),
	            .c(i_intf.c)
            );

            endmodule
	    
	    
	    
	    
	    
	    

            ////////////////
            ////////////////
            //Random_test///
            ////////////////
            ////////////////

            `include "environment.sv"
            program test(intf i_intf);

            //////////////////////////////////
            //declaring environment instance//
            //////////////////////////////////
            environment env;

            initial begin
	            env = new(i_intf);//creating environment
	            env.gen.repeat_count = 4;//setting the repeat count of generator as 4, means to generates 4 packet
	            env.run();//calling run of env, it interns calls generator and driver main tasks.
            end
            endprogram
	    
	    
	    
	    

            //////////////////
            //////////////////
            //Directed_test///
            //////////////////
            //////////////////

            `include "environment.sv"
            program test(intf i_intf);

            class my_trans extends transaction;
            bit [1:0] count;

            function void pre_randomize();
	            a.rand_mode(0);
	            b.rand_mode(0);

	            a=10;
	            b=12;
            endfunction
            endclass

            //////////////////////////////////
            //declaring environment instance//
            //////////////////////////////////
            environment env;
            my_trans my_tr;

            initial begin
	            env = new(i_intf);//creating environment
	            my_tr = new();
	            env.gen.repeat_count = 10;//setting the repeat count of generator as 10, means to generate 10 packets
	            env.gen.trans = my_tr;
	            env.run();//calling run of env, it interns calls generator and driver main tasks.
            end
            endprogram
