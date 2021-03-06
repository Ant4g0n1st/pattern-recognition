clear
close
clc

fprintf('Clasificador de Vectores\n\n');
classes = input('¿Cuántas clases quieres? : ');
members = input('¿Cuántos elementos por clase? : ');

classifiers = zeros(2, members, classes);
centers = zeros(2, classes);
radius = zeros(classes);

for k = 1 : classes
    fprintf('Coordenada ''x'' del representante %d :', k);
    centers(1, k) = input(' ');
    fprintf('Coordenada ''y'' del representante %d :', k);
    centers(2, k) = input(' ');
    fprintf('Dispersión de la clase %d :', k);
    radius(k) = input(' ');
    classMembers = randn(2, members) .* radius(k);
    classMembers(1, :) = classMembers(1, :) + centers(1, k);
    classMembers(2, :) = classMembers(2, :) + centers(2, k);
    classifiers(:, :, k) = classMembers;
end

% Allocate space for class mean vectors.
means = zeros(2, classes);
grid on
hold on
legend

for k = 1 : classes
    scatter(classifiers(1, :, k), classifiers(2, :, k), 'filled', 'DisplayName', strcat('C', num2str(k)));
    % Compute the class means.
    means(:, k) = mean(classifiers(:, :, k), 2);
end

% Plot the class means.
scatter(means(1, :), means(2, :), 'filled', 'DisplayName', 'Means');

shouldTest = 1;
testCount = 1;

while shouldTest == 1
    % Generate random test.
    %testPoint = [ randn() ; randn() ] .* scale;
    % Ask user for x-coordinate.
    tx = input('Coordenada ''x'' de la prueba: ');
    % Ask user for y-coordinate.
    ty = input('Coordenada ''y'' de la prueba: ');
    % Construct test vector.
    testVector = [ tx ; ty ];
    option = askOption();
    if option == 1
        minClass = minimumEuclidean(classifiers, means, testVector);
    elseif option == 2
        minClass = minimumMahalanobis(classifiers, means, testVector);
    else
        break
    end
    % Output for this test case.
    fprintf('El vector [%f; %f] ', testVector);
    fprintf('pertenece a la clase %d\n', minClass);
    % Plot the test vector.
    % 'HandleVisibility', 'off');
    scatter(testVector(1, :), testVector(2, :), 'LineWidth', 1.5, 'DisplayName', strcat('X', num2str(testCount)));
    shouldTest = input('¿Quiere hacer otra prueba? (Si = 1, No = 0) : ');
    testCount = testCount + 1;
end

clear