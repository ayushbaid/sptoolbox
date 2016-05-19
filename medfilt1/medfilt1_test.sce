funcprot(0);
exec('medfilt1.sci', -1);

x = rand(3,3,2);

y = medfilt1(x, 3, 2, 0, 0);
