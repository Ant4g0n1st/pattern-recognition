clc
clear
close

classes = 6;

classifiers = randn(3, 4, classes);

means = zeros(3, classes);

for k = 1 : classes
    means(:, k) = mean(classifiers(:, :, k), 2);
end

testVector = [0;0;0];

minimumMahalanobis(classifiers, means, testVector);

clear
close