`timescale 1ns/1ns
`define num 20
`define WIDTH 8
`define CMD_WIDTH 4

//-------------------------------------

interface Alu_interface(input logic clock,input logic reset);
  logic [`WIDTH - 1 : 0]OPA;
  logic [`WIDTH - 1 : 0]OPB;
  logic [`CMD_WIDTH - 1 : 0]CMD;
  logic [1:0]IN_VALID;
  logic MODE;
  logic CE;
  logic CIN;
  logic [`WIDTH : 0]RES;
  logic ERR;
  logic COUT;
  logic OFLOW;
  logic G;
  logic E;
  logic L;
  
  clocking Drv_cb @(posedge clock);
    default input #0 output #0;
    
    output OPA;
    output OPB;
    output CMD;
    output IN_VALID;
    output MODE;
    output CE;
    output CIN;
    input reset;
    
  endclocking  
  
  clocking Mon_cb @(posedge clock);
    default input #0 output #0;
     input OPA;
    input OPB;
    input RES;
    input ERR;
    input OFLOW;
    input COUT;
    input G;
    input E;
    input L;
    input reset;
    
  endclocking 
  
  clocking Ref_cb @(posedge clock);
    default input #0 output #0;
    
    input OPA;
    input OPB;
    input CMD;
    input IN_VALID;
    input MODE;
    input CE;
    input CIN;
    input reset;
    
  endclocking 
  
  modport drv_mod(clocking Drv_cb);
    modport mon_mod(clocking Mon_cb);
      modport ref_mod(clocking Ref_cb);
  modport dut(input OPA,
    input OPB,
    input CMD,
    input IN_VALID,
    input MODE,
    input CE,
    input CIN,
    output RES,
    output ERR,
    output OFLOW,
    output COUT,
    output G,
    output E,
    output L);
    
    
