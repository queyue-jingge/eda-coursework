module h_adder(input a, input b, output so, output co);
  assign so = a ^ b;
  assign co = a & b;
endmodule
module full_adder(input a, input b, input c, output co, output so);
  wire s1, c1, c2;
  h_adder u1(.a(a), .b(b), .so(s1), .co(c1));
  h_adder u2(.a(s1), .b(c), .so(so), .co(c2));
  assign co = c1 | c2;
endmodule
