module reg_ex_to_mem (
    input logic [31:0] pc_out_ex,
    input logic [31:0] opr_res_id_ex,
    input logic [31:0] rdata2_id_ex,
    input logic [4:0] rd_id_ex,
    input logic [31:0] inst_ex,
    input logic rf_en_id_ex,
    input logic [1:0] sel_wb_id_ex,
    input logic wr_en_id_ex,
    input logic rd_en_id_ex,
    input logic [2:0] mem_type_id_ex,
    input logic is_mret_id_ex,
    input logic csr_rd_id_ex,
    input logic csr_wr_id_ex,
    input logic rst,
    input logic flush_id_ex,
    input logic clk,

    output  logic [31:0] pc_out_mem,
    output logic  [31:0] opr_res_im_wb,
    output logic [31:0] rdata2_im_wb,
    output logic [4:0] rd_im_wb,
    output logic [31:0] inst_mem_wb,
    output logic rf_en_im_wb,
    output logic [1:0] sel_wb_im_wb,
    output logic wr_en_im_wb,
    output logic rd_en_im_wb,
    output logic [2:0] mem_type_im_wb,
    output logic is_mret_im_wb,
    output logic csr_rd_im_wb,
    output logic csr_wr_im_wb
);
    
    always_ff @(posedge clk) 
    begin
        if (rst | flush_id_ex)
        begin
            pc_out_mem <= 0;
            opr_res_im_wb <= 0;
            rdata2_im_wb <= 0;
            rd_im_wb <= 0;
            inst_mem_wb <= 0;

            // Control Signals
            rf_en_im_wb <= 0;
            sel_wb_im_wb <= 0;
            wr_en_im_wb <= 0;
            rd_en_im_wb <= 0;
            mem_type_im_wb <= 0;
            is_mret_im_wb <= 0;
            csr_rd_im_wb <= 0;
            csr_wr_im_wb <= 0;
        end
        else
        begin
            pc_out_mem <= pc_out_ex;
            opr_res_im_wb <= opr_res_id_ex;
            rdata2_im_wb <= rdata2_id_ex;
            rd_im_wb <= rd_id_ex;
            inst_mem_wb <= inst_ex;

            // Control Signals
            rf_en_im_wb <= rf_en_id_ex;
            sel_wb_im_wb <= sel_wb_id_ex;
            wr_en_im_wb <= wr_en_id_ex;
            rd_en_im_wb <= rd_en_id_ex;
            mem_type_im_wb <= mem_type_id_ex;
            is_mret_im_wb <= is_mret_id_ex;
            csr_rd_im_wb <= csr_rd_id_ex;
            csr_wr_im_wb <= csr_wr_id_ex;
        end
    end

    
endmodule