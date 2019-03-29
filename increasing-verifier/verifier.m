clear
close 
clc

dim = 2;
n = 7;
m = n;
z = n;

samples = randn(2 * n, dim);
valid = zeros(1, 2 * n);
label = zeros(1, 2 * n);

for k = 1 : 2 * n
    label(1, k) = k;
    valid(1, k) = 1;
end

while m >= 2
    distances = zeros(m);
    minDist = Inf;
    a = 0;
    x = 0;
    y = 0;
    p = 0;
    q = 0;
    for k = 1 : 2 * n
        if valid(:, k) == 0
            continue
        end
        a = a + 1;
        b = 0;
        for l = 1 : 2 * n
            if valid(:, l) == 0
                continue
            end
            b = b + 1;
            distances(a, b) = norm(samples(k, :) - samples(l, :));
            distances(b, a) = distances(a, b);
            if distances(a, b) < minDist && a ~= b
                minDist = distances(a, b);
                x = a;
                y = b;
                p = k;
                q = l;
            end
            if b == m
                break
            end
        end
        if a == m
            break
        end
    end
    fprintf("Puntos Restantes:");
    disp(label(:, 1 : m));
    disp(distances);
    fprintf("Quitar: %d %d\n", label(:, x), label(:, y));
    valid(:, p) = 0;
    valid(:, q) = 0;
    z = z + 1;
    points = [ samples(p, :) ; samples(q, :) ]';
    samples(z, :) = mean(points, 2);
    m = m - 1;
    a = 0;
    for k = 1 : 2 * n
        if valid(:, k) == 0
            continue
        end
        a = a + 1;
        label(:, a) = k;
        if a == m
            break
        end
    end
end

dendrogram(linkage(samples(1 : n, :), 'average'));
