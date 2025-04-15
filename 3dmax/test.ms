-- 创建数组存储材质缓存
materialCache = #()
oldMaterialNames = #() -- 新增数组存储旧材质名称

-- 切换到扫描线渲染器
renderers.current = Default_Scanline_Renderer()

-- 全局声明函数和材质缓存
global convertToStandardMaterial

-- 定义递归材质转换函数
fn convertToStandardMaterial mat = (
    if mat == undefined then 
    (
        format "Some Mat is undefined or not supported"
        return undefined
    )

    -- 检查材质是否已经在缓存中
    if materialCache.count > 0 then (
        for cachedMat in materialCache do (
            if cachedMat.name == mat.name then (
                format ("Material " + cachedMat.name + " exists in the array.\n")
                return cachedMat
            )
        )
    )

    local newMat
    case (classof mat) of (
        Multimaterial: (
            -- 处理多维子材质
            newMat = Multimaterial name:mat.name
            for i = 1 to mat.materialList.count do (
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
            newMat.name = mat.name
            
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
                
                default: (
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

            -- 凹凸贴图处理
            try (
                if mat.bump_map != undefined and classof mat.bump_map == BitmapTexture do (
                    newMat.bumpMap = mat.bump_map
                )
                newMat.bumpAmount = mat.bump
            ) catch ()
        )
    )

    -- 将旧材质名称存入数组
    append oldMaterialNames mat.name

    -- 将新材质存入缓存
    append materialCache newMat
    return newMat
)

-- 处理所有对象
for obj in objects where obj.material != undefined do (
    obj.material = convertToStandardMaterial obj.material
)

messageBox "材质转换完成！" title:"操作成功"

-- 删除未被引用的材质
-- for mat in scenematerials do (
--     if (refs.dependentNodes mat).count == 0 do (
--         deleteItem scenematerials (findItem scenematerials mat)
--     )
-- )

-- 清理旧材质名称对应的材质
for oldName in oldMaterialNames do (
    for mat in scenematerials do (
        if mat.name == oldName do (
            deleteItem scenematerials (findItem scenematerials mat)
        )
    )
)

-- 清空旧材质名称数组
oldMaterialNames = #()

messageBox "未使用材质已清理！" title:"操作成功"