module dct_1d_top (
    input  wire        clk,
    input  wire        rst,
    input  wire [2:0]  addr,
    input  wire signed [15:0] data_in,
    input  wire        write_en,
    output reg  signed [31:0] data_out
);

// Input registers
reg signed [15:0] x0, x1, x2, x3, x4, x5, x6, x7;

// Pipeline registers
reg signed [47:0] mac0, mac1, mac2, mac3, mac4, mac5, mac6, mac7;
reg signed [15:0] y0, y1, y2, y3, y4, y5, y6, y7;

// Q10 cosine coefficients
// Row k=0
localparam signed [15:0] C00 =  16'sd724;
localparam signed [15:0] C01 =  16'sd724;
localparam signed [15:0] C02 =  16'sd724;
localparam signed [15:0] C03 =  16'sd724;
localparam signed [15:0] C04 =  16'sd724;
localparam signed [15:0] C05 =  16'sd724;
localparam signed [15:0] C06 =  16'sd724;
localparam signed [15:0] C07 =  16'sd724;
// Row k=1
localparam signed [15:0] C10 =  16'sd1004;
localparam signed [15:0] C11 =  16'sd851;
localparam signed [15:0] C12 =  16'sd569;
localparam signed [15:0] C13 =  16'sd200;
localparam signed [15:0] C14 = -16'sd200;
localparam signed [15:0] C15 = -16'sd569;
localparam signed [15:0] C16 = -16'sd851;
localparam signed [15:0] C17 = -16'sd1004;
// Row k=2
localparam signed [15:0] C20 =  16'sd946;
localparam signed [15:0] C21 =  16'sd392;
localparam signed [15:0] C22 = -16'sd392;
localparam signed [15:0] C23 = -16'sd946;
localparam signed [15:0] C24 = -16'sd946;
localparam signed [15:0] C25 = -16'sd392;
localparam signed [15:0] C26 =  16'sd392;
localparam signed [15:0] C27 =  16'sd946;
// Row k=3
localparam signed [15:0] C30 =  16'sd851;
localparam signed [15:0] C31 = -16'sd200;
localparam signed [15:0] C32 = -16'sd1004;
localparam signed [15:0] C33 = -16'sd569;
localparam signed [15:0] C34 =  16'sd569;
localparam signed [15:0] C35 =  16'sd1004;
localparam signed [15:0] C36 =  16'sd200;
localparam signed [15:0] C37 = -16'sd851;
// Row k=4
localparam signed [15:0] C40 =  16'sd724;
localparam signed [15:0] C41 = -16'sd724;
localparam signed [15:0] C42 = -16'sd724;
localparam signed [15:0] C43 =  16'sd724;
localparam signed [15:0] C44 =  16'sd724;
localparam signed [15:0] C45 = -16'sd724;
localparam signed [15:0] C46 = -16'sd724;
localparam signed [15:0] C47 =  16'sd724;
// Row k=5
localparam signed [15:0] C50 =  16'sd569;
localparam signed [15:0] C51 = -16'sd1004;
localparam signed [15:0] C52 =  16'sd200;
localparam signed [15:0] C53 =  16'sd851;
localparam signed [15:0] C54 = -16'sd851;
localparam signed [15:0] C55 = -16'sd200;
localparam signed [15:0] C56 =  16'sd1004;
localparam signed [15:0] C57 = -16'sd569;
// Row k=6
localparam signed [15:0] C60 =  16'sd392;
localparam signed [15:0] C61 = -16'sd946;
localparam signed [15:0] C62 =  16'sd946;
localparam signed [15:0] C63 = -16'sd392;
localparam signed [15:0] C64 = -16'sd392;
localparam signed [15:0] C65 =  16'sd946;
localparam signed [15:0] C66 = -16'sd946;
localparam signed [15:0] C67 =  16'sd392;
// Row k=7
localparam signed [15:0] C70 =  16'sd200;
localparam signed [15:0] C71 = -16'sd569;
localparam signed [15:0] C72 =  16'sd851;
localparam signed [15:0] C73 = -16'sd1004;
localparam signed [15:0] C74 =  16'sd1004;
localparam signed [15:0] C75 = -16'sd851;
localparam signed [15:0] C76 =  16'sd569;
localparam signed [15:0] C77 = -16'sd200;

