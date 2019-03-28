clear
close
clc

c1 = [ 1 1 1 2 2 ; 1 3 5 2 3];
c2 = [ 6 6 7 7 7 ; 3 4 1 3 5];

[ ~, n1 ] = size(c1);
[ ~, n2 ] = size(c2);

z1 = [ 1 ; 4 ];
z2 = [ 7 ; 2 ];

learn = 0.1;


treshold = 0.000001;

lz1 = [ Inf ; Inf ];
lz2 = [ Inf ; Inf ];

it = 0;

while 1
    
    it = it + 1;
    fprintf("Iteracion %d\n", it);

    count = 0;

    for k = 1 : n1
        count = count + 1;
        fprintf("X%d\n", count);
        d1 = norm(z1 - c1(:, k));
        d2 = norm(z2 - c1(:, k));
        fprintf("Distancias : [ %f %f ]\n", d1, d2);
        if d1 < d2
            z1 = z1 + learn * (c1(:, k) - z1);
            fprintf("Z1 : [ %f ; %f ]\n", z1);
        else
            z2 = z2 + learn * (c1(:, k) - z2);
            fprintf("Z2 : [ %f ; %f ]\n", z2);
        end
        fprintf("\n");
    end

    for k = 1 : n2
        count = count + 1;
        fprintf("X%d\n", count);
        d1 = norm(z1 - c2(:, k));
        d2 = norm(z2 - c2(:, k));
        fprintf("Distancias : [ %f %f ]\n", d1, d2);
        if d1 < d2
            z1 = z1 + learn * (c2(:, k) - z1);
            fprintf("Z1 : [ %f ; %f ]\n", z1);
        else
            z2 = z2 + learn * (c2(:, k) - z2);
            fprintf("Z2 : [ %f ; %f ]\n", z2);
        end
        fprintf("\n");
    end
    
    if norm(lz1 - z1) < treshold && norm(lz2 - z2) < treshold
        break
    end
    
    lz1 = z1;
    lz2 = z2;

end

fprintf("Z1 : [ %f ; %f ]\n", z1);
fprintf("Z2 : [ %f ; %f ]\n", z2);

clear
