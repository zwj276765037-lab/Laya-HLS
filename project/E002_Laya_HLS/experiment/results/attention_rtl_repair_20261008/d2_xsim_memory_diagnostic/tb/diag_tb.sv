`timescale 1ns/1ps

module diag_tb;
    import uvm_pkg::*;
    import file_agent_pkg::*;

    string mode, tv_path, raw_path, offset_path;
    string paths[$];
    integer widths[$];
    int depth, raw_fp, got, bad;
    reg [7:0] expected;
    logic [7:0] observed;
    file_read_agent#(8) reader;
    mem_model#(8) direct_mem;
    mem_model_pages_with_diffofst#(8,8) full_mem;

    task automatic verify_raw_file(string path);
        raw_fp = $fopen(path, "rb");
        if (raw_fp == 0) $fatal(1, "cannot open expected raw payload %s", path);
        for (int i=0; i<depth; i++) begin
            got = $fread(expected, raw_fp);
            if (got != 1) $fatal(1, "short expected raw payload at %0d: got %0d", i, got);
            if (mode == "Q") begin
                if (reader.TV_Queue[0][i] !== expected)
                    $fatal(1, "Q byte mismatch at %0d: %02x != %02x", i, reader.TV_Queue[0][i], expected);
            end else if (mode == "M") begin
                bad = direct_mem.read_one_elem(observed, i);
                if (bad != 0 || observed !== expected)
                    $fatal(1, "M byte mismatch at %0d: %02x != %02x bad=%0d", i, observed, expected, bad);
            end else begin
                bad = full_mem.pages[0].read_one_elem(observed, i);
                if (bad != 0 || observed !== expected)
                    $fatal(1, "F byte mismatch at %0d: %02x != %02x bad=%0d", i, observed, expected, bad);
            end
        end
        if ($fgetc(raw_fp) != -1) $fatal(1, "expected raw payload longer than depth=%0d", depth);
        $fclose(raw_fp);
        diag_stage("readback_verified", depth, 0);
    endtask

    initial begin
        if (!$value$plusargs("MODE=%s", mode) ||
            !$value$plusargs("DEPTH=%d", depth) ||
            !$value$plusargs("TV=%s", tv_path) ||
            !$value$plusargs("RAW=%s", raw_path) ||
            !$value$plusargs("OFFSET=%s", offset_path))
            $fatal(1, "missing diagnostic plusarg");
        if (depth != 1024 && depth != 4096 && depth != 16384 && depth != 65536)
            $fatal(1, "depth outside accepted ladder: %0d", depth);
        if (mode != "Q" && mode != "M" && mode != "F")
            $fatal(1, "unknown diagnostic mode: %s", mode);

        $display("DIAG_CONFIG mode=%s depth=%0d tv=%s raw=%s offset=%s", mode, depth, tv_path, raw_path, offset_path);
        diag_stage("process_baseline", depth, 0);
        if (mode == "Q") begin
            reader = new("diagnostic_reader");
            paths.push_back(tv_path);
            widths.push_back(8);
            reader.set_binary(1);
            reader.config_file(paths, widths);
            reader.read_TVIN_file();
            if (reader.TV_Queue.size() != 1 || reader.TV_Queue[0].size() != depth ||
                reader.diag_transactions != 1 || reader.diag_copy_elements != depth ||
                reader.diag_payload_bytes != depth || reader.diag_fread_bytes != depth+16 ||
                reader.diag_last_ftell != depth+16 || $fgetc(reader.fp) != -1)
                $fatal(1, "Q frame/queue/count mismatch: queue=%0d data=%0d tx=%0d copy=%0d fread=%0d payload=%0d ftell=%0d",
                       reader.TV_Queue.size(), reader.TV_Queue[0].size(), reader.diag_transactions,
                       reader.diag_copy_elements, reader.diag_fread_bytes, reader.diag_payload_bytes,
                       reader.diag_last_ftell);
            diag_stage("Q_frame_verified", depth, reader.diag_fread_bytes);
            verify_raw_file(raw_path);
        end else if (mode == "M") begin
            direct_mem = new("diagnostic_mem");
            direct_mem.init(depth);
            raw_fp = $fopen(raw_path, "rb");
            if (raw_fp == 0) $fatal(1, "cannot open raw payload");
            for (int i=0; i<depth; i++) begin
                got = $fread(expected, raw_fp);
                if (got != 1 || direct_mem.write_one_elem(expected, i) != 0)
                    $fatal(1, "M write mismatch at %0d", i);
            end
            if ($fgetc(raw_fp) != -1) $fatal(1, "M raw payload longer than depth");
            $fclose(raw_fp);
            diag_stage("M_after_writes", depth, 0);
            verify_raw_file(raw_path);
        end else begin
            full_mem = new("diagnostic_full_model");
            paths.push_back(tv_path);
            full_mem.whole_page_size = depth+16;
            full_mem.maxi_bundlevar_fpath["fixture_r"] = offset_path;
            full_mem.set_binary(1);
            full_mem.tvinload_pagechk_atinit(paths, depth, 0, 0);
            if (full_mem.pages.size() != 1 || full_mem.pages[0].depth != depth ||
                full_mem.diag_copy_count != depth ||
                !full_mem.maxi_bundlevar_offset.exists("fixture_r") ||
                full_mem.maxi_bundlevar_offset["fixture_r"] != 0)
                $fatal(1, "F page/copy/offset mismatch: pages=%0d copy=%0d", full_mem.pages.size(), full_mem.diag_copy_count);
            diag_stage("F_chain_verified", depth, full_mem.diag_copy_count);
            verify_raw_file(raw_path);
        end
        $display("DIAG_PASS mode=%s depth=%0d bytes=%0d", mode, depth, depth);
        $finish;
    end
endmodule
