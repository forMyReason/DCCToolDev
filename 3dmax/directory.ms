struct SimpleDict
(
    keys = #(),
    values = #(),

    fn Add key value = 
    (
        append keys key
        append values value
    ),

    fn GetValue key = 
    (
        index = findItem keys key
        if index != 0 then values[index]
        else undefined
    )
)

-- 使用示例
myDict = SimpleDict()
myDict.Add "apple" 5
format "Value for 'apple': %\n" (myDict.GetValue "apple")
format "Value for 'banana': %\n" (myDict.GetValue "banana")
format "Value for 'cherry': %\n" (myDict.GetValue "cherry")
