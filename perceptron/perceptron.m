clear
close
clc

c2 = [ 0 1 1 ; 0 0 1 ];
c1 = [ 0 ; 1 ];

[ ~, n1 ] = size(c1);
[ ~, n2 ] = size(c2);

w = zeros(3, 1);
w(:, :) = 1;

x = zeros(3, 1);
x(:, :) = 1;

change = 1;
dim = 2;
r = 1;

grid on
hold on
legend

scatter(c1(1, :), c1(2, :), 'filled', 'DisplayName', 'C1');
scatter(c2(1, :), c2(2, :), 'filled', 'DisplayName', 'C2');

while change == 1
    change = 0;
    for k = 1 : n1
        x(1 : dim, :) = c1(:, k);
        dot = x' * w;
        if dot >= 0
            w = w - r * x;
            change = 1;
        end
    end
    for k = 1 : n2
        x(1 : dim, :) = c2(:, k);
        dot = x' * w;
        if dot <= 0
            w = w + r * x;
            change = 1;
        end
    end
end

disp(w');

width = 2;
v = -width : width;

if w(2, :) ~= 0
    if w(1, :) ~= 0
        plot(v, - (v * w(1, :) + w(3, :)) / w(2, :), 'HandleVisibility', 'off');
    else
        y = zeros(1, 2 * width + 1);
        y(:, :) = - w(3, :) / w(2, :);
        plot(v, y, 'HandleVisibility', 'off');
    end
else
    z = - w(3, :) / w(1, :);
    plot([z z], [ -width, width ], 'HandleVisibility', 'off');
end

clear