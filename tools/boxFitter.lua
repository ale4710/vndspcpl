return function(ox, oy, tx, ty)
    local wsf = tx / ox
    local hsf = ty / oy

    local scale1, scale2

    local targetAspectRatio = tx / ty
    local originalAspectRatio = ox / oy
    local scaleTh = 0.005


    if(originalAspectRatio > targetAspectRatio - scaleTh) then
        --video is wider.
        scale1 = hsf
        scale2 = wsf
    elseif(originalAspectRatio < targetAspectRatio + scaleTh) then
        --video is taller
        scale1 = wsf
        scale2 = hsf
    else --else it moreorless fits the window.
        scale2 = wsf
    end

    if(scale1) then
        return scale2, scale1 --fit, fill
    else
        return scale2
    end
end