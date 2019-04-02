close
clear
clc

%legend

figure(1);
img = imread("kMeansInput.png"); % Germany Flag
%img = imread("kMeansInput.jpg"); % Italy Flag
%img = imread("kMeansInput1.jpg"); % France Flag
%img = rgb2gray(img);
imshow(img);
hold on

[ dx, dy, dz ] = size(img);

disp("Algoritmo K-Means.");

axes = 2;
n = 5000;
m = 3;

threshold = 1e-9;
dim = 3;

pixels = rand(n, axes);
pixels(:, 1) = floor(pixels(:, 1) * (dx - 1) + 1);
pixels(:, 2) = floor(pixels(:, 2) * (dy - 1) + 1);
pixels(:, :) = pixels(randperm(n), :);

vectors = zeros(n, dim);
for k = 1 : n
    vectors(k, 1) = img(pixels(k, 1), pixels(k, 2), 1);
    vectors(k, 2) = img(pixels(k, 1), pixels(k, 2), 2);
    vectors(k, 3) = img(pixels(k, 1), pixels(k, 2), 3);
end


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
    %fprintf("Iteracion %d\n", it);
    clusters = cell(1, m);
    for k = 1 : n
    %fprintf("Vector %d\n", k);
        minDist = Inf;
        cluster = 0;
        for c = 1 : m
            dist = norm(vectors(k, :) - means(c, :));
            if dist < minDist
                minDist = dist;
                cluster = c;
            end
            %fprintf("d(%d, %d) = %f\n", k, c, dist);
        end
        [~, s] = size(clusters{cluster});
        clusters{cluster}(s + 1) = k;
        %fprintf("%d pertenece a %d\n\n", k, cluster);
    end
    %fprintf("Medias:\n");
    for k = 1 : m
        means(k, :) = mean(vectors(clusters{k}, :), 1);
        %fprintf("m%d = [ %f %f ]\n", k, means(k, :));
    end
    %fprintf("\n");
    change = 0;
    for k = 1 : m
        if norm(prev(k, :) - means(k, :)) > threshold
            change = 1;
            break;
        end
    end
    %for k = 1 : m
    %    fprintf("Z%d\n", k);
    %    disp(clusters{k});
    %end
    %fprintf("\n");
    if change == 0
        break
    end
    prev(:, :) = means(:, :);
end

for k = 1 : m
    cluster = pixels(clusters{k}, :);
    [s, ~] = size(cluster);
    scatter(cluster(:, 2), cluster(:, 1), 'filled');
    fprintf("Cluster %d size: %d\n", k, s);
end

fprintf("Se logró en %d iteraciones.\n", it);
