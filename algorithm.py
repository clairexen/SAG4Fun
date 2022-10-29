#!/usr/bin/env python3
#
# SAG4Fun
#
# Copyright (C) 2022 Claire Wolf <claire@clairexen.net>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

import random
import sys
import textwrap
import types

config = types.SimpleNamespace(
    enableDebug=True,
    enableRowShuffle=True,
)

def debug(*args):
    if config.enableDebug: print(*args)

class BitMaskSet:
    def __init__(self, N, depth, value=None, default=0):
        self.N = N
        self.depth = depth
        self.numRows = 1 << depth
        self.numCols = N >> depth
        self.data = [[default]*self.numCols for i in range(self.numRows)]
        if value is not None: self.set(value)

    def set(self, value):
        if type(value) is str:
            index = 0
            for i in reversed(range(self.N)):
                if value[index] in ("0", "1"):
                    self[i] = int(value[index])
                else:
                    self[i] = value[index]
                index += 1
                if i != 0 and i % self.numCols == 0 and value[index] == " ":
                    index += 1
            assert index == len(value)
            return

        if type(value) is BitMaskSet:
            assert self.N == value.N
            for i in range(self.N):
                self[i] = value[i]
            return

        assert False

    def __str__(self):
        s = list()
        for i in reversed(range(self.numRows)):
            for j in reversed(range(self.numCols)):
                s.append(str(self[i,j]))
            # if i != 0: s.append(" ")
        return "".join(s)

    def __eq__(self, other):
        return str(self) == str(other)

    def __ne__(self, other):
        return str(self) != str(other)

    def __getitem__(self, key):
        if type(key) is tuple:
            return self.data[key[0]][key[1]]
        return self.data[key // self.numCols][key % self.numCols]

    def __setitem__(self, key, value):
        if type(key) is tuple:
            self.data[key[0]][key[1]] = value
        else:
            self.data[key // self.numCols][key % self.numCols] = value

    def xorsum(self):
        result = BitMaskSet(self.N>>1, self.depth)
        for i in range(self.numRows):
            carry = 1
            for j in range(self.numCols>>1):
                result[i,j] = carry ^ self[i,2*j]
                carry = result[i,j] ^ self[i,2*j+1]
        return result

    def swap(self, mask):
        result = BitMaskSet(self.N, self.depth)
        if False:
            for i in range(self.numRows):
                for j in range(self.numCols>>1):
                    a, b = self[i,2*j], self[i,2*j+1]
                    if mask[i,j]: a, b = b, a
                    result[i,2*j], result[i,2*j+1] = a, b
        else:
            for i in range(self.N>>1):
                a, b = self[2*i], self[2*i+1]
                if mask[i]: a, b = b, a
                result[2*i], result[2*i+1] = a, b
        return result

    def split(self):
        assert self.numCols > 1
        result = BitMaskSet(self.N, self.depth+1)
        if config.enableRowShuffle and self.depth != 0:
            temp = BitMaskSet(self.N, 0, self)
            result.set(temp.split())
        else:
            for i in range(self.numRows):
                for j in range(self.numCols>>1):
                    result[2*i,j], result[2*i+1,j] = self[i,2*j], self[i,2*j+1]
        return result

    def merge(self):
        assert self.numRows > 1
        result = BitMaskSet(self.N, self.depth-1)
        if config.enableRowShuffle and self.depth != 1:
            temp = BitMaskSet(self.N, 1, self)
            result.set(temp.merge())
        else:
            for i in range(self.numRows>>1):
                for j in range(self.numCols):
                    result[i,2*j], result[i,2*j+1] = self[2*i,j], self[2*i+1,j]
        return result

    def mask(self, other, default=0):
        result = BitMaskSet(self.N, self.depth, default=default)
        for i in range(self.numRows):
            for j in range(self.numCols):
                if self[i,j]: result[i,j] = other[i,j]
        return result

    def inverse(self):
        result = BitMaskSet(self.N, self.depth)
        for i in range(self.numRows):
            for j in range(self.numCols):
                result[i,j] = 1-self[i,j]
        return result

class SAG4Fun:
    def __init__(self, N):
        self.N = N
        self.xcfg = [BitMaskSet(N, i) for i in range((N-1).bit_length())]
        self.extMask = BitMaskSet(N, 0)
        self.depMask = BitMaskSet(N, 0)

    def loadMask(self, value):
        M = BitMaskSet(self.N, 0, value)
        self.extMask = M

        for i in range((self.N-1).bit_length()):
            self.xcfg[i] = M.xorsum()
            debug(f"-x{i}", self.xcfg[i])
            M = M.swap(self.xcfg[i])
            M = M.split()

        if not config.enableRowShuffle:
            for i in range((self.N-1).bit_length()):
                M = M.merge()
        else:
                M = BitMaskSet(self.N, 0, M)
        self.depMask = M

    def SAG(self, value, mask=None):
        if mask is not None:
            self.loadMask(mask)

        D = BitMaskSet(self.N, 0, value)

        for i in range((self.N-1).bit_length()):
            D = D.swap(self.xcfg[i])
            D = D.split()
            debug(f"-d{i}", D)

        if not config.enableRowShuffle:
            for i in range((self.N-1).bit_length()):
                D = D.merge()
        else:
                D = BitMaskSet(self.N, 0, D)

        return D

    def ISG(self, value, mask=None):
        if mask is not None:
            self.loadMask(mask)

        if not config.enableRowShuffle:
            D = BitMaskSet(self.N, 0, value)
            for i in range((self.N-1).bit_length()):
                D = D.split()
        else:
            D = BitMaskSet(self.N, (self.N-1).bit_length(), value)

        for i in reversed(range((self.N-1).bit_length())):
            debug(f"-d{i}", D)
            D = D.merge()
            D = D.swap(self.xcfg[i])

        return D

    def EXT(self, value, mask=None):
        if mask is not None:
            self.loadMask(mask)
        D = BitMaskSet(self.N, 0, value)
        D = self.extMask.mask(D, "_")
        return self.SAG(D)

    def DEP(self, value, mask=None):
        if mask is not None:
            self.loadMask(mask)
        D = BitMaskSet(self.N, 0, value)
        D = self.depMask.mask(D, "_")
        return self.ISG(D)

def demo():
    config.enableDebug = True

    letters = "abcdefgh"
    numbers = "12345678"

    sag = SAG4Fun(8)

    for M in ["00110100", "01010110"]:
        print("M: ", M)
        sag.loadMask(M)

        I = ""
        l = letters[0:M.count("0")]
        n = numbers[0:M.count("1")]
        for i in range(8):
            if M[i] == "0":
                I += l[-1]
                l = l[0:-1]
            else:
                I += n[0]
                n = n[1:]
        assert l == "" and n == ""

        print()
        print("D: ", D := I)
        print("--")
        print("ext", sag.EXT(D))
        print("--")
        print("sag", D := sag.SAG(D))

        assert str(D) == "".join(sorted(str(D), key=lambda k: ord(k)%ord("a")))
        print()

        print("D: ", D)
        print("--")
        print("dep", sag.DEP(D))
        print("--")
        print("gas", D := sag.ISG(D))

        assert str(I) == str(D)
        print()
        print("=" * 50)
        print()

def tests(N):
    config.enableDebug = False

    symbols = "+0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~"
    assert N <= len(symbols)
    symbols = symbols[0:N]

    sag = SAG4Fun(N)

    for i in range(100):
        M = "".join(random.choices("01", k=N))
        sag.loadMask(M)

        I = ""
        l = symbols[:M.count("0")]
        r = symbols[M.count("0"):]
        for i in range(N):
            if M[i] == "0":
                I += l[-1]
                l = l[:-1]
            else:
                I += r[0]
                r = r[1:]
        assert l == "" and r == ""

        D = sag.SAG(I)
        O = sag.ISG(D)

        sep = " " if N<=32 else "\n\t"
        print(f"M={M} I={I}{sep}D={D} O={O}")

        assert str(D) == "".join(sorted(str(D)))
        assert str(I) == str(O)

    print()
    print("=" * 50)
    print()

def snippets():
    config.enableDebug = False

    I32 = BitMaskSet(32, 0, str32 := "+0123456789ABCDEFGHIJKLMNOPQRST~")
    I64 = BitMaskSet(64, 0, str64 := "+0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~")
    assert len(str32) == 32 and len(str64) == 64

    sag32 = SAG4Fun(32)
    sag64 = SAG4Fun(64)

    def makePerm(name, val32, val64):
        expr32 = "{" + ", ".join([f"in[{str32.find(c)}]" for c in reversed(str(val32))]) + "}"
        expr64 = "{" + ", ".join([f"in[{str64.find(c)}]" for c in reversed(str(val64))]) + "}"
        print()
        print(f"function [XLEN-1:0] {name};")
        print(f"  input [XLEN-1:0] in;")
        for stmt in [f"  if (XLEN == 32) {name} = {expr32};", f"  else {name} = {expr64};"]:
            for line in textwrap.wrap(stmt, initial_indent="  ", subsequent_indent="      "):
                print(line)
        print(f"endfunction")

    makePerm(f"split", I32.split(), I64.split())
    makePerm(f"merge", BitMaskSet(32, 1, I32).merge(), BitMaskSet(64, 1, I64).merge())

    print()
    print("=" * 50)
    print()

def checks(N):
    config.enableDebug = False

    symbols = "+0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~"
    assert N <= len(symbols)
    symbols = symbols[0:N-1] + "~"
    
    sag = SAG4Fun(N)
    log2N = (N-1).bit_length()

    print()
    print("I ", symbols)

    print()
    D = (Q := BitMaskSet(N, 0, symbols))
    for i in range(log2N):
        D = D.split()
        Q = BitMaskSet(N, 0, Q.split())
        print(f"S{i}", D, Q, ("EQ" if Q==D else "ne") + ("ID" if Q==symbols else ""))

    print()
    D = (Q := BitMaskSet(N, log2N, symbols))
    for i in range(log2N):
        D = D.merge()
        Q = BitMaskSet(N, 1, Q).merge()
        print(f"M{i}", D, Q, ("EQ" if Q==D else "ne") + ("ID" if Q==symbols else ""))

    D = bin(0x1b3389e39)[3:] if N == 32 else bin(0x135af3cf8a0e5e582)[3:]
    M = bin(0x1690aea75)[3:] if N == 32 else bin(0x1642c00be348a9690)[3:]

    print()
    print(f"localparam [{N-1}:0] test_din = {N}'b {D};")
    print(f"localparam [{N-1}:0] test_msk = {N}'b {M};")

    sag = SAG4Fun(N)
    sag.loadMask(M);

    print(f"localparam [{N-1}:0] test_sag = {N}'b {sag.SAG(D)};")
    print(f"localparam [{N-1}:0] test_isg = {N}'b {sag.ISG(D)};")

    print()
    print("=" * 50)
    print()

if __name__ == "__main__":
    demo()
    tests(32)
    tests(64)
    snippets()
    checks(32)
    checks(64)
    print("ALL TESTS PASSED")
    print()
    sys.exit(0)
