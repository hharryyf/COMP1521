cat isi.s tests/m7.s > exe.s
1521 spim -file exe.s | sed -e 1d
