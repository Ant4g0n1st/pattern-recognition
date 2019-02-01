clear
close
clc

radius = 10 ^ 2;
classes = 12;

step = (2 * pi) / classes;
degrees = step : step : 2 * pi;

centers = zeros(2, classes);

for k = 1 : classes
    centers(:, k) = [ cos(degrees(k)) ; sin(degrees(k)) ] .* radius;
end

classRadius = 10 ^ 1;
classElements = 4;

step = (2 * pi) / classElements;
degrees = step : step : 2 * pi;

classifiers = zeros(2, classElements, classes);

for k = 1 : classes
    for l = 1 : classElements
        element = [ cos(degrees(l)) ; sin(degrees(l))] .* classRadius;
        element = centers(:, k) + element;
        classifiers(:, l, k) = element;
    end
end

means = zeros(2, classes);
grid on
hold on

for k = 1 : classes
    plot(classifiers(1, :, k), classifiers(2, :, k), 'ro');
    means(:, k) = mean(classifiers(:, :, k), 2);
end

plot(means(1, :), means(2, :), 'go');

scale = 5 * 10 ^ 1;
tests = 100;

for k = 1 : tests
    testPoint = [ randn() ; randn() ] .* scale;
    minDist = Inf;
    minClass = 1;
    for l = 1 : classes
        dist = norm(means(:, l) - testPoint);
        if minDist > dist
            minDist = dist;
            minClass = l;
        end
    end
    disp(['El vector ', mat2str(testPoint) ,' pertenece a la clase ', num2str(minClass)]);
    plot(testPoint(1, :), testPoint(2, :), 'bo');
end

clear