//ASSERTIONS 
    
  property prop1;
    @(posedge clock)
    IN_VALID == 2'b11 |-> !$isunknown(OPA) && !$isunknown(OPB);
  endproperty
    assert property (prop1)
    else $error("OPA/OPB unknown when IN_VALID == 2'b11");

  property prop2;
    @(posedge clock)
    CE |-> !$isunknown(CMD) && !$isunknown(OPA) && !$isunknown(OPB) && !$isunknown(IN_VALID) && !$isunknown(MODE);
  endproperty
    assert property (prop2)
    else $error("CMD or operands unknown when CE is high");

  property prop3;
    @(posedge clock)
    CMD < (2**`CMD_WIDTH);
  endproperty
    assert property (prop3)
    else $error("CMD out of range!");

  property prop4;
    @(posedge clock)
    (MODE==1 ) |-> (CMD inside {0,1,2,3,4,5,6,7,8,9,10});
  endproperty
    assert property (prop4)
    else $error("Invalid CMD used in MODE=1");

  property prop5;
    @(posedge clock)
    (MODE==0 ) |-> (CMD inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13});
  endproperty
    assert property (prop5)
    else $error("Invalid CMD used in MODE=0");

  property prop6;
    @(posedge clock)
    reset |-> (RES==0 && ERR==0 && COUT==0 && OFLOW==0 && G==0 && E==0 && L==0);
  endproperty
    assert property (prop6)
    else $error("Outputs not cleared on reset");
    
      sequence seq1;
        CE ==1 && ((MODE ==1) && CMD inside{0,1,2,3,4,5,6,7,8}) || MODE == 0;
      endsequence 
      
//   property prop7;
//     @(posedge clock) seq1 ##2 RES;
//   endproperty
//      assert property (prop7)
//        else $error("No result after 1 clock cycle");
       
//        sequence seq2;
//          CE == 1 && (MODE == 1 && CMD inside {9,10});
//        endsequence
       
//        property prop8;
//          @(posedge clock) seq2 ##3 RES;
//        endproperty 
//        assert property (prop8);
//          $error("no resut for multiplication after 2 clock cycle ");

endinterface  
    
//---------------------------------------------------------------------------------------
class transaction;
  
  rand bit [`WIDTH - 1 : 0]OPA;
  rand bit [`WIDTH - 1 : 0]OPB;
  rand bit [`CMD_WIDTH - 1 : 0]CMD;
  rand bit [1:0]IN_VALID;
  rand bit CE;
  randc bit MODE;
  rand bit CIN;
  bit [`WIDTH : 0]RES;
  bit ERR;
  bit COUT;
  bit OFLOW;
  bit G;
  bit E;
  bit L;
  
  constraint a1{CE dist{0:=10,1:=90};}
  constraint a2{IN_VALID dist{[1:3]:=70 , 0:=30};}
  constraint a3{ CE == 1; IN_VALID == 2'b11;  }
  constraint a4{if(MODE == 1) CMD inside{[0:10]};}
  constraint a5{if(MODE	 == 0)CMD inside {[0:13]};}

  
  //constraint set {CMD == 9;MODE ==1; OPA inside{[0:5]};OPB inside {[0:5]};}
  virtual function transaction copy();
    copy = new;
    copy.OPA = OPA;
    copy.OPB = OPB;
    copy.CMD = CMD;
    copy.IN_VALID = IN_VALID;
    copy.CE = CE;
    copy.MODE = MODE;
    copy.CIN = CIN;
    copy.RES = RES;
    copy.COUT = COUT;
    copy.OFLOW = OFLOW;
    copy.G = G;
    copy.E = E;
    copy.L = L;
    return copy;
  endfunction 
endclass
      
      class trans_1 extends transaction;
        constraint a6 {CMD == 9; MODE == 1;IN_VALID == 2'b11;}
       constraint a7 {OPA inside {[1:5]}; OPB inside {[1:6]};}
         virtual function transaction copy();
           trans_1 copy1;
    copy1 = new;
    copy1.OPA = OPA;
    copy1.OPB = OPB;
    copy1.CMD = CMD;
    copy1.IN_VALID = IN_VALID;
    copy1.CE = CE;
    copy1.MODE = MODE;
    copy1.CIN = CIN;
    copy1.RES = RES;
    copy1.COUT = COUT;
    copy1.OFLOW = OFLOW;
    copy1.G = G;
    copy1.E = E;
    copy1.L = L;
    return copy1;
  endfunction 
endclass
        
         class trans_2 extends transaction;
           constraint a6 {CMD == 12; MODE == 0;IN_VALID == 2'b11;}
         virtual function transaction copy();
           trans_2 copy2;
    copy2 = new;
    copy2.OPA = OPA;
    copy2.OPB = OPB;
    copy2.CMD = CMD;
    copy2.IN_VALID = IN_VALID;
    copy2.CE = CE;
    copy2.MODE = MODE;
    copy2.CIN = CIN;
    copy2.RES = RES;
    copy2.COUT = COUT;
    copy2.OFLOW = OFLOW;
    copy2.G = G;
    copy2.E = E;
    copy2.L = L;
    return copy2;
  endfunction 
endclass
      
      class trans_3 extends transaction;
        constraint d1 { MODE == 1; CMD==8 ;IN_VALID ==2'b11 ;}
      
      virtual function transaction copy();
              trans_3 copy3;
    copy3=new();
    copy3.OPA=OPA;
    copy3.OPB=OPB;
    copy3.CMD=CMD;
    copy3.MODE=MODE;
    copy3.CIN=CIN;
    copy3.IN_VALID=IN_VALID;
    copy3.G=G;
    copy3.E=E;
    copy3.L=L;
    copy3.COUT=COUT;
    copy3.ERR=ERR;
    copy3.OFLOW=OFLOW;
    return copy3;
  endfunction
    endclass
    
    class trans_4 extends transaction ;
      constraint d2 {MODE==0;CMD==13;IN_VALID ==2'b11 ;}
      
      virtual function transaction copy();
              trans_4 copy4;
    copy4=new();
    copy4.OPA=OPA;
    copy4.OPB=OPB;
    copy4.CMD=CMD;
    copy4.MODE=MODE;
    copy4.CIN=CIN;
    copy4.IN_VALID = IN_VALID;
    copy4.G=G;
    copy4.E=E;
    copy4.L=L;
    copy4.COUT=COUT;
    copy4.ERR=ERR;
    copy4.OFLOW=OFLOW;
    return copy4;
  endfunction
    endclass
   
  //-----------------------------------------------------------------------------------------
  
class Generator;
  
  transaction gen_hand;
  
  mailbox #(transaction) gen2drv;
  
  function new(mailbox #(transaction) gen2drv);
    this.gen2drv = gen2drv;
    gen_hand = new();
  endfunction
  
  task start();
    begin 
      for(int i = 0 ; i < `num ; i++)
        begin 
          gen_hand.randomize();
          gen2drv.put(gen_hand.copy());
          $display("[%t]the Randomized values in generator are : opa:%d , opb:%d , CMD:%d , IN_VALID:%d , CE:%d, MODE:%d ",$time, gen_hand.OPA,gen_hand.OPB,gen_hand.CMD,gen_hand.IN_VALID,gen_hand.CE,gen_hand.MODE);
        end
    end
  endtask
