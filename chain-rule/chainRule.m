close
clear
clc

%img = imread("kMeansInput2.png");  % Colombia Flag
%img = imread("kMeansInput.png");   % Germany Flag
%img = imread("kMeansInput1.jpg");  % France Flag
%img = imread("kMeansInput.jpg");   % Italy Flag
%img = rgb2gray(img);

pictures = {
    %imread("kMeansInput2.png")   % Colombia Flag
    %imread("kMeansInput1.jpg")   % France Flag
    %imread("kMeansInput.jpg")    % Italy Flag
    imread("kMeansInput.png")    % Germany Flag
};

[ p, ~ ] = size(pictures);

disp("Algoritmo Regla de la Cadena.");

for i = 1 : p
    fprintf("Imagen %d:\n", i);
    
    img = pictures{i};
    
    [ dx, dy, dim ] = size(img);

    axes = 2;
    n = 5000;

    classThreshold = 150;
    threshold = 1e-9;

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

    means = zeros(1, dim);
    means(:, :) = vectors(1, :);

    prev = zeros(0, dim);

    it = 0;

    while 1
        it = it + 1;
        %fprintf("Iteracion %d\n", it);

        [ m, ~ ] = size(means);
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

            if classThreshold > minDist
                [~, s] = size(clusters{cluster});
                clusters{cluster}(s + 1) = k;
            else
                means(m + 1, :) = vectors(k, :);
                clusters{m + 1}(1, 1) = k;
                m = m + 1;
            end
        end

        for k = 1 : m
            means(k, :) = mean(vectors(clusters{k}, :), 1);
        end

        [ s, ~ ] = size(prev);

        if s < m
            prev(s + 1 : m, :) = Inf;
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

    figure(i);

    imshow(img);

    hold on
    legend

    for k = 1 : m
        cluster = pixels(clusters{k}, :);
        scatter(cluster(:, 2), cluster(:, 1), 'filled', 'DisplayName', strcat("C", num2str(k)));
    end
end
    