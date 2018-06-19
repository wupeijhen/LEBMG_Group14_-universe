--local normalW, normalH = 480, 320

--local w, h = display.pixelWidth, display.pixelHeight
--local scale = math.max(normalW / w, normalH / h)
--w, h = w * scale, h * scale

--application = {
    --content = {
        --width = w,
        --height = h,
        --scale = 'letterbox',
        --fps = 60,
        --imageSuffix = {
            --['@2x'] = 1.1,
            --['@4x'] = 2.1
        --}
    --}
--}
application =
{
    content =
    {
        --寬
        width = 320,
        --高 
        height = 480,
        --縮放模式 
        --scale = "letterbox",
        --scale = "zoomEven",
        scale = "zoomStretch",
        --偵數
        fps = 60,
        
        
        imageSuffix =
        {
                ["@2x"] = 2,
                ["@4x"] = 4,
        },
        
    },
}