endclass
//-------------------------------------------------------------------------------------------------
  class driver;

  virtual Alu_interface.drv_mod drv_intf;
  transaction drv_hand;
  mailbox #(transaction) gen2drv;
  mailbox #(transaction) drv2ref;
    
    covergroup driver_cover;
  Input_Valid : coverpoint drv_hand.IN_VALID {
    bins vld[4] = {2'b00, 2'b01, 2'b10, 2'b11};
  }
  Command : coverpoint drv_hand.CMD {
    bins cmd_first  = {[0 : (2**(`CMD_WIDTH/2))-1]};
    bins cmd_second = {[(2**(`CMD_WIDTH/2)) : (2**`CMD_WIDTH)-1]};
  }
  OperandA : coverpoint drv_hand.OPA {
    bins zero      = {0};
    bins small_opa = {[1 : (2**(`WIDTH/2))-1]};
    bins large_opa = {[2**(`WIDTH/2) : (2**`WIDTH)-1]};
  }
  OperandB : coverpoint drv_hand.OPB {
    bins zero      = {0};
    bins small_opb = {[1 : (2**(`WIDTH/2))-1]};
    bins large_opb = {[2**(`WIDTH/2) : (2**`WIDTH)-1]};
  }
  clock : coverpoint drv_hand.CE {
    bins Clock_en[] = {1'b0, 1'b1};
  }
  carry_in : coverpoint drv_hand.CIN {
    bins Carry_in[] = {1'b0, 1'b1};
  }
  AxB     : cross OperandA, OperandB;
  cmdxinp : cross Command, Input_Valid;
endgroup
    
  function new(mailbox #(transaction) gen2drv,
               mailbox #(transaction) drv2ref,
               virtual Alu_interface.drv_mod drv_intf);
    this.gen2drv = gen2drv;
    this.drv2ref = drv2ref;
    this.drv_intf = drv_intf;
    driver_cover = new();
  endfunction


  task start();
    
    repeat(3)@(drv_intf.Drv_cb);
    $display("driver started - %t",$time);
    for (int i = 0; i < `num; i++) begin
      gen2drv.get(drv_hand);
      driver_cover.sample();

      if (drv_intf.Drv_cb.reset == 0 && drv_hand.CE == 1) begin

        if ( (drv_hand.MODE == 1 && drv_hand.IN_VALID == 2'b11 ) || (drv_hand.MODE == 0 && drv_hand.IN_VALID == 2'b11)) begin


          drv_intf.Drv_cb.OPA      <= drv_hand.OPA;
          drv_intf.Drv_cb.OPB      <= drv_hand.OPB;
          drv_intf.Drv_cb.CMD      <= drv_hand.CMD;
          drv_intf.Drv_cb.IN_VALID <= drv_hand.IN_VALID;
          drv_intf.Drv_cb.MODE     <= drv_hand.MODE;
          drv_intf.Drv_cb.CE       <= drv_hand.CE;
          drv_intf.Drv_cb.CIN      <= drv_hand.CIN;

          
            if ((drv_hand.MODE == 1 && drv_hand.CMD == 9) || (drv_hand.MODE == 1 && drv_hand.CMD == 10))
              repeat(3) @(drv_intf.Drv_cb); 
            else  
              repeat(2)@(drv_intf.Drv_cb);           

          drv2ref.put(drv_hand.copy());
          $display("[%t]Driver sent for single operand(valid CMD): OPA=%d ,OPB=%d ,CMD=%d ,IN_VALID=%d, MODE=%d", $time,drv_hand.OPA, drv_hand.OPB, drv_hand.CMD, drv_hand.IN_VALID, drv_hand.MODE);

        end
        
        
         else if ( (drv_hand.MODE == 1 && drv_hand.CMD inside {4,5,6,7}) ||
             (drv_hand.MODE == 0 && drv_hand.CMD inside {6,7,8,9,10,11}) ) begin


          drv_intf.Drv_cb.OPA      <= drv_hand.OPA;
          drv_intf.Drv_cb.OPB      <= drv_hand.OPB;
          drv_intf.Drv_cb.CMD      <= drv_hand.CMD;
          drv_intf.Drv_cb.IN_VALID <= drv_hand.IN_VALID;
          drv_intf.Drv_cb.MODE     <= drv_hand.MODE;
          drv_intf.Drv_cb.CE       <= drv_hand.CE;
          drv_intf.Drv_cb.CIN      <= drv_hand.CIN;

              repeat(2)@(drv_intf.Drv_cb);         

          drv2ref.put(drv_hand.copy());
           $display("[%t]Driver sent for double operand with input valid as 2'b11(valid CMD): OPA=%d ,OPB=%d ,CMD=%d ,IN_VALID=%d, MODE=%d", $time,drv_hand.OPA, drv_hand.OPB, drv_hand.CMD, drv_hand.IN_VALID, drv_hand.MODE);

        end
          else if ( (drv_hand.MODE == 1 && drv_hand.IN_VALID == 2'b10) ||
          (drv_hand.MODE == 0 && drv_hand.IN_VALID == 2'b01) ) begin

            bit found = 0;
            drv_hand.CMD.rand_mode(0);
            drv_hand.MODE.rand_mode(0);
            drv_hand.CE.rand_mode(0);
                        
            drv_intf.Drv_cb.OPA      <= drv_hand.OPA;
            drv_intf.Drv_cb.OPB      <= drv_hand.OPB;
            drv_intf.Drv_cb.CMD      <= drv_hand.CMD;
            drv_intf.Drv_cb.IN_VALID <= drv_hand.IN_VALID;
            drv_intf.Drv_cb.MODE     <= drv_hand.MODE;
            drv_intf.Drv_cb.CE       <= drv_hand.CE;
            drv_intf.Drv_cb.CIN      <= drv_hand.CIN;

            for (int j = 0; j < 16; j++) begin
              @(drv_intf.Drv_cb);
              drv_hand.randomize();
              if (drv_hand.IN_VALID == 2'b11) begin
                $display("inside loop");
            drv_intf.Drv_cb.OPA      <= drv_hand.OPA;
            drv_intf.Drv_cb.OPB      <= drv_hand.OPB;
            drv_intf.Drv_cb.CMD      <= drv_hand.CMD;
            drv_intf.Drv_cb.IN_VALID <= drv_hand.IN_VALID;
            drv_intf.Drv_cb.MODE     <= drv_hand.MODE;
            drv_intf.Drv_cb.CE       <= drv_hand.CE;
            drv_intf.Drv_cb.CIN      <= drv_hand.CIN; 
                drv2ref.put(drv_hand);
                found = 1;
                break;
              end
              
                else begin
            drv_intf.Drv_cb.OPA      <= drv_hand.OPA;
            drv_intf.Drv_cb.OPB      <= drv_hand.OPB;
            drv_intf.Drv_cb.CMD      <= drv_hand.CMD;
            drv_intf.Drv_cb.IN_VALID <= drv_hand.IN_VALID;
            drv_intf.Drv_cb.MODE     <= drv_hand.MODE;
            drv_intf.Drv_cb.CE       <= drv_hand.CE;
            drv_intf.Drv_cb.CIN      <= drv_hand.CIN; 
                drv2ref.put(drv_hand);
              end
            end

            drv_hand.CMD.rand_mode(1);
            drv_hand.MODE.rand_mode(1);
            drv_hand.CE.rand_mode(1);


//             if (!found) begin
//               $error("IN_VALID did not become 2'b11 in 16 clocks for invalid CMD %0d MODE %0d", 
//                       drv_hand.CMD, drv_hand.MODE);
//             end


            if ((drv_hand.MODE == 1 && drv_hand.CMD == 9) || (drv_hand.MODE == 1 && drv_hand.CMD == 10))
              repeat(3) @(drv_intf.Drv_cb); 
            else  
              repeat(2)@(drv_intf.Drv_cb); 

            drv2ref.put(drv_hand.copy());
            $display("[%t]Driver sent for double operand(after waiting for IN_VALID): OPA=%d OPB=%d CMD=%d IN_VALID=%d",$time,
                      drv_hand.OPA, drv_hand.OPB, drv_hand.CMD, drv_hand.IN_VALID);

          end
        end
      end
    
  endtask
endclass
//----------------------------------------------------------------------------------------------------------------------------
      
 class Monitor;
  
  transaction mon_hand;
  virtual Alu_interface.mon_mod mon_intf;
  mailbox #(transaction) mon2scb;
//   // Covergroup must be declared right after member variables
//   covergroup monitor_cover;
//     ERROR  : coverpoint mon_hand.ERR;
//     RESULT : coverpoint mon_hand.RES { bins result = {[0 : (2**`WIDTH)-1]}; }
//     COUT   : coverpoint mon_hand.COUT;
//     OFLOW  : coverpoint mon_hand.OFLOW;
//     G      : coverpoint mon_hand.G;
//     E      : coverpoint mon_hand.E;
//     L      : coverpoint mon_hand.L;
//   endgroup

  // Constructor
  function new(mailbox #(transaction) mon2scb, virtual Alu_interface.mon_mod mon_intf);
    begin
    this.mon2scb = mon2scb;
    this.mon_intf = mon_intf;
   // monitor_cover = new(); // instantiate covergroup
    end
  endfunction

  // Task
  task start();
    repeat(4)@(mon_intf.Mon_cb);
    for (int i = 0; i < `num; i++) begin
      mon_hand = new();

      repeat(1)@(mon_intf.Mon_cb);
      
      mon_hand.RES   = mon_intf.Mon_cb.RES;
      mon_hand.ERR   = mon_intf.Mon_cb.ERR;
      mon_hand.COUT  = mon_intf.Mon_cb.COUT;
      mon_hand.OFLOW = mon_intf.Mon_cb.OFLOW;
      mon_hand.G     = mon_intf.Mon_cb.G;
      mon_hand.E     = mon_intf.Mon_cb.E;
      mon_hand.L     = mon_intf.Mon_cb.L;
      mon2scb.put(mon_hand);

      $display("[%t]Monitor TO Scoreboard: RES=%0d, ERR=%d, COUT=%d, OFLOW=%d, G=%d, E=%d, L=%d opa=%0d opb=%0d",$time,
                mon_hand.RES, mon_hand.ERR, mon_hand.COUT, mon_hand.OFLOW,
                mon_hand.G, mon_hand.E, mon_hand.L,mon_hand.OPA,mon_hand.OPB);
      //monitor_cover.sample();
    end
  endtask

endclass
    
 //--------------------------------------------------------------------------------------------------------------------
 class reference_model;

  virtual Alu_interface.ref_mod ref_intf;
  transaction ref_hand;

  mailbox #(transaction) drv2ref;
  mailbox #(transaction) ref2scb;
   
  localparam rot_bits = $clog2(`WIDTH);
  logic [rot_bits-1:0] rot_val;
   
  function new(mailbox #(transaction) drv2ref, mailbox #(transaction) ref2scb, virtual Alu_interface.ref_mod ref_intf);
    this.drv2ref = drv2ref;
    this.ref2scb = ref2scb;
    this.ref_intf = ref_intf;
  endfunction

  task start();
    bit found;
    bit [3:0] count;
    
    for(int i = 0; i < `num; i++) begin
      drv2ref.get(ref_hand);
      
      $display("[%t] data from driver :  OPA=%d ,OPB=%d ,CMD=%d ,IN_VALID=%d, MODE=%d", $time,ref_hand.OPA, ref_hand.OPB, ref_hand.CMD, ref_hand.IN_VALID, ref_hand.MODE);
      found = 0;
      count = 0;

      if (ref_intf.Ref_cb.reset == 1 || ref_hand.CE == 0) begin
        ref_hand.RES = 0;
        ref_hand.ERR = 0;
        ref_hand.COUT = 0;
        ref_hand.OFLOW = 0;
        ref_hand.G = 0;
        ref_hand.E = 0;
        ref_hand.L = 0;
      end
      else if (ref_intf.Ref_cb.reset == 0 && ref_hand.CE == 1) begin

        if ( (ref_hand.MODE == 1 && !(ref_hand.CMD inside {0,1,2,3,4,5,6,7,8,9,10})) ||
             (ref_hand.MODE == 0 && !(ref_hand.CMD inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13})) ) begin
          ref_hand.ERR = 1;
        end
        
        if( (ref_hand.MODE == 1 && (ref_hand.CMD inside {0,1,2,3,4,8,9,10})) ||
           (ref_hand.MODE == 0 && (ref_hand.CMD inside {0,1,2,3,4,5,12,13})) ) begin
          
          if (ref_hand.IN_VALID == 2'b10 || ref_hand.IN_VALID == 2'b01) begin
            repeat(16) begin
              drv2ref.get(ref_hand); 
              if (ref_hand.IN_VALID == 2'b11) begin
                found = 1;
                break;
              end
            end
          end
          
            if (!found) begin
              ref_hand.ERR = 1;
            end
          end

          
    if (ref_hand.MODE == 1) begin
      case (ref_hand.CMD)
                
                0: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = ref_hand.OPA + ref_hand.OPB;
                  ref_hand.COUT = ref_hand.RES[`WIDTH] ? 1 : 0 ;
                end
                1: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = ref_hand.OPA - ref_hand.OPB;
                  ref_hand.OFLOW = (ref_hand.OPA < ref_hand.OPB) ? 1 : 0;
                end
                2: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = ref_hand.OPA + ref_hand.OPB + ref_hand.CIN;
                  ref_hand.COUT = ref_hand.RES[`WIDTH] ? 1 : 0 ;
                end
                3: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = ref_hand.OPA - ref_hand.OPB - ref_hand.CIN;
                  ref_hand.OFLOW = (ref_hand.OPA < ref_hand.OPB) ? 1 : 0;
                end
                 4: if(ref_hand.IN_VALID == 2'b01 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = ref_hand.OPA + 1;
                end
            	   else begin
                     ref_hand.ERR = 1;
                   end
                5: if(ref_hand.IN_VALID == 2'b01 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = ref_hand.OPA - 1;  
                end
                  else begin 
                    ref_hand.ERR = 1;
                  end
                6: if(ref_hand.IN_VALID == 2'b10 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = ref_hand.OPB + 1;
                end
                  else begin 
                    ref_hand.ERR = 1;
                  end
                7: if(ref_hand.IN_VALID == 2'b10 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = ref_hand.OPB - 1;
                end
                  else begin 
                    ref_hand.ERR = 1;
                  end                        
                8: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  if(ref_hand.OPA > ref_hand.OPB) ref_hand.G = 1;
                  else if (ref_hand.OPA == ref_hand.OPB) ref_hand.E = 1;
                  else ref_hand.L = 1;
                end
                9: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = (ref_hand.OPA+1) * (ref_hand.OPB+1);
                end
                10: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = (ref_hand.OPA<<1) * ref_hand.OPB; 
                end
                default: ref_hand.ERR = 1;
              endcase
            end
        
            else if (ref_hand.MODE == 0) begin
              case (ref_hand.CMD)
                0: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = {1'b0, ref_hand.OPA & ref_hand.OPB};
                end
                1: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = {1'b0, ~(ref_hand.OPA & ref_hand.OPB)};
                end
                2: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = {1'b0, ref_hand.OPA | ref_hand.OPB};
                end
                3: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = {1'b0, ~(ref_hand.OPA | ref_hand.OPB)};
                end
                4: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = {1'b0, ref_hand.OPA ^ ref_hand.OPB};
                end
                5: if (ref_hand.IN_VALID == 2'b11 || found) begin
                  ref_hand.RES = {1'b0, ~(ref_hand.OPA ^ ref_hand.OPB)};
                end
                6: if(ref_hand.IN_VALID == 2'b01 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = {1'b0, ~ref_hand.OPA};
                end
                else begin
                  ref_hand.ERR = 1;
                end
                7: if(ref_hand.IN_VALID == 2'b10 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = {1'b0, ~ref_hand.OPB};
                end
                else begin
                  ref_hand.ERR = 1;
                end
                8: if(ref_hand.IN_VALID == 2'b01 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = {1'b0, ref_hand.OPA>>1};
                end
                else begin
                  ref_hand.ERR = 1;
                end
                9: if(ref_hand.IN_VALID == 2'b01 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = {1'b0, ref_hand.OPA << 1};
                end
                else begin
                  ref_hand.ERR = 1;
                end
                10:if(ref_hand.IN_VALID == 2'b10 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = {1'b0,ref_hand.OPB >> 1};
                end
                else begin
                  ref_hand.ERR = 1;
                end
                11: if(ref_hand.IN_VALID == 2'b10 || ref_hand.IN_VALID == 2'b11) begin
                  ref_hand.RES = {1'b0, ref_hand.OPB <<1};
                end
                else begin
                  ref_hand.ERR = 1;
                end
                12: if (ref_hand.IN_VALID == 2'b11 || found) begin 
                  if (ref_hand.OPB >= `WIDTH)
                    ref_hand.ERR = 1;
                  else
                    rot_val= ref_hand.OPB[rot_bits-1 :0];
                  ref_hand.RES = {1'b0, (ref_hand.OPA << rot_val) | (ref_hand.OPA >> (`WIDTH - rot_val))};
                end
                13: if (ref_hand.IN_VALID == 2'b11 || found) begin 
                  if (ref_hand.OPB >= `WIDTH)
                    ref_hand.ERR = 1;
                  else
                    rot_val= ref_hand.OPB[rot_bits-1 : 0];
                  ref_hand.RES = {1'b0, (ref_hand.OPA >> rot_val) | (ref_hand.OPA << (`WIDTH - rot_val))};
                end
                default : ref_hand.ERR = 1;
              endcase
            end 
          end 
      
      ref2scb.put(ref_hand.copy());
      $display("[%t]data out from reference model CMD=%d MODE=%d RES=%d ERR=%d COUT=%d OFLOW=%d G=%d E=%d L=%d", $time,ref_hand.CMD, ref_hand.MODE, ref_hand.RES, ref_hand.ERR, ref_hand.COUT, ref_hand.OFLOW, ref_hand.G, ref_hand.E, ref_hand.L);
      
        end 
  endtask
endclass
    //----------------------------------------------------------------------------------------------------------------------------------------------------------------
      
 class scoreboard;
  
  transaction ref_hand, mon_hand;
  mailbox #(transaction) ref2scb;
  mailbox #(transaction) mon2scb;
  
  function new(mailbox #(transaction) ref2scb, mailbox #(transaction) mon2scb);
    this.ref2scb = ref2scb;
    this.mon2scb = mon2scb;
  endfunction 
  
  task start();
    for(int i = 0; i < `num; i++) begin 
      fork
        begin
          mon2scb.get(mon_hand);

        end
        begin
          ref2scb.get(ref_hand);
         
        end
      join
 $display("[%t]------------Data From Reference Model--------- : Result: %d, ERR: %d, COUT: %d, OFLOW: %d, G: %d, E: %d, L: %d",
                   $time,ref_hand.RES, ref_hand.ERR, ref_hand.COUT, ref_hand.OFLOW, ref_hand.G, ref_hand.E, ref_hand.L);
                $display("[%t]-------------Data From Monitor Model---------- : Result: %d, ERR: %d, COUT: %d, OFLOW: %d, G: %d, E: %d, L: %d",$time,
                   mon_hand.RES, mon_hand.ERR, mon_hand.COUT, mon_hand.OFLOW, mon_hand.G, mon_hand.E, mon_hand.L);
      
      if (ref_hand.RES === mon_hand.RES)
        $display("%t : RES matches ", $time);
      else
        $error("%t : RES mismatch  (REF=%d, MON=%d)", $time, ref_hand.RES, mon_hand.RES);

      if (ref_hand.ERR === mon_hand.ERR)
        $display("%t : ERR matches ", $time);
      else
        $error("%t : ERR mismatch (REF=%d, MON=%d)", $time, ref_hand.ERR, mon_hand.ERR);

      if (ref_hand.COUT === mon_hand.COUT)
        $display("%t : COUT matches ", $time);
      else
        $error("%t : COUT mismatch (REF=%d, MON=%d)", $time, ref_hand.COUT, mon_hand.COUT);

      if (ref_hand.OFLOW === mon_hand.OFLOW)
        $display("%t : OFLOW matches ", $time);
      else
        $error("%t : OFLOW mismatch (REF=%d, MON=%d)", $time, ref_hand.OFLOW, mon_hand.OFLOW);

      if (ref_hand.G === mon_hand.G)
        $display("%t : G matches ", $time);
      else
        $error("%t : G mismatch (REF=%d, MON=%d)", $time, ref_hand.G, mon_hand.G);

      if (ref_hand.E === mon_hand.E)
        $display("%t : E matches ", $time);
      else
        $error("%t : E mismatch (REF=%d, MON=%d)", $time, ref_hand.E, mon_hand.E);

      if (ref_hand.L === mon_hand.L)
        $display("%t : L matches ", $time);
      else
        $error("%t : L mismatch (REF=%d, MON=%d)", $time, ref_hand.L, mon_hand.L);

      $display("-------------------------------------------------------------");
    end
  endtask
endclass
//-----------------------------------------------------------------------------------------------------------------------------------------------------
 
  class environment;
  
  virtual Alu_interface drv_intf;
  virtual Alu_interface mon_intf;
  virtual Alu_interface ref_intf;
  
  mailbox #(transaction) gen2drv;
  mailbox #(transaction) drv2ref;
  mailbox #(transaction) mon2scb;
  mailbox #(transaction) ref2scb;
  
  Generator gen;
  driver drv;
  Monitor mon;
  reference_model ref_mod;
  scoreboard scb;
  
  function new(  virtual Alu_interface drv_intf,virtual Alu_interface mon_intf,virtual Alu_interface ref_intf);
    begin 
      this.drv_intf = drv_intf;
      this.mon_intf = mon_intf;
      this.ref_intf = ref_intf;
    end
  endfunction 
  
  task build();
    begin
    gen2drv = new();
    drv2ref = new();
    mon2scb = new();
    ref2scb = new();
    
    gen = new(gen2drv);
    drv = new(gen2drv,drv2ref,drv_intf);
    mon = new(mon2scb,mon_intf);
    ref_mod = new(drv2ref,ref2scb,ref_intf);
    scb = new(ref2scb,mon2scb);
    end
  endtask
  
  task start();
    fork 
    gen.start();
    drv.start();
    mon.start();
    ref_mod.start();
    scb.start();
    join
  endtask
  
endclass
  //----------------------------------------------------------------------------------------------------------------------------------------------------
 class testbench;
  
  virtual Alu_interface drv_intf;
  virtual Alu_interface mon_intf;
  virtual Alu_interface ref_intf;
  
  environment env;
  
  function new(virtual Alu_interface drv_intf,virtual Alu_interface mon_intf,virtual Alu_interface ref_intf);
    begin 
      this.drv_intf = drv_intf;
      this.mon_intf = mon_intf;
      this.ref_intf = ref_intf;
    end
  endfunction 
  
  task run;
    begin 
      env = new( drv_intf, mon_intf, ref_intf);
      env.build();
      env.start();
    end
  endtask
endclass
  
      class test1 extends testbench;
        trans_1 trans;
        function new(virtual Alu_interface drv_intf,
                     virtual Alu_interface mon_intf,
                     virtual Alu_interface ref_intf);
          super.new(drv_intf, mon_intf, ref_intf);
        endfunction 
        
        task run();
          $display("child test 1");
          env = new(drv_intf, mon_intf, ref_intf);
          env.build;
          begin 
            trans = new();
            env.gen.gen_hand = trans;
          end
          env.start;
        endtask;
      endclass
      
      class test2 extends testbench;
        trans_2 trans;
        function new(virtual Alu_interface drv_intf,
                     virtual Alu_interface mon_intf,
                     virtual Alu_interface ref_intf);
          super.new(drv_intf, mon_intf, ref_intf);
        endfunction 
        
        task run();
          $display("child test 2");
          env = new(drv_intf, mon_intf, ref_intf);
          env.build;
          begin 
            trans = new();
            env.gen.gen_hand = trans;
          end
          env.start;
        endtask;
      endclass
      
          
      class test3 extends testbench;
        trans_3 trans;
        function new(virtual Alu_interface drv_intf,
                     virtual Alu_interface mon_intf,
                     virtual Alu_interface ref_intf);
          super.new(drv_intf, mon_intf, ref_intf);
        endfunction 
        
        task run();
          $display("child test 2");
          env = new(drv_intf, mon_intf, ref_intf);
          env.build;
          begin 
            trans = new();
            env.gen.gen_hand = trans;
          end
          env.start;
        endtask
      endclass
      
          
      class test4 extends testbench;
        trans_4 trans;
        function new(virtual Alu_interface drv_intf,
                     virtual Alu_interface mon_intf,
                     virtual Alu_interface ref_intf);
          super.new(drv_intf, mon_intf, ref_intf);
        endfunction 
        
        task run();
          $display("child test 2");
          env = new(drv_intf, mon_intf, ref_intf);
          env.build;
          begin 
            trans = new();
            env.gen.gen_hand = trans;
          end
          env.start;
        endtask
      endclass
      
      class test_regression extends testbench;
        transaction trans0;
        trans_1 trans1;
        trans_2 trans2;
        trans_3 trans3;
        trans_4 trans4;
        
        function new(virtual Alu_interface drv_intf,
                     virtual Alu_interface mon_intf,
                     virtual Alu_interface ref_intf);
          super.new(drv_intf, mon_intf, ref_intf);
        endfunction 
        
        task run();
          
         env = new(drv_intf, mon_intf, ref_intf);
          
          env.build;
        //..............................
          
          begin 
            trans0 = new();
            env.gen.gen_hand = trans0;
          end
          env.start;
          
        //...............................
          
          begin 
            trans1 = new();
            env.gen.gen_hand = trans1;
          end
          env.start;
          
         //.............................
          
          begin 
            trans2 = new();
            env.gen.gen_hand = trans2;
          end
          env.start;
          
         //..............................
          
          begin 
            trans3 = new();
            env.gen.gen_hand = trans3;
          end
          env.start;
          
         //..............................
          
          begin 
            trans4 = new();
            env.gen.gen_hand = trans4;
          end
          env.start;
         
         //.............................
        endtask
      endclass
  //--------------------------------------------------------------------------------------------------------------------------------------------------
 module top;
  logic clock;
  logic reset;
   
   initial 
     begin 
       clock = 0;
       forever #5 clock = ~clock;
     end

   
  initial
    begin
      reset = 0;
      @(posedge clock)
      reset = 0;
    end

   
  Alu_interface intf(clock, reset);
  
  ALU_DESIGN DUT(.INP_VALID(intf.IN_VALID), .OPA(intf.OPA), .OPB(intf.OPB), .CIN(intf.CIN), .CMD(intf.CMD), .COUT(intf.COUT), .OFLOW(intf.OFLOW), .RES(intf.RES), .G(intf.G), .E(intf.E), .L(intf.L), .CLK(clock), .ERR(intf.ERR), .CE(intf.CE), .MODE(intf.MODE), .RST(intf.reset));
  
   testbench test = new(intf.drv_mod, intf.mon_mod, intf.ref_mod);
   //test_regression set = new(intf.drv_mod, intf.mon_mod, intf.ref_mod);
   
  initial 
    begin 
      test.run();
      //set.run();
      $finish();
    end
endmodule
