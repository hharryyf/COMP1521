cat isi.s tests/m1.s > exe.s
1521 spim -file exe.s | sed -e 1d
