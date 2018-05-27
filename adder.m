a = single(randn(10,1));
a_hex = cellstr(num2hex(a))
b = single(randn(10,1));
b_hex = cellstr(num2hex(b))
sum = single(a) + single(b);
sum_hex = cellstr(num2hex(single(sum)))


FID = fopen('a.txt','w');
fprintf(FID,'%s\n',a_hex{:});
fclose(FID);

FID = fopen('b.txt','w');
fprintf(FID,'%s\n',b_hex{:});
fclose(FID);

FID = fopen('sum.txt','w');
fprintf(FID,'%s\n',sum_hex{:});
fclose(FID);
