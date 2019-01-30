clc

radius = 10 ^ 9;
classes = 6;

step = (2 * pi) / classes;
degrees = step : step : 2 * pi;

centers = zeros(2, classes);

for k = 1 : classes
    centers(:, k) = [ cos(degrees(k)) ; sin(degrees(k)) ] .* radius;
end

classRadius = 10 ^ 3;
classElements = 4;

step = (2 * pi) / classElements;
degrees = step : step : 2 * pi;

classifiers = zeros(2, classElements, classes);

for k = 1 : classes
    for l = 1 : classElements
        element = [ cos(degrees(l)) ; sin(degrees(l))] .* classRadius;
        element = centers(k) + element;
        classifiers(:, l, k) = element;
    end
end

means = zeros(2, classes);

for k = 1 : classes
    means(:, k) = mean(classifiers(:, :, k), 2);
end

scale = 10 ^ 9;
tests = 5;

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
    disp(['Point ', mat2str(testPoint) ,' belongs to class ', num2str(minClass)]);
end

clear