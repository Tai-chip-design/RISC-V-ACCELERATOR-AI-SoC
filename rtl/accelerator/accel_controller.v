module accel_controller (
    input clk, rst, start,
    output reg [4:0] t,
    output reg clear, enable, busy, done
);
    parameter cycle_total = 25;
    parameter IDLE = 2'b00;
    parameter RUN = 2'b01;
    parameter DONE = 2'b10;
    reg [1:0] state_reg, state_next;
    reg [4:0] t_reg, t_next;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state_reg <= IDLE;
            t_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            t_reg <= t_next;
        end
    end
    always @(*) begin
        state_next = state_reg;
        t_next = t_reg;
        case (state_reg)
            IDLE: begin
                t_next = 0;
                if(start == 1) begin
                    state_next = RUN;
                    t_next = 0;
                end
            end 
            RUN: begin
                if(t_reg == cycle_total-1) state_next = DONE;
                else t_next = t_reg + 1;
            end
            DONE: begin
                if(start == 0) begin
                    state_next = IDLE;
                    t_next = 0;
                end
            end
            default: begin
                state_next = IDLE;
                t_next = 0;
            end
        endcase
    end
    always @(*) begin
        clear = 0;
        enable = 0;
        busy = 0;
        done = 0;
        case (state_reg)
            IDLE: begin
                if(start == 1) begin
                    clear = 1;
                    enable = 1;
                    busy = 1;
                end
            end 
            RUN: begin
                clear = 0;
                enable = 1;
                busy = 1;
            end
            DONE: begin
                clear = 0;
                enable = 0;
                busy = 0;
                done = 1;
            end
            default: begin
                clear = 0;
                enable = 0;
                busy = 0;
                done = 0;
            end
        endcase
    end
    always @(*) begin
        t = t_reg;
    end
endmodule