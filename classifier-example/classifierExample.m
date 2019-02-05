clear
close
clc

% Class constants.
classElements = 8;
classRadius = 1e1;

% Script constants.
classes = 24;
radius = 1e2;

% Test constants.
scale = radius / 2;
tests = 100;

% Compute degrees for every class center.
step = (2 * pi) / classes;
degrees = step : step : 2 * pi;

% Allocate space for class center vectors.
centers = zeros(2, classes);

% Compute the class center vectors.
for k = 1 : classes
    centers(:, k) = [ cos(degrees(k)) ; sin(degrees(k)) ] .* radius;
end

% Compute degrees for every class member.
step = (2 * pi) / classElements;
degrees = step : step : 2 * pi;

% Allocate space for every class element vector.
classifiers = zeros(2, classElements, classes);

for k = 1 : classes
    for l = 1 : classElements
        % Compute every class member vector.
        element = [ cos(degrees(l)) ; sin(degrees(l))] .* classRadius;
        % Translate the origin of the member to the class center,
        element = centers(:, k) + element;
        % Store the new member.
        classifiers(:, l, k) = element;
    end
end

% Allocate space for class mean vectors.
means = zeros(2, classes);
grid on
hold on

for k = 1 : classes
    plot(classifiers(1, :, k), classifiers(2, :, k), 'ro');
    % Compute the class means.
    means(:, k) = mean(classifiers(:, :, k), 2);
end

% Plot the class means.
plot(means(1, :), means(2, :), 'go');

for k = 1 : tests
    % Generate random test.
    testPoint = [ randn() ; randn() ] .* scale;
    % Minimal distance starts at infinity.
    minDist = Inf;
    % Pick any class as the closest class.
    minClass = 1;
    for l = 1 : classes
        % Compute distance to class mean.
        dist = norm(means(:, l) - testPoint);
        if minDist > dist
            % Minimize distance.
            minDist = dist;
            % Store the new closest class.
            minClass = l;
        end
    end
    % Output for this test case.
    fprintf('El vector [%f; %f] ', testPoint);
    fprintf('pertenece a la clase %d\n', minClass);
    % Plot the test vector.
    plot(testPoint(1, :), testPoint(2, :), 'bo');
end

clear