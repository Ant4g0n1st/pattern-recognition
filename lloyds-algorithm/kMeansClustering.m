close
clear
clc

%img = imread("kMeansInput2.png");  % Colombia Flag
%img = imread("kMeansInput.png");   % Germany Flag
%img = imread("kMeansInput1.jpg");  % France Flag
img = imread("kMeansInput.jpg");   % Italy Flag
%img = rgb2gray(img);
%img = imread("peppers.png");

[ dx, dy, dim ] = size(img);

disp("Algoritmo K-Means.");

axes = 2;
n = 2500;
m = 3;

threshold = 1e-9;
%dim = 3;

pixels = rand(n, axes);
pixels(:, 1) = floor(pixels(:, 1) * (dx - 1) + 1);
pixels(:, 2) = floor(pixels(:, 2) * (dy - 1) + 1);
pixels(:, :) = pixels(randperm(n), :);

vectors = zeros(n, dim);
for k = 1 : n
    for l = 1 : dim
        vectors(k, l) = img(pixels(k, 1), pixels(k, 2), l);
    end
end

%vectors = randn(n, dim);
%vectors(:, :) = vectors(randperm(n), :);

means = zeros(m, dim);
for k = 1 : m
    for x = 1 : n
        inMeans = 0;
        for y = 1 : k - 1
            if means(y, :) == vectors(x, :)
                inMeans = 1;
                continue
            end
        end
        if inMeans == 1
            continue
        end
        means(k, :) = vectors(x, :);
        break
    end
end

prev = zeros(m, dim);
prev(:, :) = Inf;

it = 0;

while 1
    it = it + 1;
    clusters = cell(1, m);
    for k = 1 : n
        minDist = Inf;
        cluster = 0;
        for c = 1 : m
            dist = norm(vectors(k, :) - means(c, :));
            if dist < minDist
                minDist = dist;
                cluster = c;
            end
        end
        [~, s] = size(clusters{cluster});
        clusters{cluster}(s + 1) = k;
    end
    for k = 1 : m
        means(k, :) = mean(vectors(clusters{k}, :), 1);
    end
    change = 0;
    for k = 1 : m
        if norm(prev(k, :) - means(k, :)) > threshold
            change = 1;
            break
        end
    end
    if change == 0
        break
    end
    prev(:, :) = means(:, :);
end

fprintf("Se logró en %d iteraciones.\n", it);

figure(1);

imshow(img);

hold on
%grid on
legend

for k = 1 : m
    cluster = pixels(clusters{k}, :);
    %cluster = vectors(clusters{k}, :);
    [s, ~] = size(cluster);
    scatter(cluster(:, 2), cluster(:, 1), 'filled', 'DisplayName', strcat("C", num2str(k)));
    %scatter3(cluster(:, 1), cluster(:, 2), cluster(:, 3), 'filled', 'DisplayName', strcat("C", num2str(k)));
end

figure(2);

hold on
grid on
legend

scatter3(means(:, 1), means(:, 2), means(:, 3), 'DisplayName', 'Medias K-Means');

disp(means');

kMeans = means;

disp("Algoritmo de Lloyd.");

prev(:, :) = Inf;

threshold = 1e-9;
learn = 5e-2;

it = 0;

while 1
    it = it + 1;
    for k = 1 : n
        minCluster = 0;
        minDist = Inf;
        for c = 1 : m
            dist = norm(vectors(k, :) - means(c, :));
            if dist < minDist
                minCluster = c;
                minDist = dist;
            end
        end
        z = means(minCluster, :);
        z = z + learn * (vectors(k, :) - z);
        means(minCluster, :) = z;
    end
    change = 0;
    for k = 1 : m
        if norm(prev(k, :) - means(k, :)) > threshold
            change = 1;
            break
        end
    end
    if change == 0
        break
    end
    prev(:, :) = means(:, :);
end

fprintf("Lloyd's terminó en %d iteraciones.\n", it);

disp(means');

scatter3(means(:, 1), means(:, 2), means(:, 3), 'd', 'DisplayName', 'Medias Lloyd');

for k = 1 : m
    p = kMeans(k, :);
    q = means(k, :);
    plot3([ p(1) ; q(1) ], [ p(2) ; q(2) ], [ p(3) ; q(3) ], 'k--', 'HandleVisibility', 'off');
end
