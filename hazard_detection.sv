module hazard_detection (
    input  logic       rf_en,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd,
    output logic       for_a,
    output logic       for_b,

    //For Load Stall
    input  logic [1:0] sel_wb,
    output logic       stall_if,
    output logic       stall_id_ex,
    output logic       flush_id_ex,

    //For Branch stall
    input  logic       br_taken

);
    
    logic stall_lw;


    always_comb
    begin
        if (((rs1 == rd) & rf_en) & (rs1 != 0))
        begin 
            for_a = 1'b1;
        end
        else 
        begin
            for_a = 1'b0;
        end
    end

    always_comb
    begin
        if (((rs2 == rd) & rf_en) & (rs2 != 0))
        begin 
            for_b = 1'b1;
        end
        else 
        begin
            for_b = 1'b0;
        end
    end

    always_comb
    begin
        if((sel_wb == 2'b01) & ((rs1 == rd) | (rs2 == rd)))
        begin
            stall_lw = 1'b1;
        end
        else
        begin
            stall_lw = 1'b0;
        end
    end

    assign stall_if    = stall_lw;
    assign stall_id_ex = stall_lw;

    assign flush_id_ex = (stall_lw | br_taken);

endmodule