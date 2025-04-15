-- 创建字典存储对象名称和材质名称
matDict = dotNetObject "System.Collections.Generic.Dictionary`2[System.String,System.String]"

-- 遍历场景中的所有对象
for obj in objects do
(
    -- 排除物理相机对象
    if superClassOf obj == GeometryClass and not (matchPattern obj.name pattern:"*.target") do
    (
        -- 获取材质名称（处理空材质情况）
        matName = if obj.material != undefined then obj.material.name else "No Material"
        
        -- 避免重复key
        if not (matDict.ContainsKey obj.name) do
        (
            matDict.Add obj.name matName
        )
    )
)

-- 遍历字典并输出结果
enum = matDict.GetEnumerator()
while enum.MoveNext() do
(
    current = enum.Current
    format "Object: %, Material: %\n" current.Key current.Value
)

-- 将字典中所有的value组成一个数组
matValues = #()
enum = matDict.GetEnumerator()
while enum.MoveNext() do
(
    append matValues enum.Current.Value
)
for mat in matValues do
(
    format "Material: %\n" mat
)

-- -- 判断材质名称"bottle"是否已存在数组中
-- if findItem matValues "bottle" > 0 then
-- (
--     format "Material 'bottle' exists in the array.\n"
-- )
-- else
-- (
--     format "Material 'bottle' does not exist in the array.\n"
-- )

