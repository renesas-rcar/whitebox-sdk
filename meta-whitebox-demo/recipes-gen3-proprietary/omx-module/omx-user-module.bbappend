require include/eval-pack.inc

FILESEXTRAPATHS_append := "${MM_EVA_L3_DIR}:"

do_fetch[depends] = "eval-pack:do_unpack"
