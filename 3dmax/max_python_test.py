# 文件名: create_sphere_with_modifiers.py
# 功能：创建一个球体，添加扭曲修改器，并设置材质颜色

from pymxs import runtime as rt  # 导入3ds Max的Python运行时接口

# 1. 创建球体
sphere = rt.Sphere(
    radius=30.0,          # 半径
    pos=rt.Point3(0,0,0), # 坐标位置
    name="MyPythonSphere" # 名称
)

# 2. 添加扭曲修改器 (Twist)
twist_mod = rt.Twist()    # 创建扭曲修改器
twist_mod.Bias = 50       # 偏移量
twist_mod.Angle = 180     # 扭曲角度
rt.addModifier(sphere, twist_mod) # 将修改器附加到球体

# 3. 创建红色材质并赋予球体
red_material = rt.StandardMaterial() # 创建标准材质
red_material.Diffuse = rt.Color(255, 0, 0) # 设置为红色
sphere.Material = red_material # 分配材质

# 4. 调整视图（可选）
rt.viewport.SetLayout(rt.Name("layout_4")) # 切换到四视图
rt.redrawViews() # 刷新视图