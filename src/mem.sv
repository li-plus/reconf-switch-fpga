`include "def.svh"

// handle load & store
module mem (
    // connected to switch
    input wire ce,
    input wire we,
    input wire [`ADDR_BUS] addr_i,
    input wire [3:0] width_i,
    input wire [`DATA_BUS] data_i,  // data to write to sram
    output reg [`DATA_BUS] data_o,  // data read from sram

    // connected to sram
    output reg sram_ce,
    output reg sram_we,
    output reg [`ADDR_BUS] sram_addr_o,
    output reg [3:0] sram_sel_o,
    output reg [`DATA_BUS] sram_data_o,  // data to write to sram
    input wire [`DATA_BUS] sram_data_i   // data read from sram
);

    always @(*) begin
        assign sram_ce = ce;
        assign sram_we = we;
        assign sram_addr_o = addr_i;

        if (ce == `FALSE) begin
            sram_sel_o <= 4'b0000;
            sram_data_o <= `ZERO_WORD;
            data_o <= `ZERO_WORD;
        end else begin
            case (width_i)
            4'h1: begin
                if (we == `FALSE) begin
                    // load byte
                    sram_sel_o <= 4'b0000;
                    sram_data_o <= `ZERO_WORD;
                    case (addr_i[1:0])
                    2'b00: begin
                        data_o <= {24'h000000, sram_data_i[31:24]};
                    end
                    2'b01: begin
                        data_o <= {24'h000000, sram_data_i[23:16]};
                    end
                    2'b10: begin
                        data_o <= {24'h000000, sram_data_i[15:8]};
                    end
                    2'b11: begin
                        data_o <= {24'h000000, sram_data_i[7:0]};
                    end
                    default: ; // error
                    endcase
                end else begin
                    // store byte
                    data_o <= `ZERO_WORD;
                    sram_data_o <= {4{data_i[7:0]}};
                    case (addr_i[1:0])
                    2'b00: begin
                        sram_sel_o <= 4'b1000;
                    end
                    2'b01: begin
                        sram_sel_o <= 4'b0100;
                    end
                    2'b10: begin
                        sram_sel_o <= 4'b0010;
                    end
                    2'b11: begin
                        sram_sel_o <= 4'b0001;
                    end
                    default: ; // error
                    endcase
                end
            end
            4'h2: begin
                if (we == `FALSE) begin
                    // load half
                    sram_sel_o <= 4'b0000;
                    sram_data_o <= `ZERO_WORD;
                    case (addr_i[1:0])
                    2'b00: begin
                        data_o <= {16'h0000, sram_data_i[31:16]};
                    end
                    2'b10: begin
                        data_o <= {16'h0000, sram_data_i[15:0]};
                    end
                    default: ; // error
                    endcase
                end else begin
                    // store half
                    data_o <= `ZERO_WORD;
                    sram_data_o <= {2{data_i[15:0]}};
                    case (addr_i[1:0])
                    2'b00: begin
                        sram_sel_o <= 4'b1100;
                    end
                    2'b10: begin
                        sram_sel_o <= 4'b0011;
                    end
                    default: ; // error
                    endcase
                end
            end
            4'h4: begin
                if (we == `FALSE) begin
                    // load word
                    sram_sel_o <= 4'b0000;
                    sram_data_o <= `ZERO_WORD;
                    data_o <= sram_data_i;
                end else begin
                    // store word
                    sram_sel_o <= 4'b1111;
                    sram_data_o <= data_i;
                    data_o <= `ZERO_WORD;
                end
            end
            default: ; // error
            endcase
        end
    end

endmodule