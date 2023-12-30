module reg_file (
    input  logic        clk,
    // input  logic        rst,
    input  logic        rf_en,
    input  logic [ 4:0] rs2,
    input  logic [ 4:0] rs1,
    input  logic [ 4:0] rd,
    input  logic [31:0] wdata,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);
    
    logic [31:0] reg_mem [0:31];

    // integer i;

    // always_comb
    // begin
    //     if (rst)
    //     begin
    //     for (i = 0; i < 32; i = i+1)
    //     begin
    //         reg_mem[i] = 0;
    //     end
    //     end        
    // end
    
    //ASYNCHRONUS READ
    always_comb 
    begin 
        rdata1 = reg_mem[rs1];
        rdata2 = reg_mem[rs2];
    end
    
    //SYNCHRONUS WRITE
    always_ff @(posedge clk) 
    begin
        if (rf_en)
        begin
            if (reg_mem[0] != rd)
            begin
                reg_mem[rd] <= wdata;
            end
        end
    end
    
endmodule