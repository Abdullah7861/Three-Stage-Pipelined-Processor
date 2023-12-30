module Processor (
    input logic clk,
    input logic rst,
    input logic interupt
);
    //control signals

    logic        sel_pc;
    logic        sel_opr_a;
    logic        sel_opr_b;
    logic        sel_m;
    logic        en;
    logic [ 2:0] imm_type;
    
    logic [ 4:0] rs2;
    logic [ 4:0] rs1;
    
    logic [ 6:0] opcode;
    logic [ 2:0] func3;
    logic [ 6:0] func7;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [31:0] rdata1;
    
    logic [ 3:0] aluop;
    logic [31:0] imm;
    
    logic [31:0] mux_out_pc;
    logic [31:0] mux_out_opr_a;
    logic [31:0] mux_out_opr_b;
    logic [31:0] mux_out_for_a;
    logic [31:0] mux_out_for_b;
    logic [ 2:0] br_type;
    logic        br_taken;
    logic        tm_interupt;
    logic [31:0] csr_rdata;
    logic [31:0] epc;
    logic        epc_taken;
    logic        excep;
    logic        for_a;
    logic        for_b;
    logic        sel_for_a;
    logic        sel_for_b;
    

    logic        flush_id_ex;
    
    //stalls
    logic        stall_if;
    logic        stall_id_ex;
    
    //is_mret
    logic        is_mret_id_ex;
    logic        is_mret_im_wb;

    //csr_rd
    logic        csr_rd_id_ex;
    logic        csr_rd_im_wb;

    //csr_wr
    logic        csr_wr_id_ex;
    logic        csr_wr_im_wb;
    
    //sel_wb
    logic [ 1:0] sel_wb_id_ex;
    logic [ 1:0] sel_wb_im_wb;

    //rf_en
    logic        rf_en_id_ex;
    logic        rf_en_im_wb;

    //pc_out
    logic [31:0] pc_out_fetch;
    logic [31:0] pc_out_ex;
    logic [31:0] pc_out_mem;

    //Instruction
    logic [31:0] inst_fetch;
    logic [31:0] inst_ex;
    logic [31:0] inst_mem_wb;
    
    
    //rd
    logic [ 4:0] rd_id_ex;
    logic [ 4:0] rd_im_wb;
    
    //rdata2
    logic [31:0] rdata2_id_ex;
    logic [31:0] rdata2_im_wb;
    
    //opr_res
    logic [31:0] opr_res_id_ex;
    logic [31:0] opr_res_im_wb;
    
    //rd_en
    logic        rd_en_id_ex;
    logic        rd_en_im_wb;
    
    //wr_en
    logic        wr_en_id_ex;
    logic        wr_en_im_wb;
    
    //mem_type
    logic [ 2:0] mem_type_id_ex;
    logic [ 2:0] mem_type_im_wb;

    
    
    // program counter multiplexer
    always_comb 
    begin 
    if (epc_taken)
        begin
            mux_out_pc = epc;
        end
        else
        begin
            mux_out_pc = br_taken ? opr_res_id_ex : (pc_out_fetch + 32'd4);
        end
    end
    


// ------------------------FETCH--------------------------

    PC PC_i
    (
        .clk    ( clk            ),
        .rst    ( rst            ),
        .en     ( ~stall_if      ),
        .pc_in  ( mux_out_pc     ),
        .pc_out ( pc_out_fetch      )
    );

    inst_mem inst_mem_i
    (
        .addr   ( pc_out_fetch       ),
        .data   ( inst_fetch         )
    );





    reg_fetch_to_ex reg_fetch_to_ex_i
    (
        .clk (  clk                        ),
        .rst(   rst                        ),
        .flush_id_ex(   flush_id_ex        ),
        .stall_id_ex(   stall_id_ex        ),
        .inst_fetch(    inst_fetch         ),
        .pc_out_fetch(  pc_out_fetch       ),
        .inst_ex(   inst_ex                ),
        .pc_out_ex( pc_out_ex              )
    );

    
    
// ----------------------------DECODE------------------------------

    inst_decode inst_decode_i
    (
        .clk    ( clk             ),
        .inst   ( inst_ex      ),
        .rd     ( rd_id_ex        ),
        .rs1    ( rs1             ),
        .rs2    ( rs2             ),
        .opcode ( opcode          ),
        .func3  ( func3           ),
        .func7  ( func7           )
    );

    reg_file reg_file_i
    (
        .clk    ( clk             ),
        .rs2    ( rs2             ),
        .rs1    ( rs1             ),
        .rd     ( rd_im_wb        ),
        .wdata  ( wdata           ),
        .rdata1 ( rdata1          ),
        .rdata2 ( rdata2_id_ex    ),
        .rf_en  ( rf_en_im_wb     )

    );

     // controller
    controller controller_i
    (
        .opcode    ( opcode         ),
        .func7     ( func7          ),
        .func3     ( func3          ),
        .rf_en     ( rf_en_id_ex    ),
        .sel_opr_a ( sel_opr_a      ),
        .sel_opr_b ( sel_opr_b      ),
        .sel_wb    ( sel_wb_id_ex   ),
        .imm_type  ( imm_type       ),
        .aluop     ( aluop          ),
        .br_type   ( br_type        ),
        .rd_en     ( rd_en_id_ex    ),
        .wr_en     ( wr_en_id_ex    ),
        .mem_type  ( mem_type_id_ex ),
        .csr_rd    ( csr_rd_id_ex   ),
        .csr_wr    ( csr_wr_id_ex   ),
        .is_mret   ( is_mret_id_ex  )
    );

    // immediate generator
    imm_gen imm_gen_i
    (
        .inst      ( inst_ex     ),
        .imm_type  ( imm_type       ),
        .imm       ( imm            )
    );

// ----------------------EXECUTE------------------------------

    // forward a selection mux
    assign mux_out_for_a = sel_for_a ? opr_res_im_wb : rdata1;

    //forward b selection mux
    assign mux_out_for_b = sel_for_b ? opr_res_im_wb : rdata2_id_ex;

    // operand a selection mux
    assign mux_out_opr_a = sel_opr_a ? pc_out_ex : mux_out_for_a;

    // operand b selection mux
    assign mux_out_opr_b = sel_opr_b ? imm    : mux_out_for_b;

     alu alu_i
    (
        .aluop    ( aluop          ),
        .opr_a    ( mux_out_opr_a  ),
        .opr_b    ( mux_out_opr_b  ),
        .opr_res  ( opr_res_id_ex  )
    );



    Branch_comp Branch_comp_i
    (
        .br_type   ( br_type        ),
        .opr_a     ( mux_out_for_a  ),
        .opr_b     ( mux_out_for_b  ),
        .br_taken  ( br_taken       )
    );


    hazard_detection hazard_detection_i
    (
        .rf_en      ( rf_en_im_wb   ),
        .rs1        ( rs1           ),
        .rs2        ( rs2           ),
        .rd         ( rd_im_wb      ),
        .for_a      ( sel_for_a     ),
        .for_b      ( sel_for_b     ),
        .sel_wb     ( sel_wb_im_wb  ),
        .stall_if   ( stall_if      ),
        .stall_id_ex( stall_id_ex   ),
        .flush_id_ex( flush_id_ex   ),
        .br_taken   ( br_taken      )   
    );



    reg_ex_to_mem reg_ex_to_mem_i
    (
        .clk(clk                            ),
        .rst(rst                            ),
        .flush_id_ex(flush_id_ex            ),
        .pc_out_ex(pc_out_ex                ),
        .pc_out_mem(pc_out_mem              ),
        .opr_res_im_wb(opr_res_im_wb        ),
        .opr_res_id_ex(opr_res_id_ex        ),
        .rdata2_im_wb(rdata2_im_wb          ),
        .rdata2_id_ex(rdata2_id_ex          ),
        .rd_im_wb(rd_im_wb                  ),
        .rd_id_ex(rd_id_ex                  ),
        .inst_mem_wb(inst_mem_wb            ),
        .inst_ex(inst_ex                    ),
        .rf_en_im_wb(rf_en_im_wb            ),
        .rf_en_id_ex(rf_en_id_ex            ),
        .sel_wb_im_wb(sel_wb_im_wb          ),
        .sel_wb_id_ex(sel_wb_id_ex          ),
        .wr_en_im_wb(wr_en_im_wb            ),
        .wr_en_id_ex(wr_en_id_ex            ),
        .rd_en_im_wb(rd_en_im_wb            ),
        .rd_en_id_ex(rd_en_id_ex            ),
        .mem_type_im_wb(mem_type_im_wb      ),
        .mem_type_id_ex(mem_type_id_ex      ),
        .is_mret_im_wb(is_mret_im_wb        ),
        .is_mret_id_ex(is_mret_id_ex        ),
        .csr_rd_im_wb(csr_rd_im_wb          ), 
        .csr_rd_id_ex(csr_rd_id_ex          ),
        .csr_wr_im_wb(csr_wr_im_wb          ),
        .csr_wr_id_ex(csr_wr_id_ex          )
    );

// ------------------------MEMORY------------------------------

    data_mem data_mem_i
    (
        .clk       ( clk            ),
        .rd_en     ( rd_en_im_wb    ),
        .wr_en     ( wr_en_im_wb    ),
        .mem_type  ( mem_type_im_wb ),
        .addr      ( opr_res_im_wb  ),
        .wdata     ( rdata2_im_wb   ),
        .rdata     ( rdata          )
    );

    csr_reg csr_reg_i
    (
        .clk       ( clk             ),
        .rst       ( rst             ),
        .addr      ( opr_res_im_wb   ),
        .wdata     ( rdata2_im_wb    ),
        .pc        ( pc_out_mem    ),
        .csr_rd    ( csr_rd_im_wb    ),
        .csr_wr    ( csr_wr_im_wb    ),
        .inst      ( inst_mem_wb      ),
        .rdata     ( csr_rdata       )
    );

    interupt interupt_i
    (
        .is_mret    ( is_mret        ),    
        .tm_interupt( interupt       ),        
        .epc        ( epc            ),
        .epc_taken  ( epc_taken      ),    
        .excep      ( excep          )
    );

// -----------------------WRITEBACK----------------------------

    always_comb
    begin
        case(sel_wb_im_wb)
            2'b00: wdata = opr_res_im_wb;
            2'b01: wdata = rdata;
            2'b10: wdata = pc_out_mem + 32'd4;
            2'b11: wdata = csr_rdata;
            default:
            begin
                wdata = 32'b0;
            end
        endcase
    end

endmodule