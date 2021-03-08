function dist = compute_euclidian_distance(route)
    sum = 0.0;
    for i = 1 : (length(route) - 1)
        sum = sum + sqrt( (route(i, 1) - route(i + 1, 1))^2 + (route(i, 2) - route(i + 1, 2))^2 );
    end
    
    dist = round(sum);
end