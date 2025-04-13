-- 创建一个函数用于将材质转换为标准材质
fn convertToStandard = (
    -- 切换到扫描线渲染器
    renderers.current = Default_Scanline_Renderer()

    -- 全局声明函数和材质缓存
    global convertToStandardMaterial
    global materialCache = Dictionary 

    -- 定义递归材质转换函数
    fn convertToStandardMaterial mat = (
        -- 检查材质是否已经在缓存中
        if materialCache.hasKey mat.name do (
            return materialCache[mat.name]
        )

        local newMat
        case (classof mat) of (
            Multimaterial: (
                -- 处理多维子材质
                newMat = Multimaterial name:mat.name
                for i in 1 to mat.materialList.count do (
                    local subMat = mat.materialList[i]
                    if subMat != undefined do (
                        newMat.materialList[i] = convertToStandardMaterial subMat
                    )
                )
            )
            
            StandardMaterial: (
                -- 已经是标准材质则直接返回
                newMat = mat
            )
            
            default: (
                -- 创建新标准材质
                newMat = StandardMaterial()
                newMat.name = mat.name + "_Std"
                
                -- 漫反射处理（优先处理贴图）
                case (classof mat) of (
                    PhysicalMaterial: (
                        -- 转换物理材质
                        if mat.base_color_map != undefined and classof mat.base_color_map == BitmapTexture do (
                            newMat.diffuseMap = mat.base_color_map
                        )
                        newMat.diffuse = mat.base_color
                    )
                    
                    VRayMtl: (
                        -- 转换VRay材质
                        if mat.texmap_diffuse != undefined and classof mat.texmap_diffuse == BitmapTexture do (
                            newMat.diffuseMap = mat.texmap_diffuse
                        )
                        newMat.diffuse = mat.diffuse
                    )
                    
                    Standardmaterial: ()  -- 已处理
                    
                    default: (
                        -- 通用处理（适用于Arnold等大多数材质）
                        try (
                            if mat.diffuseMap != undefined and classof mat.diffuseMap == BitmapTexture do (
                                newMat.diffuseMap = mat.diffuseMap
                            )
                            newMat.diffuse = mat.diffuse
                        ) catch ()
                    )
                )
                
                -- 不透明度处理（带贴图支持）
                try (
                    if mat.opacity_map != undefined and classof mat.opacity_map == BitmapTexture do (
                        newMat.opacityMap = mat.opacity_map
                    )
                    newMat.opacity = mat.opacity
                ) catch ()
                
                -- 自发光处理
                try (
                    case (classof mat) of (
                        PhysicalMaterial: newMat.selfIllumAmount = mat.luminance
                        VRayMtl: newMat.selfIllumAmount = mat.selfIllumAmount
                        default: newMat.selfIllumAmount = mat.selfIllumination
                    )
                ) catch ()
                
                -- 高光处理
                try (newMat.specularLevel = mat.specular_level) catch ()
                try (newMat.glossiness = mat.roughness) catch ()
            )
        )

        -- 检查材质名称是否有效
        if mat.name == undefined or mat.name == "" do (
            mat.name = uniqueName "Material"
        )
        
        -- 将新材质存入缓存
        materialCache[mat.name] = newMat
        return newMat
    )

    -- 处理所有对象
    for obj in objects where obj.material != undefined do (
        obj.material = convertToStandardMaterial obj.material
    )

    messageBox "材质转换完成！" title:"操作成功"
)

-- 创建主界面卷展栏
rollout convertMaterialsRollout "材质转换工具" width:165 height:85
(
    button btnConvert "转换为标准材质" pos:[10,10] width:142 height:28
    on btnConvert pressed do
    (
        convertToStandard()
    )
)

-- 创建浮动窗口
if convertMaterialsFloater != undefined do DestroyDialog convertMaterialsFloater
-- 创建一个可调整大小的浮动窗口
floater = newRolloutFloater "材质转换工具" 280 220 style:#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu)
-- 设置窗口最小尺寸
addRollout convertMaterialsRollout floater