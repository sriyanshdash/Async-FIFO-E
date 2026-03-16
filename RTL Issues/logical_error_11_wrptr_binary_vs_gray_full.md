# [ASYNC_FIFO][RTL][ERR_011][wrptr_handler.sv][LINE_58][LOGICAL] Full-flag comparison uses binary pointer instead of gray-coded pointer

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 58 of `wrptr_handler.sv` compares the binary write pointer `b_wptr_next` against the inverted MSBs of the synchronized gray-coded read pointer `g_rptr_sync`. The full condition requires comparing gray-coded values; mixing binary with gray produces an incorrect full flag.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `wptr_handler` (write pointer handler)
- **File name:** `rtl/wrptr_handler.sv`
- **Line affected:** 58

---

## --- ANALYSIS ---

- The FIFO full condition is determined by comparing the next gray-coded write pointer with the synchronized gray-coded read pointer (with the top two MSBs inverted). Using the binary write pointer `b_wptr_next` in this comparison is fundamentally wrong because the read pointer `g_rptr_sync` is in the gray-code domain.
- This mismatch means the full flag will assert at incorrect times, potentially allowing writes to a full FIFO (data corruption) or blocking writes prematurely.
- **Buggy:** `assign wfull = (b_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});`
- **Fix:** `assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/wrptr_handler.sv`
- **Line number:** 58
