cat isi.s tests/m4.s > exe.s
1521 spim -file exe.s | sed -e 1d
