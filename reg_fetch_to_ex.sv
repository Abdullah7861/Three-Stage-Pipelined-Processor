module reg_fetch_to_ex(
    input logic clk,
    input logic rst,
    input logic flush_id_ex,
    input logic stall_id_ex,
    input  logic [31:0] inst_fetch,
    input logic [31:0] pc_out_fetch,
    output logic [31:0] inst_ex,
    output logic [31:0] pc_out_ex
);
    
    always_ff @(posedge clk) 
    begin
        if (rst)
        begin
            inst_ex   <= 0;
            pc_out_ex <= 0;
        end
        else if (flush_id_ex)
        begin
            inst_ex   <= 32'h00000033;
            pc_out_ex <= 1'b0;

        end
        else if (~stall_id_ex)
        begin
            inst_ex   <= inst_fetch;
            pc_out_ex <= pc_out_fetch;
        end
    end
    
endmodule