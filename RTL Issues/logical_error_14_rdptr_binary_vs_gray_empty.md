# [ASYNC_FIFO][RTL][ERR_014][rdptr_handler.sv][LINE_38][LOGICAL] Empty-flag compares gray-coded write pointer against binary read pointer instead of gray-coded read pointer

**Error Type:** Logical Error

---

## --- SUMMARY ---

- Line 38 of `rdptr_handler.sv` compares `g_wptr_sync` (gray-coded) with `b_rptr_next` (binary) to determine the empty flag. The empty condition requires comparing two gray-coded pointers; mixing domains produces an unreliable empty flag.

---

## --- PURPOSE/SETTINGS ---

- **Design module:** `rptr_handler` (read pointer handler)
- **File name:** `rtl/rdptr_handler.sv`
- **Line affected:** 38

---

## --- ANALYSIS ---

- The FIFO empty condition is determined by comparing the synchronized gray-coded write pointer with the next gray-coded read pointer. Using the binary read pointer `b_rptr_next` in this comparison is incorrect because `g_wptr_sync` is in the gray-code domain.
- This domain mismatch means the empty flag will assert at incorrect times, potentially allowing reads from an empty FIFO (stale/garbage data) or blocking reads when data is available.
- **Buggy:** `assign rempty = (g_wptr_sync == b_rptr_next);`
- **Fix:** `assign rempty = (g_wptr_sync == g_rptr_next);`

---

## --- OTHER TEST INFORMATION ---

- **File path:** `rtl/rdptr_handler.sv`
- **Line number:** 38
