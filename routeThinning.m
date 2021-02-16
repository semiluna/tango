function thinnedRoute = routeThinning(route)
%ROUTETHINNING Takes route as input and reduces strings of coordinates in a
%straight line to two endpoints
    thinnedRoute = [route(1,:), route(2,:)];
    
    [prevVertical, prevGrad] = getGrad(thinnedRoute(-2,:), thinnedRoute(-1,:));
    
    for i = 3:length(route)
        candidate = route(i,:);
        
        [vertical, grad] = getGrad(thinnedRoute(-2,:), candidate);
        
        if (vertical && prevVertical) || (~vertical && ~prevVertical && grad == prevGrad)
            thinnedRoute(-1,:) = candidate;
            prevVertical = vertical;
            prevGrad = grad;
        else
            thinnedRoute = append(thinnedRoute, candidate);
            [prevVertical, prevGrad] = getGrad(thinnedRoute(-2,:), thinnedRoute(-1,:));
        end 
    end
    
end

function [vertical, grad] = getGrad(c1, c2)
    grad = 0;
    vertical = false;
    if c1(1) ~= c2(1)
        grad = (c2(2)-c1(2))/(c2(1)-c1(1));
    else
        vertical = true;
    end
end

