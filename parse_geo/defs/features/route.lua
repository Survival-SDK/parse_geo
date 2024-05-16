return {
    ignored = {
        ["piste"] = true,
    },
    properties = {
        bicycle = {
            ["roundtrip"] = true,
            ["signed_direction"] = true,
            ["state"] = true,
        },
        canoe = {
            ["roundtrip"] = true,
        },
        hiking = {
            ["educational"] = true,
            ["pilgrimage"] = true,
            ["roundtrip"] = true,
            ["signed_direction"] = true,
            ["state"] = true,
        },
        power = {
            ["cables"] = true,
            ["voltage"] = true,
            ["wires"] = true,
        },
        railway = {},
        road = {},
        snowmobile = {
            ["ice_road"] = true,
            ["lanes"] = true,
            ["snowmobile"] = true,
            ["toll"] = true,
        },
        train = {
            ["air_conditioning"] = true,
            ["bicycle"] = true,
            ["couchette"] = true,
            ["internet_access"] = true,
            ["internet_access:fee"] = true,
            ["passenger"] = true,
            ["restaurant"] = true,
            ["reservation"] = true,
            ["service"] = true,
            ["sleeping_car"] = true,
            ["socket"] = true,
            ["surveillance"] = true,
            ["surveillance:type"] = true,
            ["toilets"] = true,
        },
    },
    swaps = {},
    swaps_to_properties = {},
}
