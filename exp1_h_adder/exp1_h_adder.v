module h_adder(input a, input b, output so, output co);
  assign so = a ^ b;
  assign co = a & b;
endmodule
