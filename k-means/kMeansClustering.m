close
clear
clc

disp("Algoritmo K-Means.");

n = input("Ingrese el número de vectores : ");
m = input("Ingrese el valor de K : ");

threshold = 1e-9;
dim = 2;

vectors = randn(n, dim);

means = vectors(1 : m, :);

prev = zeros(m, dim);
prev(:, :) = Inf;

it = 0;

hold on
grid on
legend

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
        for k = 1 : m
            cluster = vectors(clusters{k}, :);
            scatter(cluster(:, 1), cluster(:, 2), 'filled', 'DisplayName', strcat("C", num2str(k)));
        end
        scatter(means(:, 1), means(:, 2), 'ko', 'DisplayName', 'Medias');
        break
    end
    prev(:, :) = means(:, :);
end

fprintf("Se logró en %d iteraciones.\n", it);
