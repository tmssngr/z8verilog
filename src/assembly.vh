`ifdef BENCH
reg[15:0] memPC = 0;

`include "jump_conditions.vh"

task label;
    input [15:0] addr;
    begin
        $fwrite(file, "// label\n");
        if (addr != memPC) begin
            $display("%m expected label at %h", memPC);
            $finish(0);
        end
    end
endtask

task _asm_;
    input [7:0] a;
    begin
        $fwrite(file, "memory[16'h%h] = 8'h%h;\n", memPC, a);
        memory[memPC] = a;
        memPC = memPC + 1;
    end
endtask

task asm1;
    input [7:0] a;
    begin
        _asm_(a);
        $fwrite(file, "\n");
    end
endtask

task asm2;
    input [7:0] a;
    input [7:0] b;
    begin
        _asm_(a);
        _asm_(b);
        $fwrite(file, "\n");
    end
endtask

task asm3;
    input [7:0] a;
    input [7:0] b;
    input [7:0] c;
    begin
        _asm_(a);
        _asm_(b);
        _asm_(c);
        $fwrite(file, "\n");
    end
endtask

task default_interrupt_vectors;
    begin
        asm2('h8, 0);
        asm2('h8, 3);
        asm2('h8, 6);
        asm2('h8, 9);
        asm2('h8, 'hC);
        asm2('h8, 'hF);
    end
endtask

task asm_nop;
    begin
        asm1('hFF);
    end
endtask

task asm_rcf;
    begin
        asm1('hCF);
    end
endtask

task asm_scf;
    begin
        asm1('hDF);
    end
endtask

task asm_ccf;
    begin
        asm1('hEF);
    end
endtask

task asm_ld_r_R;
    input [3:0] dst;
    input [7:0] src;
    begin
        asm2({dst, 4'h8}, src);
    end
endtask
task asm_ld_r_IM;
    input [3:0] dst;
    input [7:0] src;
    begin
        asm2({dst, 4'hC}, src);
    end
endtask
task asm_ld_R_IM;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3(8'hE6, dst, src);
    end
endtask
task asm_ld_R_R;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3(8'hE4, src, dst);
    end
endtask
task asm_ld_R_IR;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3(8'hE5, src, dst);
    end
endtask
task asm_ld_IR_R;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3(8'hF5, src, dst);
    end
endtask

task asm_alu2_r_r;
    input [5:0] op;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2({op[4:0], 4'h2}, {dst, src});
    end
endtask
task asm_alu2_r_Ir;
    input [5:0] op;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2({op[4:0], 4'h3}, {dst, src});
    end
endtask
task asm_alu2_R_R;
    input [5:0] op;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3({op[4:0], 4'h4}, src, dst);
    end
endtask
task asm_alu2_R_IR;
    input [5:0] op;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3({op[4:0], 4'h5}, src, dst);
    end
endtask
task asm_alu2_R_IM;
    input [5:0] op;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3({op[4:0], 4'h6}, dst, src);
    end
endtask
task asm_alu2_IR_IM;
    input [5:0] op;
    input [7:0] dst;
    input [7:0] src;
    begin
        asm3({op[4:0], 4'h7}, dst, src);
    end
endtask

task asm_jr;
    input [3:0] condition;
    input [15:0] addr;
    integer ra;
    begin
        $fwrite(file, "// jr %h\n", addr);
        ra = addr - memPC - 2;
        asm2({ condition, 4'hB }, ra);
    end
endtask
task asm_jp;
    input [3:0] condition;
    input [15:0] addr;
    begin
        $fwrite(file, "// jp %h\n", addr);
        asm3({ condition, 4'hD }, addr[15:8], addr[7:0]);
    end
endtask
task asm_jp_IRR;
    input [7:0] irr;
    begin
        $fwrite(file, "// jp @%h\n", irr);
        asm2(8'h30, irr);
    end
endtask
task asm_djnz;
    input [3:0] dst;
    input [15:0] addr;
    integer ra;
    begin
        $fwrite(file, "// djnz %h\n", addr);
        ra = addr - memPC - 2;
        asm2({ dst, 4'hA }, ra);
    end
endtask

task asm_srp;
    input [7:0] dst;
    begin
        asm2(8'h31, dst);
    end
endtask
task asm_dec;
    input [7:0] dst;
    begin
        asm2(8'h00, dst);
    end
endtask
task asm_decIn;
    input [7:0] dst;
    begin
        asm2(8'h01, dst);
    end
endtask
task asm_rlc;
    input [7:0] dst;
    begin
        asm2(8'h10, dst);
    end
endtask
task asm_inc;
    input [7:0] dst;
    begin
        asm2(8'h20, dst);
    end
endtask
task asm_inc_r;
    input [3:0] dst;
    begin
        asm1({dst, 4'hE});
    end
endtask
task asm_da;
    input [7:0] dst;
    begin
        asm2(8'h40, dst);
    end
endtask
task asm_com;
    input [7:0] dst;
    begin
        asm2(8'h60, dst);
    end
endtask
task asm_decw;
    input [7:0] dst;
    begin
        asm2(8'h80, dst);
    end
endtask
task asm_decw_IRR;
    input [7:0] dst;
    begin
        asm2(8'h81, dst);
    end
endtask
task asm_rl;
    input [7:0] dst;
    begin
        asm2(8'h90, dst);
    end
endtask
task asm_incw;
    input [7:0] dst;
    begin
        asm2(8'hA0, dst);
    end
endtask
task asm_incw_IRR;
    input [7:0] dst;
    begin
        asm2(8'hA1, dst);
    end
endtask
task asm_clr;
    input [7:0] dst;
    begin
        asm2(8'hB0, dst);
    end
endtask
task asm_rrc;
    input [7:0] dst;
    begin
        asm2(8'hC0, dst);
    end
endtask
task asm_sra;
    input [7:0] dst;
    begin
        asm2(8'hD0, dst);
    end
endtask
task asm_rr;
    input [7:0] dst;
    begin
        asm2(8'hE0, dst);
    end
endtask
task asm_swap;
    input [7:0] dst;
    begin
        asm2(8'hF0, dst);
    end
endtask
task asm_push;
    input [7:0] src;
    begin
        asm2(8'h70, src);
    end
endtask
task asm_pushIn;
    input [7:0] src;
    begin
        asm2(8'h71, src);
    end
endtask
task asm_pop;
    input [7:0] dst;
    begin
        asm2(8'h50, dst);
    end
endtask
task asm_popIn;
    input [7:0] dst;
    begin
        asm2(8'h51, dst);
    end
endtask

task asm_ldc_r_Irr;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'hC2, { dst, src});
    end
endtask
task asm_ldc_Irr_r;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'hD2, { src, dst});
    end
endtask
task asm_ldci_Ir_Irr;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'hC3, { dst, src});
    end
endtask
task asm_ldci_Irr_Ir;
    input [3:0] dst;
    input [3:0] src;
    begin
        asm2(8'hD3, { src, dst});
    end
endtask

task asm_call;
    input [15:0] addr;
    begin
        asm3(8'hD6, addr[15:8], addr[7:0]);
    end
endtask
task asm_call_IRR;
    input [7:0] rr;
    begin
        asm2(8'hD4, rr);
    end
endtask
task asm_ret;
    begin
        asm1(8'hAF);
    end
endtask
task asm_iret;
    begin
        asm1(8'hBF);
    end
endtask
`endif
