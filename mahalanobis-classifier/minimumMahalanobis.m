function minClass = minimumMahalanobis(classifiers, means, testVector)
    % Minimum Mahalanobis classification algorithm.
    
    % Collect sizes.
    [ dc, elements, classes ] = size(classifiers);
    [ dt, ~ ] = size(testVector);
    [ dm, ~ ] = size(means); 
    
    minClass = 0;
    
    if dc ~= dm
        return
    end
    
    if dc ~= dt
        return
    end
    
    sigma = zeros(dc, dc, classes);
    
    for k = 1 : classes
        m = classifiers(:, :, k) - means(:, k);
        sigma(:, :, k) = (m * m') ./ elements;
    end
    
    % Minimal distance starts at infinity.
    minDist = Inf;
    % Pick any class as the closest class.
    minClass = 1;
    
    for k = 1 : classes
        % Compute Mahalanobis distance.
        m = testVector - means(:, k);
        dist = (m' / sigma(:, :, k)) * m;
        if minDist > dist
            % Minimize distance.
            minDist = dist;
            % Store the new closest class.
            minClass = k;
        end
    end
    
end

