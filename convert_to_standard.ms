-- 创建一个函数用于将材质转换为标准材质
fn convertToStandard = (
    -- 切换到扫描线渲染器
    renderers.current = Default_Scanline_Renderer()

    -- 全局声明函数
    global convertToStandardMaterial

    -- 定义递归材质转换函数
    fn convertToStandardMaterial mat = (
        if classof mat == Multimaterial then (
            for i in 1 to mat.materialList.count do (
                local subMat = mat.materialList[i]
                if subMat != undefined do (
                    mat.materialList[i] = convertToStandardMaterial subMat
                )
            )
            mat
        ) else (
            if classof mat == StandardMaterial then (
                mat
            ) else (
                local newMat = StandardMaterial()
                newMat.name = mat.name + "_Std"
                
                -- 通用属性转换
                try(newMat.diffuse = mat.diffuse)catch()
                try(newMat.diffuse = mat.base_color)catch()
                try(newMat.specularLevel = mat.specular_level)catch()
                try(newMat.opacity = mat.opacity)catch()
                
                -- 自发光处理
                case (classof mat) of (
                    PhysicalMaterial: try(newMat.selfIllumAmount = mat.luminance)catch()
                    VRayMtl: try(newMat.selfIllumAmount = mat.selfIllumAmount)catch()
                    default: try(newMat.selfIllumAmount = mat.selfIllumination)catch()
                )
                
                newMat
            )
        )
    )

    -- 处理所有对象
    for obj in objects where obj.material != undefined do (
        obj.material = convertToStandardMaterial obj.material
    )

    messageBox "材质转换完成！" title:"操作成功"
)

-- 创建主界面卷展栏
rollout convertMaterialsRollout "材质转换工具" width:162 height:85
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
floater = newRolloutFloater "材质转换工具" 180 220 style:#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu)
addRollout convertMaterialsRollout floater