// State machine
localparam IDLE    = 2'd0;
localparam COMPUTE = 2'd1;
localparam OUTPUT  = 2'd2;

reg [1:0] state;

// Track when all 8 pixels written
reg [7:0] written_mask;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state        <= IDLE;
        written_mask <= 8'h00;
        data_out     <= 0;
        x0<=0; x1<=0; x2<=0; x3<=0;
        x4<=0; x5<=0; x6<=0; x7<=0;
        y0<=0; y1<=0; y2<=0; y3<=0;
        y4<=0; y5<=0; y6<=0; y7<=0;
    end else begin

        // Read results - sign extend 16-bit output to 32 bits
        case (addr)
            3'd0: data_out <= {{16{y0[15]}}, y0};
            3'd1: data_out <= {{16{y1[15]}}, y1};
            3'd2: data_out <= {{16{y2[15]}}, y2};
            3'd3: data_out <= {{16{y3[15]}}, y3};
            3'd4: data_out <= {{16{y4[15]}}, y4};
            3'd5: data_out <= {{16{y5[15]}}, y5};
            3'd6: data_out <= {{16{y6[15]}}, y6};
            3'd7: data_out <= {{16{y7[15]}}, y7};
        endcase

        // Write pixels and track which ones received
        if (write_en) begin
            case (addr)
                3'd0: begin x0 <= data_in; written_mask[0] <= 1; end
                3'd1: begin x1 <= data_in; written_mask[1] <= 1; end
                3'd2: begin x2 <= data_in; written_mask[2] <= 1; end
                3'd3: begin x3 <= data_in; written_mask[3] <= 1; end
                3'd4: begin x4 <= data_in; written_mask[4] <= 1; end
                3'd5: begin x5 <= data_in; written_mask[5] <= 1; end
                3'd6: begin x6 <= data_in; written_mask[6] <= 1; end
                3'd7: begin x7 <= data_in; written_mask[7] <= 1; end
            endcase
        end

        case (state)
            IDLE: begin
                if (written_mask == 8'hFF) begin
                    written_mask <= 8'h00;
                    state <= COMPUTE;
                end
            end

            COMPUTE: begin
                mac0 <= x0*C00 + x1*C01 + x2*C02 + x3*C03 +
                        x4*C04 + x5*C05 + x6*C06 + x7*C07;
                mac1 <= x0*C10 + x1*C11 + x2*C12 + x3*C13 +
                        x4*C14 + x5*C15 + x6*C16 + x7*C17;
                mac2 <= x0*C20 + x1*C21 + x2*C22 + x3*C23 +
                        x4*C24 + x5*C25 + x6*C26 + x7*C27;
                mac3 <= x0*C30 + x1*C31 + x2*C32 + x3*C33 +
                        x4*C34 + x5*C35 + x6*C36 + x7*C37;
                mac4 <= x0*C40 + x1*C41 + x2*C42 + x3*C43 +
                        x4*C44 + x5*C45 + x6*C46 + x7*C47;
                mac5 <= x0*C50 + x1*C51 + x2*C52 + x3*C53 +
                        x4*C54 + x5*C55 + x6*C56 + x7*C57;
                mac6 <= x0*C60 + x1*C61 + x2*C62 + x3*C63 +
                        x4*C64 + x5*C65 + x6*C66 + x7*C67;
                mac7 <= x0*C70 + x1*C71 + x2*C72 + x3*C73 +
                        x4*C74 + x5*C75 + x6*C76 + x7*C77;
                state <= OUTPUT;
            end

				OUTPUT: begin
					 y0 <= (mac0 + 48'sd1024) >>> 11;
					 y1 <= (mac1 + 48'sd1024) >>> 11;
					 y2 <= (mac2 + 48'sd1024) >>> 11;
					 y3 <= (mac3 + 48'sd1024) >>> 11;
					 y4 <= (mac4 + 48'sd1024) >>> 11;
					 y5 <= (mac5 + 48'sd1024) >>> 11;
					 y6 <= (mac6 + 48'sd1024) >>> 11;
					 y7 <= (mac7 + 48'sd1024) >>> 11;
					 state <= IDLE;
				end
        endcase
    end
end

endmodule