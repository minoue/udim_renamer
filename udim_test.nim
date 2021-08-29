import std/unittest
import tables
import udim_convert
from sequtils import zip

let
    udim = [
        "1001", "1002", "1003", "1004", "1005", "1006", "1007", "1008", "1009", "1010",
        "1011", "1012", "1013", "1014", "1015", "1016", "1017", "1018", "1019", "1020",
        "1021", "1022", "1023", "1024", "1025", "1026", "1027", "1028", "1029", "1030",
        ]
    mudbox = [
        "_u1_v1", "_u2_v1", "_u3_v1", "_u4_v1", "_u5_v1", "_u6_v1", "_u7_v1", "_u8_v1", "_u9_v1", "_u10_v1",
        "_u1_v2", "_u2_v2", "_u3_v2", "_u4_v2", "_u5_v2", "_u6_v2", "_u7_v2", "_u8_v2", "_u9_v2", "_u10_v2",
        "_u1_v3", "_u2_v3", "_u3_v3", "_u4_v3", "_u5_v3", "_u6_v3", "_u7_v3", "_u8_v3", "_u9_v3", "_u10_v3",
        ]
    zbrush = [
        "_u0_v0", "_u1_v0", "_u2_v0", "_u3_v0", "_u4_v0", "_u5_v0", "_u6_v0", "_u7_v0", "_u8_v0", "_u9_v0",
        "_u0_v1", "_u1_v1", "_u2_v1", "_u3_v1", "_u4_v1", "_u5_v1", "_u6_v1", "_u7_v1", "_u8_v1", "_u9_v1",
        "_u0_v2", "_u1_v2", "_u2_v2", "_u3_v2", "_u4_v2", "_u5_v2", "_u6_v2", "_u7_v2", "_u8_v2", "_u9_v2",
        ]


suite "UDIM Conversion Check":

  echo "Setup: Run once before all tests in this suite."

  setup:
    echo "Setup: Run once before each test."

  teardown:
    echo "Teardown: Run once after each test."

  test "Mari to Mudbox":
    for pair in zip(udim, mudbox):
        let (u, m) = pair
        check(mariToMudbox(u) == m)

  test "Mari to ZBrush":
    for pair in zip(udim, zbrush):
        let (u, z) = pair
        check(mariToZBrush(u) == z)

  test "Mudbox to Mari":
    for pair in zip(mudbox, udim):
        let (m, u) = pair
        check(mudboxToMari(m) == u)

  test "Mudbox to ZBrush":
    for pair in zip(mudbox, zbrush):
        let (m, z) = pair
        check(mudboxToZBrush(m) == z)

  test "ZBrush to Mari":
    for pair in zip(zbrush, udim):
        let (z, u) = pair
        check(zbrushToMari(z) == u)

  test "ZBrush to Mudbox":
    for pair in zip(zbrush, mudbox):
        let (z, m) = pair
        check(zbrushToMudbox(z) == m)


  echo "Teardown: Run once after all tests in this suite."
