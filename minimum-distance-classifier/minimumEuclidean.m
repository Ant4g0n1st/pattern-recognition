function minClass = minimumEuclidean(classifiers, means, testVector)
    % Minimum Distance classification algorithm.
    
    % Collect sizes.
    [ dc, ~, classes ] = size(classifiers);
    [ dt, ~ ] = size(testVector);
    [ dm, ~ ] = size(means); 
    
    minClass = 0;
    
    if dc ~= dm
        return
    end
    
    if dc ~= dt
        return
    end
    
    % Minimal distance starts at infinity.
    minDist = Inf;
    % Pick any class as the closest class.
    minClass = 1;
    for k = 1 : classes
        % Compute distance to class mean.
        dist = norm(means(:, k) - testVector);
        if minDist > dist
            % Minimize distance.
            minDist = dist;
            % Store the new closest class.
            minClass = k;
        end
    end
    
end