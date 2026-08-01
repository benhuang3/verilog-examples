`timescale 1ns/10ps
`include "fifo.v"

//
// Self-checking testbench for fifo.v
//
// The FIFO under test is compared against a behavioral reference queue kept
// here in the testbench.  Every cycle the TB checks:
//     - empty  == (reference count == 0)
//     - full   == (reference count == DEPTH)
//     - r_data == value at the head of the reference queue (when not empty)
//
// Assumed spec (matches "stops writing when full, stops reading when empty"):
//     - a write is accepted only if the FIFO is not full at that clock edge
//     - a read  is accepted only if the FIFO is not empty at that clock edge
//     - wr & rd are evaluated independently, so on a full FIFO a simultaneous
//       wr+rd reads one word and drops the write, and on an empty FIFO it
//       writes one word and drops the read
//     - r_data continuously shows the head word (read-through, no rd needed)
//
module fifo_tb();

    localparam T     = 20;          // clock period
    localparam B     = 8;           // data width
    localparam W     = 2;           // address bits
    localparam DEPTH = 1 << W;      // 4 words -> easy to hit full/empty

    reg              clk, reset;
    reg              wr, rd;
    reg  [B-1:0]     w_data;
    wire             empty, full;
    wire [B-1:0]     r_data;

    fifo #(.B(B), .W(W)) uut (
        .clk(clk), .reset(reset),
        .wr(wr), .rd(rd),
        .w_data(w_data),
        .empty(empty), .full(full),
        .r_data(r_data)
    );

    // ---------------- reference model ----------------
    reg [B-1:0] model_q [0:DEPTH-1];
    integer     m_head, m_tail, m_cnt;

    integer     errors, checks;
    integer     i, k, s, seed;
    reg [B-1:0] expected;

    // ---------------- per-section bookkeeping ----------------
    integer        sec_err0, sec_started, nsec;
    reg [8*48-1:0] sec_names [0:31];
    integer        sec_errs  [0:31];

    // ---------------- clock ----------------
    always begin
        clk = 1'b1;
        #(T/2);
        clk = 1'b0;
        #(T/2);
    end

    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);
    end

    // ---------------- checkers ----------------
    task check_flags;
        begin
            checks = checks + 1;
            if (empty !== (m_cnt == 0)) begin
                errors = errors + 1;
                $display("[%6t] ERROR empty=%b expected=%b (count=%0d)",
                         $time, empty, (m_cnt == 0), m_cnt);
            end
            if (full !== (m_cnt == DEPTH)) begin
                errors = errors + 1;
                $display("[%6t] ERROR full=%b expected=%b (count=%0d)",
                         $time, full, (m_cnt == DEPTH), m_cnt);
            end
        end
    endtask

    task check_rdata;
        begin
            checks = checks + 1;
            expected = model_q[m_head];
            if (r_data !== expected) begin
                errors = errors + 1;
                $display("[%6t] ERROR r_data=%h expected=%h (count=%0d)",
                         $time, r_data, expected, m_cnt);
            end
        end
    endtask

    // ---------------- one clock cycle of stimulus ----------------
    // Call at a negedge; returns at the next negedge.
    task cycle;
        input        wr_i;
        input        rd_i;
        input [B-1:0] data_i;
        reg          do_wr, do_rd;
        begin
            wr     = wr_i;
            rd     = rd_i;
            w_data = data_i;

            #(T/4);                     // let outputs settle before sampling
            check_flags;
            if (m_cnt > 0) check_rdata; // head word must be visible

            do_wr = wr_i & (m_cnt < DEPTH);
            do_rd = rd_i & (m_cnt > 0);

            @(posedge clk);

            if (do_rd) begin
                m_head = (m_head + 1) % DEPTH;
                m_cnt  = m_cnt - 1;
            end
            if (do_wr) begin
                model_q[m_tail] = data_i;
                m_tail = (m_tail + 1) % DEPTH;
                m_cnt  = m_cnt + 1;
            end

            @(negedge clk);
        end
    endtask

    task idle;
        input integer n;
        begin
            for (k = 0; k < n; k = k + 1) cycle(1'b0, 1'b0, {B{1'bx}});
        end
    endtask

    // Close the previous section (if any) and open a new one.
    task section;
        input [8*48-1:0] nm;
        begin
            if (sec_started) begin
                sec_errs[nsec] = errors - sec_err0;
                nsec = nsec + 1;
            end
            sec_names[nsec] = nm;
            sec_err0        = errors;
            sec_started     = 1;
            $display("-- %0s --", nm);
        end
    endtask

    // Close the final section.
    task end_sections;
        begin
            if (sec_started) begin
                sec_errs[nsec] = errors - sec_err0;
                nsec           = nsec + 1;
                sec_started    = 0;
            end
        end
    endtask

    task do_reset;
        begin
            wr = 1'b0; rd = 1'b0; w_data = {B{1'b0}};
            reset = 1'b0;               // guarantee a clean 0->1 edge
            #(T/4);
            reset = 1'b1;
            #(T);
            reset = 1'b0;
            m_head = 0; m_tail = 0; m_cnt = 0;
            @(negedge clk);
        end
    endtask

    // ---------------- test program ----------------
    initial begin
        errors      = 0;
        checks      = 0;
        seed        = 32'hfeed_face;
        nsec        = 0;
        sec_started = 0;

        $display("=== fifo_tb: B=%0d W=%0d DEPTH=%0d ===", B, W, DEPTH);

        // -------- 1. reset and idle --------
        section("1. reset / idle");
        do_reset;
        idle(3);

        // -------- 2. fill to full, then overflow --------
        section("2. fill then overflow");
        for (i = 0; i < DEPTH; i = i + 1)
            cycle(1'b1, 1'b0, 8'hA0 + i[B-1:0]);
        // FIFO is full here; these writes must be dropped
        cycle(1'b1, 1'b0, 8'hEE);
        cycle(1'b1, 1'b0, 8'hEF);
        idle(1);

        // -------- 3. drain to empty, then underflow --------
        section("3. drain then underflow");
        for (i = 0; i < DEPTH; i = i + 1)
            cycle(1'b0, 1'b1, {B{1'bx}});
        // FIFO is empty here; these reads must be dropped
        cycle(1'b0, 1'b1, {B{1'bx}});
        cycle(1'b0, 1'b1, {B{1'bx}});
        idle(1);

        // -------- 4. simultaneous read+write, partially filled --------
        section("4. concurrent rd+wr, partially filled");
        cycle(1'b1, 1'b0, 8'h11);
        cycle(1'b1, 1'b0, 8'h22);
        for (i = 0; i < 6; i = i + 1)
            cycle(1'b1, 1'b1, 8'h30 + i[B-1:0]);
        // drain whatever is left and confirm ordering
        for (i = 0; i < DEPTH; i = i + 1)
            cycle(1'b0, 1'b1, {B{1'bx}});
        idle(1);

        // -------- 5. concurrent rd+wr at the boundaries --------
        section("5. concurrent rd+wr while empty / full");
        do_reset;
        cycle(1'b1, 1'b1, 8'h5A);        // empty: write takes, read dropped
        idle(1);
        for (i = 0; i < DEPTH - 1; i = i + 1)
            cycle(1'b1, 1'b0, 8'h60 + i[B-1:0]);
        cycle(1'b1, 1'b1, 8'h7F);        // full: read takes, write dropped
        idle(1);
        for (i = 0; i < DEPTH; i = i + 1)
            cycle(1'b0, 1'b1, {B{1'bx}});
        idle(1);

        // -------- 6. pointer wrap-around --------
        section("6. pointer wrap-around");
        do_reset;
        for (i = 0; i < 3 * DEPTH + 1; i = i + 1) begin
            cycle(1'b1, 1'b0, 8'h80 + i[B-1:0]);
            cycle(1'b0, 1'b1, {B{1'bx}});
        end
        // half-fill, wrap, then drain
        for (i = 0; i < DEPTH - 1; i = i + 1)
            cycle(1'b1, 1'b0, 8'hC0 + i[B-1:0]);
        for (i = 0; i < DEPTH + 4; i = i + 1)
            cycle(1'b0, 1'b1, {B{1'bx}});
        idle(1);

        // -------- 7. random soak --------
        section("7. random soak");
        do_reset;
        for (i = 0; i < 400; i = i + 1)
            cycle($random(seed), $random(seed), $random(seed));
        idle(1);

        // -------- 8. async reset while holding data --------
        section("8. async reset with data in flight");
        do_reset;
        for (i = 0; i < DEPTH - 1; i = i + 1)
            cycle(1'b1, 1'b0, 8'hD0 + i[B-1:0]);
        do_reset;                        // must come back empty, not full
        idle(2);
        cycle(1'b1, 1'b0, 8'h99);        // and still work afterwards
        cycle(1'b0, 1'b1, {B{1'bx}});
        idle(2);

        // -------- summary --------
        end_sections;
        $display("");
        $display("=== section summary ===");
        for (s = 0; s < nsec; s = s + 1)
            $display("  [%0s] %0s (%0d errors)",
                     sec_errs[s] == 0 ? "PASS" : "FAIL",
                     sec_names[s], sec_errs[s]);
        $display("");
        $display("=== done: %0d checks, %0d errors ===", checks, errors);
        if (errors == 0) $display("=== OVERALL: PASS ===");
        else             $display("=== OVERALL: FAIL ===");
        $finish;
    end

endmodule
