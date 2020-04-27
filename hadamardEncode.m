function encodedBits = hadamardEncode(databits, hadamardMatrix)
encodedBits = hadamardMatrix(1+bi2de(databits), :);
end